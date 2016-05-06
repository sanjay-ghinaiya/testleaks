//
//  TGAllocation.m
//  LeaksPodTest
//
//  Created by Harry on 4/22/16.
//  Copyright © 2016 Harry. All rights reserved.
//

#import "TGAllocation.h"

@implementation TGAllocation

- (instancetype)initWithAllocations:(NSUInteger)allocations
                      deallocations:(NSUInteger)deallocations
                       aliveObjects:(NSInteger)aliveObjects
                          className:(NSString *)className
                       instanceSize:(NSUInteger)instanceSize
{
    if ((self = [super init])) {
        
        _allocations = allocations;
        _deallocations = deallocations;
        _aliveObjects = aliveObjects;
        _className = className;
        _instanceSize = instanceSize;
        
        _byteCount = aliveObjects * instanceSize;
        
        NSByteCountFormatter *_byteCountFormatter = [NSByteCountFormatter new];
        _byteString = [_byteCountFormatter stringFromByteCount:_byteCount];
    }
    
    return self;
}

- (void)updateLeaks:(BOOL)isLeaks {

    _isLeaks = isLeaks;
}

@end
