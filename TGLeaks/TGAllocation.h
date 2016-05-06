//
//  TGAllocation.h
//  LeaksPodTest
//
//  Created by Harry on 4/22/16.
//  Copyright © 2016 Harry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FBAllocationTrackerSummary.h>

@interface TGAllocation : NSObject

@property (nonatomic, readonly) NSUInteger allocations;
@property (nonatomic, readonly) NSUInteger deallocations;
@property (nonatomic, readonly) NSInteger aliveObjects;
@property (nonatomic, copy, readonly, nonnull) NSString *className;
@property (nonatomic, readonly) NSUInteger instanceSize;
@property (nonatomic, readonly) NSInteger byteCount;
@property (nonatomic, copy, readonly, nonnull) NSString *byteString;
@property (nonatomic, readonly) BOOL isLeaks;

- (nonnull instancetype)initWithAllocations:(NSUInteger)allocations
                              deallocations:(NSUInteger)deallocations
                               aliveObjects:(NSInteger)aliveObjects
                                  className:(nonnull NSString *)className
                               instanceSize:(NSUInteger)instanceSize;

- (void)updateLeaks:(BOOL)isLeaks;

@end
