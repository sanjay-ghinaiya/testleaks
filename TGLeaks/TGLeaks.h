//
//  TGLeaks.h
//  TGLeaks
//
//  Created by Harry on 4/21/16.
//  Copyright © 2016 TestGrid Team. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for TGLeaks.
FOUNDATION_EXPORT double TGLeaksVersionNumber;

//! Project version string for TGLeaks.
FOUNDATION_EXPORT const unsigned char TGLeaksVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <TGLeaks/PublicHeader.h>

@interface TGLeaks : NSObject

+ (id)sharedInstance;


- (NSArray *)getLeaks;


- (NSString *)testLib;

@end
