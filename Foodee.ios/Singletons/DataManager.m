//
//  DataManager.m
//  Seed.iOS
//
//  Created by Rob Stokes on 05/06/2015.
//  Copyright (c) 2015 LimeNinja. All rights reserved.
//

#import "DataManager.h"
#import "Constants.h"
#import "objc/runtime.h"
#import "M13ProgressViewRing.h"

@implementation DataManager

+ (id)sharedManager {
    static DataManager *sharedDataManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDataManager = [[self alloc] init];
    });
    return sharedDataManager;
}

- (id)init {
    if (self = [super init]) {
        // Get user from storage if exists
    }
    self.networkEngine = [NetworkEngine sharedEngine];
    self.networkEngine.delegate = self;
    return self;
}



# pragma mark - Getters / Setters

- (void)addProductWithBarcode:(NSString *)barcode
                  withSuccess:(void (^) (Product *product))success
                      failure:(void (^) (NSError *error))failure {

    NSLog(@"Adding Product");
    NSString *url = [NSString stringWithFormat:@"products/%@", barcode];

    RKObjectMapping *responseMapping = [RKObjectMapping mappingForClass:[Product class]];
    [responseMapping addAttributeMappingsFromDictionary:[self getMappingAttributesForProduct]];
    
    // Create POST Request
    [self.networkEngine get:url withMapping:responseMapping withSuccess:^(Product *product) {
        NSLog(@"Created Product: %@", product);
//       Product *product = (Product *)returnedObject;
       success(product);
    } failure:^(NSError *error) {
        NSLog(@"Error: %@", error);
        failure(error);
    }];
}


- (void)consumeOneWithBarcode:(NSString *)barcode
                  withSuccess:(void (^) (Product *product))success
                      failure:(void (^) (NSError *error))failure {
    
    NSLog(@"Consuming One Product");
    NSString *url = [NSString stringWithFormat:@"stock/barcode/one/%@", barcode];

    RKObjectMapping *responseMapping = [RKObjectMapping mappingForClass:[Product class]];
    [responseMapping addAttributeMappingsFromDictionary:[self getMappingAttributesForProduct]];
        
    // Create POST Request
    [self.networkEngine get:url withMapping:responseMapping withSuccess:^(Product *product) {
        NSLog(@"Consumed Product: %@", product);
        success(product);
    } failure:^(NSError *error) {
        NSLog(@"Error: %@", error);
        failure(error);
    }];
}

- (void)consumeAllWithBarcode:(NSString *)barcode
                  withSuccess:(void (^) (Product *product))success
                      failure:(void (^) (NSError *error))failure {
    
    NSLog(@"Consuming All Product");
        NSString *url = [NSString stringWithFormat:@"stock/barcode/all/%@", barcode];

        RKObjectMapping *responseMapping = [RKObjectMapping mappingForClass:[Product class]];
        [responseMapping addAttributeMappingsFromDictionary:[self getMappingAttributesForProduct]];
            
        // Create POST Request
        [self.networkEngine get:url withMapping:responseMapping withSuccess:^(Product *product) {
            NSLog(@"Consumed Product: %@", product);
            success(product);
        } failure:^(NSError *error) {
            NSLog(@"Error: %@", error);
            failure(error);
        }];
    
}

- (void)markSpoiledWithBarcode:(NSString *)barcode
                   withSuccess:(void (^) (Product *product))success
                       failure:(void (^) (NSError *error))failure {
    
    NSLog(@"Spoiling One Product");
        NSString *url = [NSString stringWithFormat:@"stock/barcode/spoiled/%@", barcode];

        RKObjectMapping *responseMapping = [RKObjectMapping mappingForClass:[Product class]];
        [responseMapping addAttributeMappingsFromDictionary:[self getMappingAttributesForProduct]];
            
        // Create POST Request
        [self.networkEngine get:url withMapping:responseMapping withSuccess:^(Product *product) {
           NSLog(@"Consumed Product: %@", product);;
           success(product);
        } failure:^(NSError *error) {
            NSLog(@"Error: %@", error);
            failure(error);
        }];
    
}

//- (void)updateStrat:(Strat *)strat
//        WithSuccess:(void (^) (Strat *strat))success
//            failure:(void (^) (NSError *error))failure {
    
//    NSLog(@"Updating Strat");
//    NSString *url = [NSString stringWithFormat:@"/strats/%@", strat._id];
//
//
//    RKObjectMapping *requestMapping = [RKObjectMapping requestMapping];
//    [requestMapping addAttributeMappingsFromDictionary:@{@"map":@"map", @"name":@"name", @"type":@"type", @"gameMode":@"gameMode"}];
//
//    RKObjectMapping *operatorMapping = [RKObjectMapping requestMapping];
//    [operatorMapping addAttributeMappingsFromArray:@[@"name", @"prepPhase", @"actionPhase"]];
//
//    RKObjectMapping *loadoutMapping = [RKObjectMapping requestMapping];
//    [loadoutMapping addAttributeMappingsFromArray:@[@"primary", @"secondary", @"gadget"]];
//
//    [operatorMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"loadout" toKeyPath:@"loadout" withMapping:loadoutMapping]];
//
//    [requestMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"operators" toKeyPath:@"operators" withMapping:operatorMapping]];
//
//    RKObjectMapping *responseMapping = [RKObjectMapping mappingForClass:[Strat class]];
//    [responseMapping addAttributeMappingsFromDictionary:[self getMappingAttributesForStrat]];
//
//
//    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:requestMapping objectClass:[Strat class] rootKeyPath:nil method:RKRequestMethodPUT];
//
//
//    // Create PUT Request
//    [self.networkEngine put:strat atURL:url withRequestDescriptors:@[requestDescriptor] withResponseMapping:responseMapping withSuccess:^(NSObject *returnedObject) {
//        NSLog(@"Created Strat: %@", returnedObject);
//        Strat *strat = (Strat *)returnedObject;
//        success(strat);
//    } failure:^(NSError *error) {
//        NSLog(@"Error: %@", error);
//    }];
//}

-(NSDictionary *)getMappingAttributesForProduct
{
    NSMutableDictionary *att = [[NSMutableDictionary alloc]init];
    [att setValue:@"_id" forKey:@"_id"];
    [att setValue:@"name" forKey:@"name"];
    
    NSDictionary *retArray = [NSDictionary dictionaryWithDictionary:att];
    return retArray;
}

@end
