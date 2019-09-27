//
//  NetworkEngine.h
//  Seed.iOS
//
//  Created by Rob Stokes on 05/06/2015.
//  Copyright (c) 2015 LimeNinja. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import "NetworkEngine.h"

@protocol NetworkEngineDelegate <NSObject>

- (void)appWentOffline;
- (void)appCameOnline;
- (void)receivedUnauthorised;

@end

@interface NetworkEngine : NSObject

@property (nonatomic) BOOL isOnline;

@property (nonatomic, strong) id <NetworkEngineDelegate> delegate;

+ (id)sharedEngine;

//- (void)loginWith:(User *)user
//      withSuccess:(void (^)(User *user))success
//       andFailure:(void (^)(NSError *error))failure;
//
//- (void)resetPasswordForUser:(User *)user
//                 withSuccess:(void (^)(User *user))success
//                  andFailure:(void (^)(NSError *error))failure;

- (void)get:(NSString *)url
withMapping:(RKObjectMapping *)mapping
withSuccess:(void (^)(NSArray *objects))success
    failure:(void (^)(NSError *error))failure;

- (void)getOne:(NSString *)url
   withMapping:(RKObjectMapping *)mapping
   withSuccess:(void (^)(NSArray *objects))success
       failure:(void (^)(NSError *error))failure;

-(void)post:(NSObject *)object
      atURL:(NSString *)url
withRequestDescriptors:(NSArray *)descriptors
withResponseMapping:(RKObjectMapping *)responseMapping
withSuccess:(void (^) (NSObject *returnedObject))success
    failure:(void (^)(NSError *error))failure;

-(void)put:(NSObject *)object
     atURL:(NSString *)url
withRequestDescriptors:(NSArray *)descriptors
withResponseMapping:(RKObjectMapping *)responseMapping
withSuccess:(void (^) (NSObject *returnedObject))success
   failure:(void (^)(NSError *error))failure;

@end
