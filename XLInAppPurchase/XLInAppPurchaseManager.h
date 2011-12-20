//
//  XLInAppPurchaseManager.h
//  XLInAppPurchaseManager
//
//  Created by Richard Wei on 11-11-7.
//  Copyright (c) 2011 Xinranmsn Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

#define kInAppPurchaseManagerTransactionDidFailNotification @"InAppPurchaseManagerTransactionDidFailNotification"
#define kInAppPurchaseManagerTransactionDidSucceedNotification @"InAppPurchaseManagerTransactionDidSucceedNotification"
#define kInAppPurchaseManagerProductsFetchedNotification @"InAppPurchaseManagerProductsFetchedNotification"

@protocol XLInAppPurchaseManagerDelegate;

@interface XLInAppPurchaseManager : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver, SKRequestDelegate> {
    NSString *_productIdentifier;
    SKProduct *_purchaseProduct;
    SKProductsRequest *_productsRequest;
    BOOL _notificationsEnabled;
}

@property (nonatomic, assign) id <XLInAppPurchaseManagerDelegate> delegate;
@property (nonatomic, retain) NSString *productIdentifier;
@property (nonatomic, readonly) SKProduct *product;
@property (nonatomic, getter = isNotificationsEnabled) BOOL notificationsEnabled;
@property (nonatomic, readonly) BOOL canMakePurchases;

- (id)initWithProductIdentifier:(NSString *)productIdentifier delegate:(id <XLInAppPurchaseManagerDelegate>)delegate loadStore:(BOOL)doLoadStore enableNotifications:(BOOL)enableNotifications;
- (id)initWithProductIdentifier:(NSString *)productIdentifier;
- (void)loadStore;
- (void)makePurchase;

@end

@protocol XLInAppPurchaseManagerDelegate

@required
- (void)inAppPurchaseManager:(XLInAppPurchaseManager *)manager transactionDidSucceed:(SKPaymentTransaction *)transaction; // Save the receipt and provide contents

@optional
- (void)inAppPurchaseManager:(XLInAppPurchaseManager *)manager transactionDidFail:(SKPaymentTransaction *)transaction;
- (void)inAppPurchaseManager:(XLInAppPurchaseManager *)manager transactionDidCancel:(SKPaymentTransaction *)transaction;
- (void)inAppPurchaseManager:(XLInAppPurchaseManager *)manager transactionInProgress:(SKPaymentTransaction *)transaction;

@end
