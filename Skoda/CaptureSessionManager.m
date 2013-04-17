//
//  CaptureManager.m
//  Skoda
//
//  Created by Дмитрий Куртеев on 19.03.13.
//  Copyright (c) 2013 Дмитрий Куртеев. All rights reserved.
//

#import "CaptureSessionManager.h"

@interface CaptureSessionManager (Private)

- (void)clearCamera;
- (void)addStillImageOutput;
- (AVCaptureDevice *)frontCameraDevice;

@end

@implementation CaptureSessionManager

@synthesize previewLayer, captureSession, stillImageOutput, stillImage;

- (id)init
{
    self = [super init];
    if (self) {
        _currentCamera = CaptureSessionCameraBack;
        self.captureSession = [[AVCaptureSession alloc] init];
        [self addStillImageOutput];
    }
    return self;
}

- (CaptureSessionCamera)currentCamera
{
    return _currentCamera;
}

- (void)addVideoPreviewLayer {
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
}

- (BOOL)frontCameraAvailable
{
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    BOOL hasFrontCamera = NO;
    for (AVCaptureDevice *device in videoDevices)
    {
        if (device.position == AVCaptureDevicePositionFront)
        {
            hasFrontCamera = YES;
            break;
        }
    }
    
    return hasFrontCamera;
}

- (void)addBackCamera {
    [self clearCamera];
    
	AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
	if (videoDevice) {
        
		NSError *error;
		AVCaptureDeviceInput *videoIn = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
        
		if (!error) {
			if ([self.captureSession canAddInput:videoIn]) {
                _currentCamera = CaptureSessionCameraBack;
				[self.captureSession addInput:videoIn];
            } else {
				NSLog(@"Couldn't add video input");
            }
		} else {
			NSLog(@"Couldn't create video input");
        }
        
	} else {
		NSLog(@"Couldn't create video capture device");
    }
}

- (void)addFrontCamera
{
    [self clearCamera];
    
	AVCaptureDevice *videoDevice = [self frontCameraDevice];
    
	if (videoDevice) {
        
		NSError *error;
		AVCaptureDeviceInput *videoIn = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
        
		if (!error) {
			if ([self.captureSession canAddInput:videoIn]) {
                _currentCamera = CaptureSessionCameraFront;
				[self.captureSession addInput:videoIn];
            } else {
				NSLog(@"Couldn't add video input");
            }
		} else {
			NSLog(@"Couldn't create video input");
        }
        
	} else {
		NSLog(@"Couldn't create video capture device");
    }
}

- (void)captureImage
{
    AVCaptureConnection *videoConnection = nil;
	for (AVCaptureConnection *connection in [self.stillImageOutput connections]) {
		for (AVCaptureInputPort *port in [connection inputPorts]) {
			if ([port.mediaType isEqual:AVMediaTypeVideo]) {
				videoConnection = connection;
				break;
			}
		}
		if (videoConnection) {
            break;
        }
	}
    
    if (videoConnection) {
        [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection
                                                           completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                                                               NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                                                               self.stillImage = [[UIImage alloc] initWithData:imageData];
                                                               
                                                               [[NSNotificationCenter defaultCenter] postNotificationName:kImageSuccessfullyCaptured object:self];
                                                           }];
    }
}

@end

@implementation CaptureSessionManager (Private)

- (void)clearCamera
{
    NSArray *currentInputs = self.captureSession.inputs;
    
    for (AVCaptureDeviceInput *i in currentInputs) {
        [self.captureSession removeInput:i];
    }
}

- (void)addStillImageOutput
{
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey,nil];
    [self.stillImageOutput setOutputSettings:outputSettings];
    [self.captureSession addOutput:self.stillImageOutput];
}

- (AVCaptureDevice *)frontCameraDevice
{
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *frontCamera = nil;
    for (AVCaptureDevice *device in videoDevices)
    {
        if (device.position == AVCaptureDevicePositionFront)
        {
            frontCamera = device;
            break;
        }
    }
    
    return frontCamera;
}

@end
