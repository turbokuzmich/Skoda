//
//  CaptureManager.h
//  Skoda
//
//  Created by Дмитрий Куртеев on 19.03.13.
//  Copyright (c) 2013 Дмитрий Куртеев. All rights reserved.
//

#define kImageSuccessfullyCaptured @"ImageSuccessfullyCaptured"

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef enum {
    CaptureSessionCameraFront = 0,
    CaptureSessionCameraBack
} CaptureSessionCamera;

@interface CaptureSessionManager : NSObject
{
    CaptureSessionCamera _currentCamera;
}

@property (strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (strong) AVCaptureSession *captureSession;
@property (strong) AVCaptureStillImageOutput *stillImageOutput;
@property (strong, nonatomic) UIImage *stillImage;

- (void)addVideoPreviewLayer;
- (void)addBackCamera;
- (void)addFrontCamera;
- (BOOL)frontCameraAvailable;
- (CaptureSessionCamera)currentCamera;
- (void)captureImage;

@end
