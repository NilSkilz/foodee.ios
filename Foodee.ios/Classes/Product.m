//
//  Product.m
//  Foodee.ios
//
//  Created by Rob Stokes on 29/09/2019.
//  Copyright © 2019 Rob Stokes. All rights reserved.
//

#import "Product.h"

@implementation Product

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self._id forKey:@"_id"];
    [encoder encodeObject:self.name forKey:@"name"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self._id = [decoder decodeObjectForKey:@"_id"];
        self.name = [decoder decodeObjectForKey:@"name"];
    }
    return self;
}
@end
