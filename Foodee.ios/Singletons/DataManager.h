//
//  DataManager.h
//  Seed.iOS
//
//  Created by Rob Stokes on 05/06/2015.
//  Copyright (c) 2015 LimeNinja. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkEngine.h"
#import "M13ProgressHUD.h"
#import "Product.h"

@protocol DataManagerDelegate <NSObject>

@optional

- (void)productAdded:(NSString *)name;

@end

@interface DataManager : NSObject <NetworkEngineDelegate>

@property (nonatomic, strong) id <DataManagerDelegate> delegate;

@property (nonatomic, strong) M13ProgressHUD *hud;

@property (nonatomic, strong) NetworkEngine *networkEngine;


+ (id)sharedManager;


- (void)addProductWithBarcode:(NSString *)barcode
                  withSuccess:(void (^) (Product *product))success
                      failure:(void (^) (NSError *error))failure;

- (void)consumeOneWithBarcode:(NSString *)barcode
                  withSuccess:(void (^) (Product *product))success
                      failure:(void (^) (NSError *error))failure;

- (void)consumeAllWithBarcode:(NSString *)barcode
                  withSuccess:(void (^) (Product *product))success
                      failure:(void (^) (NSError *error))failure;

- (void)markSpoiledWithBarcode:(NSString *)barcode
                   withSuccess:(void (^) (Product *product))success
                       failure:(void (^) (NSError *error))failure;

@end
