//
//  ViewController.m
//  Foodee.ios
//
//  Created by Rob Stokes on 25/09/2019.
//  Copyright © 2019 Rob Stokes. All rights reserved.
//

#import "ViewController.h"
#import "DataManager.h"
#import "Constants.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupScanner];
    [self addStyling];
    [self addBtnTapped:self];
    
    
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
    
    NSLog(@"%@, ", [NSString stringWithFormat:@"Barcode %@", obj.stringValue]);
    [self.viewPort makeToastActivity:CSToastPositionCenter];
//    [self.HUD performAction:M13ProgressViewActionNone animated:YES];
//     [self.HUD setPrimaryColor:PRIMARY_COLOR];
//    [self.HUD show:YES];
    
    DataManager *dataManager = [DataManager sharedManager];
    
    if (self.consuming) {
        switch (self.segment.selectedSegmentIndex) {
            case 0:
            {
                [dataManager consumeOneWithBarcode:obj.stringValue withSuccess:^(Product *product) {
                    [self resume];
                } failure:^(NSError *error) {
                     [self resume];
                }];
            }
                break;
            case 1:
            {
               [dataManager consumeAllWithBarcode:obj.stringValue withSuccess:^(Product *product) {
                    [self resume];
               } failure:^(NSError *error) {
                   [self resume];
               }];
            }
               break;
            case 2:
            {
               [dataManager markSpoiledWithBarcode:obj.stringValue withSuccess:^(Product *product) {
                    [self resume];
               } failure:^(NSError *error) {
                  [self resume];
               }];
            }
               break;
            default:
                break;
        }
        
    } else {
        [dataManager addProductWithBarcode:obj.stringValue withSuccess:^(Product *product) {
            if (product.name) {
               [self resume];
                
                [self.viewPort makeToast:[NSString stringWithFormat:@"Added 1 x %@", product.name]
                duration:3.0
                position:CSToastPositionBottom];
                
            } else {
               [self resume];
                
                [self.viewPort makeToast:[NSString stringWithFormat:@"Product not found"]
                duration:3.0
                position:CSToastPositionBottom];
                
            }
           } failure:^(NSError *error) {
               [self resume];
           }];
    }
}

- (void)resume {
    [self.viewPort hideToastActivity];
    [self.session startRunning];
}


- (void)addBtnTapped:(id)sender {
    NSLog(@"Add Tapped");
     self.consuming = false;
    _addBtn.imageView.image = [UIImage imageNamed:@"plus-selected.png"];
    _minusBtn.imageView.image = [UIImage imageNamed:@"minus.png"];
    _segment.hidden = YES;
}

- (void)minusBtnTapped:(id)sender {
    NSLog(@"Minus Tapped");
    self.consuming = true;
    _minusBtn.imageView.image = [UIImage imageNamed:@"minus-selected.png"];
    _addBtn.imageView.image = [UIImage imageNamed:@"plus.png"];
    _segment.hidden = NO;
}

@end
