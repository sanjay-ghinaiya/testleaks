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

@implementation TGLeaks
{
    NSArray *_allocdata;
    FBMemoryProfiler *_memoryProfiler;
}

+ (id)sharedInstance
{
    static dispatch_once_t p = 0;
    
    __strong static id _sharedObject = nil;
    
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
        
        NSLog(@"Allocations Started");
        [FBAssociationManager hook];
        [[FBAllocationTrackerManager sharedManager] startTrackingAllocations];
        [[FBAllocationTrackerManager sharedManager] enableGenerations];
        
        [_sharedObject initialize];
    });
    
    return _sharedObject;
}

- (void)initialize
{
    _memoryProfiler = [FBMemoryProfiler new];
}


- (NSArray *)getLeaks
{
    _allocdata = [[FBAllocationTrackerManager sharedManager] currentSummaryForGenerations];
    
    NSMutableArray *array = [NSMutableArray new];
    for (FBAllocationTrackerSummary *object in _allocdata[0]) {
        
        [array addObject:object.className];
//        NSLog(@"allocdata : %@", object.className);
    }
    
    [array removeObject:@"__NSCFCalendar"];

    NSArray *leaksArray = [self _findRetainCyclesForClassesNamed:array inGeneration:0];
    
     NSLog(@"Get Leaks");
    
    return leaksArray;
}

- (NSArray *)_findRetainCyclesForClassesNamed:(NSArray<NSString *> *)classesNamed
                            inGeneration:(NSUInteger)generationIndex
{
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (NSString *className in classesNamed) {
            
            Class aCls = NSClassFromString(className);
            NSArray *objects = [[FBAllocationTrackerManager sharedManager] instancesForClass:aCls
                                                                                inGeneration:generationIndex];
            FBObjectGraphConfiguration *configuration = [FBObjectGraphConfiguration new];
            FBRetainCycleDetector *detector = [[FBRetainCycleDetector alloc] initWithConfiguration:configuration];
            
            for (id object in objects) {
                [detector addCandidate:object];
            }
            
            NSSet<NSArray<FBObjectiveCGraphElement *> *> *retainCycles =
            [detector findRetainCyclesWithMaxCycleLength:8];
            
//            dispatch_async(dispatch_get_main_queue(), ^{
            
//                NSLog(@"Done : %@", className);
                if ([retainCycles count] > 0) {
                    
                    NSLog(@"Leaks : %@", className);
                    [array addObject:className];
                }
                else {
                    
                    NSLog(@"No Leaks : %@", className);
//                    [array addObject:className];
                }
//            });
        }
    return [array copy];
}

- (NSString *)testLib
{
    return @"Hello from Lib";
}


@end
