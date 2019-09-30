//
//  Stock.m
//  Foodee.ios
//
//  Created by Rob Stokes on 30/09/2019.
//  Copyright © 2019 Rob Stokes. All rights reserved.
//

#import "Stock.h"

@implementation Stock

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self._id forKey:@"_id"];
    [encoder encodeObject:self.quantity forKey:@"quantity"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self._id = [decoder decodeObjectForKey:@"_id"];
        self.quantity = [decoder decodeObjectForKey:@"quantity"];
    }
    return self;
}
@end
