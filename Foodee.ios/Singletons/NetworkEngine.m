//
//  NetworkEngine.m
//  Seed.iOS
//
//  Created by Rob Stokes on 05/06/2015.
//  Copyright (c) 2015 LimeNinja. All rights reserved.
//

#import "NetworkEngine.h"
#import "Constants.h"
#import "DataManager.h"
#import <RestKit/RestKit.h>

@implementation NetworkEngine

int offlineCount = 0;
NSIndexSet *statusCodes;

+ (id)sharedEngine {
    static NetworkEngine *sharedEngine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedEngine = [[self alloc] init];
    });
    return sharedEngine;
}
//
//- (id)init {
//    self = [super initWithBaseURL:[NSURL URLWithString:@API_URL]];
//    if (self) {
//        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
//        [self setParameterEncoding:AFJSONParameterEncoding];
//        [[NSURLCache sharedURLCache] removeAllCachedResponses];
//        _isOnline = YES;
//        statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
////        [self createServerMonitor];
//    }
//    return self;
//}

- (void)get:(NSString *)url withMapping:(RKObjectMapping *)mapping withSuccess:(void (^)(Product *product))success failure:(void (^)(NSError *error))failure {
    
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@API_URL]];

    NSIndexSet *statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:RKRequestMethodGET pathPattern:nil keyPath:@"data" statusCodes:statusCodes];
    
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"application/json"];
    [manager addResponseDescriptor:responseDescriptor];
    [manager setRequestSerializationMIMEType:RKMIMETypeJSON];
    
    [manager getObject:[Product class] path:url parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"Here");
        Product *product = mappingResult.firstObject;
        success(product);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        failure(error);
    }];
    
}


# pragma mark - Helper Methods


- (void)createServerMonitor {
    
    dispatch_queue_t myBackgroundQ = dispatch_queue_create("com.LimeNinja.backgroundDelay", NULL);
    // Could also get a global queue; in this case, don't release it below.
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), myBackgroundQ, ^(void){
        [self createServerMonitor];
        if ([self pingServer]) {
            //            NSLog(@"Online");
            if (!self.isOnline) {
                self.isOnline = YES;
//                [self.delegate networkConnectionDidChangeTo:YES];
                
            }
            offlineCount = 0;
        } else {
            offlineCount++;
//            NSLog(@"Offline Count: %d", offlineCount);
            // Allow 2 false positives
            if (offlineCount >= 3 && self.isOnline) {
                self.isOnline = NO;
                NSLog(@"Properly Offline");
//                [self.delegate networkConnectionDidChangeTo:NO];
            }
        }
    });
}


- (BOOL)pingServer {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@servertest", @BASE_URL]];
    NSString *webData= [NSString stringWithContentsOfURL:url encoding:NSASCIIStringEncoding error:nil];
    if ([webData isEqualToString:@"true"]) return true;
//    NSLog(@"%@", webData);
    return false;
}

@end
