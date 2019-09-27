
//  Constants.h
//  Seed.iOS
//
//  Created by Rob Stokes on 05/06/2015.
//  Copyright (c) 2015 LimeNinja. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


// API URL
#define BASE_URL "http://139.59.181.88/api/v1/"
#define API_URL BASE_URL


FOUNDATION_EXPORT NSString *const kUserKey;


// Colour Variables

#define getColour(cname) [[Constants sharedInstance] colorFromHexString:cname]


// Default Fonts
#define FONT_LIGHT_XSMALL [UIFont fontWithName:@"TitilliumWeb-Light" size:12]
#define FONT_LIGHT_SMALL [UIFont fontWithName:@"TitilliumWeb-Light" size:14]
#define FONT_LIGHT_NORMAL [UIFont fontWithName:@"TitilliumWeb-Light" size:16]
#define FONT_LIGHT_LARGE [UIFont fontWithName:@"TitilliumWeb-Light" size:24]
#define FONT_LIGHT_XLARGE [UIFont fontWithName:@"TitilliumWeb-Light" size:36]
#define FONT_LIGHT_XXLARGE [UIFont fontWithName:@"TitilliumWeb-Light" size:50]

#define FONT_REGULAR_XSMALL [UIFont fontWithName:@"TitilliumWeb-Regular" size:12]
#define FONT_REGULAR_SMALL [UIFont fontWithName:@"TitilliumWeb-Regular" size:14]
#define FONT_REGULAR_NORMAL [UIFont fontWithName:@"TitilliumWeb-Regular" size:16]
#define FONT_REGULAR_LARGE [UIFont fontWithName:@"TitilliumWeb-Regular" size:24]
#define FONT_REGULAR_XLARGE [UIFont fontWithName:@"TitilliumWeb-Regular" size:36]
#define FONT_REGULAR_XXLARGE [UIFont fontWithName:@"TitilliumWeb-Regular" size:50]

#define FONT_BOLD_XSMALL [UIFont fontWithName:@"TitilliumWeb-Bold" size:12]
#define FONT_BOLD_SMALL [UIFont fontWithName:@"TitilliumWeb-Bold" size:14]
#define FONT_BOLD_NORMAL [UIFont fontWithName:@"TitilliumWeb-Bold" size:16]
#define FONT_BOLD_LARGE [UIFont fontWithName:@"TitilliumWeb-Bold" size:24]
#define FONT_BOLD_XLARGE [UIFont fontWithName:@"TitilliumWeb-Bold" size:36]
#define FONT_BOLD_XXLARGE [UIFont fontWithName:@"TitilliumWeb-Bold" size:50]



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Macros etc

// Colour macros
#define RGB(r, g, b) \
[UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
#define RGBA(r, g, b, a) \
[UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

#define IPad UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad
#define Landscape UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)


@interface Constants : NSObject

@property (nonatomic, strong) UIColor *primary;

+ (id)sharedInstance;

- (void)addValidationTo:(UITextField *)textField withIcon:(UILabel *)icon;
- (BOOL)validateString:(NSString *)string withPattern:(NSString *)pattern;
- (UIColor *)colorFromHexString:(NSString *)hexString;

@end
