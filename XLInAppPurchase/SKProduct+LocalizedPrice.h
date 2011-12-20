//
//  SKProduct+LocalizedPrice.h
//  SKProduct+LocalizedPrice
//
//  Created by Richard Wei on 11-11-7.
//  Copyright (c) 2011 Xinranmsn Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface SKProduct (LocalizedPrice)

@property (nonatomic, readonly) NSString *localizedPrice;

@end
