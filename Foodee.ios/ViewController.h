//
//  ViewController.h
//  Foodee.ios
//
//  Created by Rob Stokes on 25/09/2019.
//  Copyright © 2019 Rob Stokes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@interface ViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate>

@property(nonatomic, retain) IBOutlet UIView *topView;
@property(nonatomic, retain) IBOutlet UIView *bottomView;
@property(nonatomic, retain) IBOutlet UIView *viewPort;
@property(nonatomic, retain) IBOutlet UIView *captureView;

@property(nonatomic, retain) AVCaptureSession *session;
 
@end

