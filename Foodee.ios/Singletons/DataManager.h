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

#import "Team.h"
#import "Strat.h"
#import "Operator.h"
#import "Loadout.h"


@protocol DataManagerDelegate <NSObject>

@optional

- (void)squadJoined;
- (void)squadCreated;

@end

@interface DataManager : NSObject <NetworkEngineDelegate>

@property (nonatomic, strong) id <DataManagerDelegate> delegate;

@property (nonatomic, strong) M13ProgressHUD *hud;

@property (nonatomic, strong) NetworkEngine *networkEngine;

@property (nonatomic, strong) Team *team;
@property (nonatomic, strong) NSMutableArray *strats;

+ (id)sharedManager;

- (void)logout;

// App Manager

- (void)getStratsWithSuccess:(void (^) (NSArray *strats))success
                     failure:(void (^) (NSError *error))failure;

- (void)getTeamWithCode:(NSString *)code andPassword:(NSString *)password
            WithSuccess:(void (^) (Team *team))success
                failure:(void (^) (NSError *error))failure;

- (void)createTeamWithName:(NSString *)name andPassword:(NSString *)password
               WithSuccess:(void (^) (Team *team))success
                   failure:(void (^) (NSError *error))failure;

- (void)createStrat:(Strat *)strat
        WithSuccess:(void (^) (Strat *strat))success
            failure:(void (^) (NSError *error))failure;

- (void)updateStrat:(Strat *)strat
        WithSuccess:(void (^) (Strat *strat))success
            failure:(void (^) (NSError *error))failure;


//- (void)postFile:(NSString *)filePath
//     WithSuccess:(void (^) (void))success
//         failure:(void (^) (NSError *error))failure;

@end
