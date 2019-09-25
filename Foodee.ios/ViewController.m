//
//  ViewController.m
//  Foodee.ios
//
//  Created by Rob Stokes on 25/09/2019.
//  Copyright © 2019 Rob Stokes. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupScanner];
    [self addStyling];
    
}

- (void) addStyling {
    UIColor *dark = [UIColor colorWithRed:(45/255) green:(52/255) blue:(69/255) alpha:1];
    self.topView.backgroundColor = dark;
    self.topView.layer.opacity = 0.8;
    
    self.bottomView.backgroundColor = dark;
    self.bottomView.layer.opacity = 0.8;
    
    self.viewPort.backgroundColor = [UIColor clearColor];
    self.captureView.backgroundColor = [UIColor clearColor];
    
    CAShapeLayer *yourViewBorder = [CAShapeLayer layer];
    yourViewBorder.strokeColor = [UIColor blackColor].CGColor;
    yourViewBorder.fillColor = nil;
    yourViewBorder.lineWidth = 4;
    yourViewBorder.lineDashPattern = @[@70, @40];
    yourViewBorder.frame = self.captureView.bounds;
    yourViewBorder.path = [UIBezierPath bezierPathWithRect:self.captureView.bounds].CGPath;
    [self.captureView.layer addSublayer:yourViewBorder];

}

- (void) setupScanner
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    
    self.session = [[AVCaptureSession alloc] init];
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    [_session addOutput:output];
    [_session addInput:input];

    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    output.metadataObjectTypes = @[AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code];

    AVCaptureVideoPreviewLayer *preview = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    preview.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);

    AVCaptureConnection *con = preview.connection;

    con.videoOrientation = AVCaptureVideoOrientationPortrait;
    
    [self.view.layer insertSublayer:preview atIndex:0];
    
     [_session startRunning];
}

- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    [_session stopRunning];
    AVMetadataMachineReadableCodeObject *obj = metadataObjects.firstObject;
    NSLog(obj.stringValue);
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Got One!" message:obj.stringValue preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cool" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [_session startRunning];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}


@end
