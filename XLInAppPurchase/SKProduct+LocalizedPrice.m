//
//  SKProduct+LocalizedPrice.m
//  SKProduct+LocalizedPrice
//
//  Created by Richard Wei on 11-11-7.
//  Copyright (c) 2011 Xinranmsn Labs. All rights reserved.
//

#import "SKProduct+LocalizedPrice.h"

@implementation SKProduct (LocalizedPrice)

- (NSString *)localizedPrice {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:self.priceLocale];
    NSString *formattedString = [numberFormatter stringFromNumber:self.price];
    [numberFormatter release];
    return formattedString;
}

@end
