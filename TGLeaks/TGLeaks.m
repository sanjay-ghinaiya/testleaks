//
//  TGLeaks.m
//  TGLeaks
//
//  Created by Harry on 4/19/16.
//  Copyright © 2016 Harry. All rights reserved.
//

#import "TGLeaks.h"
#import <FBAllocationTracker/FBAllocationTracker.h>
#import <FBRetainCycleDetector/FBRetainCycleDetector.h>
#import <FBMemoryProfiler/FBMemoryProfiler.h>
#import "TGAllocation.h"

@implementation TGLeaks
{
    NSArray *_allocdata;
    FBMemoryProfiler *_memoryProfiler;
    NSMutableArray *_marks;
}

+ (id)sharedInstance
{
    static dispatch_once_t p = 0;
    
    __strong static id _sharedObject = nil;
    
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
        
        [FBAssociationManager hook];
        [[FBAllocationTrackerManager sharedManager] startTrackingAllocations];
        [[FBAllocationTrackerManager sharedManager] enableGenerations];
        
        [_sharedObject initialize];
    });
    
    return _sharedObject;
}

- (void)initialize
{
    _marks = [[NSMutableArray alloc] init];
    [_marks addObject:@"Default"];
    _memoryProfiler = [FBMemoryProfiler new];
    
    [self startTimedTask];
}


- (NSArray *)getLeaks
{
    _allocdata = [[FBAllocationTrackerManager sharedManager] currentSummaryForGenerations];
    
    NSMutableArray *array = [NSMutableArray new];
    for (FBAllocationTrackerSummary *object in _allocdata[[_marks count]-1]) {
        
        if(![object.className containsString:@"__NSCFCalendar"])
            [array addObject:[[TGAllocation alloc] initWithAllocations:object.allocations deallocations:object.deallocations aliveObjects:object.aliveObjects className:object.className instanceSize:object.instanceSize]];
    }
    
    NSArray *leaksArray = [self _findRetainCyclesForClassesNamed:array inGeneration:0];
    NSString *leaksData = @"StartingLeakData\n";
    for (TGAllocation *class in leaksArray) {
        
        //        NSLog(@"ClassName : %@ Size : %@ Leaks : %@", class.className, class.byteString, class.isLeaks?@"YES":@"NO");
        leaksData = [leaksData stringByAppendingFormat:@"%@, %lu, %lu, %ld, %lu, %ldu, %@, %@\n", class.className, (unsigned long)class.allocations, (unsigned long)class.deallocations, (long)class.aliveObjects, (unsigned long)class.instanceSize, (long)class.byteCount, class.byteString, class.isLeaks?@"YES":@"NO"];
    }
    leaksData = [leaksData stringByAppendingString:@"EndingLeakData"];
    
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    if (!window)
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        
        //        NSLog(@"\n\n%@", leaksData);
        BOOL isAlreadyExist = NO;
        for (UIView *view in [window subviews])
        {
            if([view isKindOfClass:[UITextView class]] && [[view accessibilityLabel] containsString:@"LeaksValue"]) {
                
                isAlreadyExist = YES;
                UITextView *leaksTextView = (UITextView *)view;
                leaksTextView.text = leaksData;
            }
        }
        
        if(isAlreadyExist == NO) {
            
            UITextView *leaksTextView = [[UITextView alloc] init];
            leaksTextView.text = leaksData;
            [leaksTextView setFrame:CGRectMake(0,0,200,300)];
            [leaksTextView setAccessibilityLabel:@"LeaksValue"];
            [window addSubview:leaksTextView];
            [window sendSubviewToBack:leaksTextView];
        }
        
    });
    
    return leaksArray;
}

- (NSArray *)_findRetainCyclesForClassesNamed:(NSArray<TGAllocation *> *)classes
                                 inGeneration:(NSUInteger)generationIndex
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (TGAllocation *class in classes) {
        
        Class aCls = NSClassFromString(class.className);
        NSArray *objects = [[FBAllocationTrackerManager sharedManager] instancesForClass:aCls
                                                                            inGeneration:generationIndex];
        FBObjectGraphConfiguration *configuration = [FBObjectGraphConfiguration new];
        FBRetainCycleDetector *detector = [[FBRetainCycleDetector alloc] initWithConfiguration:configuration];
        
        for (id object in objects) {
            [detector addCandidate:object];
        }
        
        NSSet<NSArray<FBObjectiveCGraphElement *> *> *retainCycles =
        [detector findRetainCyclesWithMaxCycleLength:8];
        
        if ([retainCycles count] > 0) {
            
            [class updateLeaks:YES];
            [array addObject:class];
        }
        else {
            
            [class updateLeaks:NO];
            [array addObject:class];
        }
    }
    return [array copy];
}

- (void)createAllocMark:(NSString *)markString {
    
    [self getLeaks];
    [_marks addObject:markString];
    [[FBAllocationTrackerManager sharedManager] markGeneration];
}

- (void)startTimedTask
{
    [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(performBackgroundTask) userInfo:nil repeats:YES];
}

- (void)performBackgroundTask
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        [self getLeaks];
    });
}

@end
