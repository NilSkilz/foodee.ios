//
//  ViewController.h
//  Foodee.ios
//
//  Created by Rob Stokes on 25/09/2019.
//  Copyright © 2019 Rob Stokes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <M13ProgressSuite/M13ProgressSuite-umbrella.h>
#import "UIView+Toast.h"

@interface ViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate>

@property(nonatomic, retain) IBOutlet UIView *topView;
@property(nonatomic, retain) IBOutlet UIView *bottomView;
@property(nonatomic, retain) IBOutlet UIView *viewPort;
@property(nonatomic, retain) IBOutlet UIView *captureView;

@property(nonatomic, retain) IBOutlet UIButton *addBtn;
@property(nonatomic, retain) IBOutlet UIButton *minusBtn;

@property(nonatomic, retain) IBOutlet UISegmentedControl *segment;

@property(nonatomic, retain) AVCaptureSession *session;

@property(nonatomic, retain) M13ProgressHUD *HUD;

@property(nonatomic) BOOL consuming;

- (IBAction)addBtnTapped:(id)sender;
- (IBAction)minusBtnTapped:(id)sender;
 
@end

