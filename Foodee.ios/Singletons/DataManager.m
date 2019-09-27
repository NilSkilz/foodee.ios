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
#import "UICKeyChainStore.h"
#import "M13ProgressViewRing.h"
#import "AppDelegate.h"


@implementation DataManager

@synthesize team = _team;

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
    
    self.hud = [[M13ProgressHUD alloc] initWithProgressView:[[M13ProgressViewRing alloc] init]];
    
    self.hud.progressViewSize = CGSizeMake(60.0, 60.0);
    self.hud.animationPoint = CGPointMake([UIScreen mainScreen].bounds.size.width / 2, [UIScreen mainScreen].bounds.size.height / 2);
    
    self.hud.indeterminate = YES;
    self.hud.secondaryColor = [UIColor colorWithRed:45/255.0 green:168/255.0 blue:227/255.0 alpha:1];
    self.hud.statusFont = [UIFont fontWithName:@"OpenSans-CondensedBold" size:16];
    self.hud.statusColor = [UIColor colorWithRed:45/255.0 green:168/255.0 blue:227/255.0 alpha:1];
    self.hud.shouldAutorotate = NO;
    
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    UIWindow *window = delegate.window;
    [window addSubview:self.hud];

    return self;
}

-(void)logout {
    NSLog(@"Logging out");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nil forKey:kUserKey];
    [defaults synchronize];
    self.team = nil;
    _team = nil;
}

# pragma mark - Getters / Setters

- (Team *)team {
    
    if (_team) {
        return _team;
    }
    
    NSLog(@"No user in pasteboard, or not allowed, checking local keychain");
    // Get user from local keychain
    UICKeyChainStore *localKeychain = [UICKeyChainStore keyChainStoreWithService:@"squad"];
    localKeychain.synchronizable = YES;
    NSData *encodedTeam = [localKeychain dataForKey:@"team"];
    NSLog(@"Got encoded team: %@", encodedTeam);
    
    // Convert data to user
    Team *team = [NSKeyedUnarchiver unarchiveObjectWithData:encodedTeam];
    if (team) {
        NSLog(@"Got team");
        _team = team;
    }
    
    return _team;
}

- (void)setTeam:(Team *)team {
    _team = team;
    
    NSData *encodedTeam = [NSKeyedArchiver archivedDataWithRootObject:team];

    // Save user to local keychain
    UICKeyChainStore *localKeychain = [UICKeyChainStore keyChainStoreWithService:@"squad"];
    localKeychain.synchronizable = YES;
    [localKeychain setData:encodedTeam forKey:@"team"];
}

# pragma mark - Stubs

- (void)getStratsWithSuccess:(void (^) (NSArray *strats))success
                     failure:(void (^) (NSError *error))failure {
    
    self.hud.status = @"Getting Strats";
    [self.hud show:YES];
    self.hud.indeterminate = YES;

    
    NSLog(@"Getting Strats");
    NSString *url = @"/strats";

    // Create Loadout Mapping
    RKObjectMapping *loadoutMapping = [RKObjectMapping mappingForClass:[Loadout class]];
    [loadoutMapping addAttributeMappingsFromArray:@[@"primary", @"secondary", @"gadget"]];

    // Create Operator Mapping
    RKObjectMapping *operatorMapping = [RKObjectMapping mappingForClass:[Operator class]];
    [operatorMapping addAttributeMappingsFromArray:@[@"name", @"prepPhase", @"actionPhase"]];
    [operatorMapping addRelationshipMappingWithSourceKeyPath:@"loadout" mapping:loadoutMapping];

    // Create Strat Mapping
    RKObjectMapping *stratMapping = [RKObjectMapping mappingForClass:[Strat class]];
    [stratMapping addAttributeMappingsFromArray:@[@"_id", @"map", @"gameMode", @"type", @"name", @"wins", @"losses", @"locked"]];
    [stratMapping addRelationshipMappingWithSourceKeyPath:@"operators" mapping:operatorMapping];

    // Create Get Request
    [self.networkEngine get:url withMapping:stratMapping withSuccess:^(NSArray *objects) {
        NSLog(@"Got Objects: %@", objects);
        self.strats = [NSMutableArray arrayWithArray:objects];
        [self.hud hide:YES];
        success(objects);
    } failure:^(NSError *error) {
        NSLog(@"Failure");
        [self.hud hide:YES];
        failure(error);
    }];
}


- (void)getTeamWithCode:(NSString *)code andPassword:(NSString *)password
            WithSuccess:(void (^) (Team *team))success
                failure:(void (^) (NSError *error))failure {

    self.hud.status = @"Joining SQUAD";
    [self.hud show:YES];
    
    NSLog(@"Getting Team");
    NSString *url = [NSString stringWithFormat:@"/accounts/"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:code forKey:@"code"];
    [defaults setValue:password forKey:@"password"];
    
    // Create Asset Mapping
    RKObjectMapping *teamMapping = [RKObjectMapping mappingForClass:[Team class]];
    [teamMapping addAttributeMappingsFromDictionary:[self getMappingAttributesForTeam]];
    
    // Create Get Request
    [self.networkEngine get:url withMapping:teamMapping withSuccess:^(NSArray *objects) {
        Team *team = [objects firstObject];
        NSLog(@"Got Team: %@", team);
        self.team = team;
//        [self.hud hide:YES];
        [self.delegate squadJoined];
        success(team);
    } failure:^(NSError *error) {
        NSLog(@"Failure");
        [self.hud hide:YES];
        failure(error);
    }];
}

- (void)createTeamWithName:(NSString *)name andPassword:(NSString *)password
               WithSuccess:(void (^) (Team *team))success
                   failure:(void (^) (NSError *error))failure {
    
    // Show the HUD
    self.hud.status = @"Creating SQUAD";
    [self.hud show:YES];
   
    
    NSLog(@"Creating Team");
    NSString *url = [NSString stringWithFormat:@"accounts/"];
    
    
    RKObjectMapping *requestMapping = [RKObjectMapping requestMapping];
    [requestMapping addAttributeMappingsFromDictionary:@{@"team_name":@"team_name", @"password":@"password"}];
    
    RKObjectMapping *responseMapping = [RKObjectMapping mappingForClass:[Team class]];
    [responseMapping addAttributeMappingsFromDictionary:[self getMappingAttributesForTeam]];
    
    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:requestMapping objectClass:[Team class] rootKeyPath:nil method:RKRequestMethodPOST];
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:password forKey:@"password"];
    
    Team *team = [[Team alloc]init];
    team.team_name = name;
    team.password = password;
    
    // Create POST Request
    [self.networkEngine post:team atURL:url withRequestDescriptors:@[requestDescriptor] withResponseMapping:responseMapping withSuccess:^(NSObject *returnedObject) {
        NSLog(@"Created Team: %@", returnedObject);
        Team *team = (Team *)returnedObject;
        self.team = team;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:team.code forKey:@"code"];
        
        [self.hud hide:YES];
        [self.delegate squadCreated];
        success(team);
    } failure:^(NSError *error) {
        [self.hud hide:YES];
        NSLog(@"Error: %@", error);
        failure(error);
    }];
}

- (void)createStrat:(Strat *)strat
               WithSuccess:(void (^) (Strat *strat))success
                   failure:(void (^) (NSError *error))failure {
    
    // Show the HUD
    self.hud.status = @"Creating Strat";
    [self.hud show:YES];
    
    
    NSLog(@"Creating Strat");
    NSString *url = [NSString stringWithFormat:@"strats/"];
    
    
    RKObjectMapping *requestMapping = [RKObjectMapping requestMapping];
    [requestMapping addAttributeMappingsFromDictionary:@{@"map":@"map", @"name":@"name", @"type":@"type", @"gameMode":@"gameMode"}];
    
    RKObjectMapping *responseMapping = [RKObjectMapping mappingForClass:[Strat class]];
    [responseMapping addAttributeMappingsFromDictionary:[self getMappingAttributesForStrat]];
    
    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:requestMapping objectClass:[Strat class] rootKeyPath:nil method:RKRequestMethodPOST];
    
    
    // Create POST Request
    [self.networkEngine post:strat atURL:url withRequestDescriptors:@[requestDescriptor] withResponseMapping:responseMapping withSuccess:^(NSObject *returnedObject) {
        NSLog(@"Created Strat: %@", returnedObject);
        Strat *strat = (Strat *)returnedObject;
        [self.hud hide:YES];
        success(strat);
    } failure:^(NSError *error) {
        [self.hud hide:YES];
        NSLog(@"Error: %@", error);
    }];
}

- (void)updateStrat:(Strat *)strat
        WithSuccess:(void (^) (Strat *strat))success
            failure:(void (^) (NSError *error))failure {
    
    NSLog(@"Updating Strat");
    NSString *url = [NSString stringWithFormat:@"/strats/%@", strat._id];
    
    
    RKObjectMapping *requestMapping = [RKObjectMapping requestMapping];
    [requestMapping addAttributeMappingsFromDictionary:@{@"map":@"map", @"name":@"name", @"type":@"type", @"gameMode":@"gameMode"}];
    
    RKObjectMapping *operatorMapping = [RKObjectMapping requestMapping];
    [operatorMapping addAttributeMappingsFromArray:@[@"name", @"prepPhase", @"actionPhase"]];
    
    RKObjectMapping *loadoutMapping = [RKObjectMapping requestMapping];
    [loadoutMapping addAttributeMappingsFromArray:@[@"primary", @"secondary", @"gadget"]];
    
    [operatorMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"loadout" toKeyPath:@"loadout" withMapping:loadoutMapping]];
    
    [requestMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"operators" toKeyPath:@"operators" withMapping:operatorMapping]];
    
    RKObjectMapping *responseMapping = [RKObjectMapping mappingForClass:[Strat class]];
    [responseMapping addAttributeMappingsFromDictionary:[self getMappingAttributesForStrat]];
    
    
    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:requestMapping objectClass:[Strat class] rootKeyPath:nil method:RKRequestMethodPUT];
    
    
    // Create PUT Request
    [self.networkEngine put:strat atURL:url withRequestDescriptors:@[requestDescriptor] withResponseMapping:responseMapping withSuccess:^(NSObject *returnedObject) {
        NSLog(@"Created Strat: %@", returnedObject);
        Strat *strat = (Strat *)returnedObject;
        success(strat);
    } failure:^(NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

-(NSDictionary *)getMappingAttributesForTeam
{
    NSMutableDictionary *att = [[NSMutableDictionary alloc]init];
    [att setValue:@"_id" forKey:@"_id"];
    [att setValue:@"team_name" forKey:@"team_name"];
    [att setValue:@"code" forKey:@"code"];
    [att setValue:@"password" forKey:@"password"];
    
    NSDictionary *retArray = [NSDictionary dictionaryWithDictionary:att];
    return retArray;
}

-(NSDictionary *)getMappingAttributesForStrat
{
    NSMutableDictionary *att = [[NSMutableDictionary alloc]init];
    [att setValue:@"_id" forKey:@"_id"];
    [att setValue:@"_account_id" forKey:@"_account_id"];
    
    [att setValue:@"map" forKey:@"map"];
    [att setValue:@"gameMode" forKey:@"gameMode"];
    [att setValue:@"type" forKey:@"type"];
    [att setValue:@"name" forKey:@"name"];

    [att setValue:@"wins" forKey:@"wins"];
    [att setValue:@"losses" forKey:@"losses"];

    [att setValue:@"locked" forKey:@"locked"];
    
    NSDictionary *retArray = [NSDictionary dictionaryWithDictionary:att];
    return retArray;
}


//- (void)postFile:(NSString *)filePath
//     WithSuccess:(void (^) (void))success
//         failure:(void (^) (NSError *error))failure {
//    // Upload file
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://app.appstash.io/api/v1/assets/profile_image"]];
//    [request setHTTPMethod:@"POST"];
//
//    NSString *boundary = [self generateBoundaryString];
//
//    // set content type
//    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
//    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
//
//
//    ASConfig *config = [ASConfig sharedConfig];
//    // Set auth header
//    [request setValue:config.app.account_id forHTTPHeaderField:@"x-account-id"];
//    [request setValue:@"ipa" forHTTPHeaderField:@"x-file"];
//    [request setValue:@"en" forHTTPHeaderField:@"x-language"];
//    [request setValue:[NSString stringWithFormat:@"Bearer %@", self.user.token] forHTTPHeaderField:@"authorization"];
//
//    // create body
//    NSData *httpBody = [self createBodyWithBoundary:boundary parameters:nil paths:@[filePath] fieldName:@"image"];
//
//    NSURLSession *session = [NSURLSession sharedSession];  // use sharedSession or create your own
//
//    NSURLSessionTask *task = [session uploadTaskWithRequest:request fromData:httpBody completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        NSLog(@"Response: %@", response);
//        NSLog(@"Data: %@", data);
//        NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        NSLog(@"result = %@", result);
//
//        success();
//    }];
//    [task resume];
//}

- (NSString *)generateBoundaryString
{
    return [NSString stringWithFormat:@"Boundary-%@", [[NSUUID UUID] UUIDString]];
}

- (NSData *)createBodyWithBoundary:(NSString *)boundary
                        parameters:(NSDictionary *)parameters
                             paths:(NSArray *)paths
                         fieldName:(NSString *)fieldName
{
    NSMutableData *httpBody = [NSMutableData data];
    
    // add params (all params are strings)
    
    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *parameterKey, NSString *parameterValue, BOOL *stop) {
        [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", parameterKey] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"%@\r\n", parameterValue] dataUsingEncoding:NSUTF8StringEncoding]];
    }];
    
    // add image data
    
    for (NSString *path in paths) {
        NSString *filename  = [path lastPathComponent];
        NSData   *data      = [NSData dataWithContentsOfFile:path];
        NSString *mimetype  = @"image/jpg";
        
        [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n;", fieldName, filename] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", mimetype] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:data];
        [httpBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [httpBody appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    return httpBody;
}

@end
//
