//
//  XLInAppPurchaseManager.m
//  XLInAppPurchaseManager
//
//  Created by Richard Wei on 11-11-7.
//  Copyright (c) 2011 Xinranmsn Labs. All rights reserved.
//

#import "XLInAppPurchaseManager.h"
#import "SKProduct+LocalizedPrice.h"

@interface XLInAppPurchaseManager ()

- (void)requestPurchaseProductData;
- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful;
- (void)completeTransaction:(SKPaymentTransaction *)transaction;
- (void)restoreTransaction:(SKPaymentTransaction *)transaction;
- (void)failedTransaction:(SKPaymentTransaction *)transaction;

@end

@implementation XLInAppPurchaseManager

@synthesize productIdentifier = _productIdentifier, delegate = _delegate, product = _purchaseProduct, notificationsEnabled = _notificationsEnabled;

- (id)initWithProductIdentifier:(NSString *)productIdentifier {
    if ((self = [super init])) {
        self.productIdentifier = productIdentifier;
        self.notificationsEnabled = NO;
    }
    return self;
}

- (id)initWithProductIdentifier:(NSString *)productIdentifier delegate:(id <XLInAppPurchaseManagerDelegate>)delegate loadStore:(BOOL)doLoadStore enableNotifications:(BOOL)enableNotifications {
    if ((self = [super init])) {
        self.productIdentifier = productIdentifier;
        self.delegate = delegate;
        self.notificationsEnabled = enableNotifications;
        if (doLoadStore) [self loadStore];
    }
    return self;
}

- (void)loadStore {
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [self requestPurchaseProductData];
}

- (void)requestPurchaseProductData {
    NSSet *productIdentifiers = [NSSet setWithObject:_productIdentifier];
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    _productsRequest.delegate = self;
    [_productsRequest start];
}

- (BOOL)canMakePurchases {
    return [SKPaymentQueue canMakePayments] && _purchaseProduct;
}

- (void)makePurchase {
    
    SKPayment *payment;
    if ([[SKPayment class] respondsToSelector:@selector(paymentWithProduct:)])
        payment = [SKPayment paymentWithProduct:_purchaseProduct];
    else
        payment = [SKPayment paymentWithProductIdentifier:_productIdentifier];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

#pragma mark - Store kit products response delegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSArray *products = response.products;
    _purchaseProduct = products.count == 1 ? [[products objectAtIndex:0] retain] : nil;
#ifdef DEBUG
    if (_purchaseProduct) {
        NSLog(@"Product Title: %@", _purchaseProduct.localizedTitle);
        NSLog(@"Product Description: %@", _purchaseProduct.localizedDescription);
        NSLog(@"Product Price: %@", _purchaseProduct.price);
        NSLog(@"Product Localized Price: %@", _purchaseProduct.localizedPrice);
        NSLog(@"Product Identifier: %@", _purchaseProduct.productIdentifier);
    }
    for (NSString *invalidProductIdentifier in response.invalidProductIdentifiers)
        NSLog(@"Invalid product id: %@", invalidProductIdentifier);
#endif
    [_productsRequest cancel];
    if (_notificationsEnabled) [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerProductsFetchedNotification object:self userInfo:nil];
}

#pragma mark - Purchase helpers

- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful {
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    if (_notificationsEnabled) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:transaction, @"transaction", nil];
        if (wasSuccessful) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionDidSucceedNotification object:self userInfo:userInfo];
        }
        else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionDidFailNotification object:self userInfo:userInfo];
        }
    }
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    if ([transaction.payment.productIdentifier isEqualToString:_productIdentifier])
        [self.delegate inAppPurchaseManager:self transactionDidSucceed:transaction];
    [self finishTransaction:transaction wasSuccessful:YES];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    if ([transaction.payment.productIdentifier isEqualToString:_productIdentifier])
        [self.delegate inAppPurchaseManager:self transactionDidSucceed:transaction.originalTransaction];
    [self finishTransaction:transaction wasSuccessful:YES];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    if (transaction.error.code != SKErrorPaymentCancelled) {
        if ([(NSObject *)self.delegate respondsToSelector:@selector(inAppPurchaseManager:transactionDidFail:)])
            [self.delegate inAppPurchaseManager:self transactionDidFail:transaction];
        [self finishTransaction:transaction wasSuccessful:NO];
    }
    else {
        if ([(NSObject *)self.delegate respondsToSelector:@selector(inAppPurchaseManager:transactionDidCancel:)])
            [self.delegate inAppPurchaseManager:self transactionDidCancel:transaction];
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
}

#pragma mark - Store kit payment transaction observer

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing:
                if ([(NSObject *)self.delegate respondsToSelector:@selector(inAppPurchaseManager:transactionInProgress:)]) [self.delegate inAppPurchaseManager:self transactionInProgress:transaction];
                break;
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
            default:
                break;
        }
    }
}

#pragma mark - Memory management

- (void)dealloc {
    [_productsRequest release];
    [_purchaseProduct release];
    [_productIdentifier release];
    [super dealloc];
}

@end
