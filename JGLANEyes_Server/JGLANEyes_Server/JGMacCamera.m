//
//  JGMacCamera.m
//  JGLANEyes_Server
//
//  Created by mtgao on 2018/5/9.
//  Copyright © 2018年 mtgao. All rights reserved.
//

#import "JGMacCamera.h"


@interface JGMacCamera()<AVCaptureVideoDataOutputSampleBufferDelegate>
{
    AVCaptureSession *_captureSession;
    AVCaptureDevice *_inputCamera;
    AVCaptureDeviceInput *_videoInput;
    AVCaptureVideoDataOutput *_videoOutput;
    AVCaptureVideoPreviewLayer *_preview;
    
    dispatch_queue_t _videoqueue;
}
@end

@implementation JGMacCamera

- (instancetype)initWithPreset:(NSString *)preset{
    //捕捉设备
    _inputCamera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //输入
    _videoInput = [AVCaptureDeviceInput deviceInputWithDevice:_inputCamera error:nil];
    //输出
    _videoOutput = [[AVCaptureVideoDataOutput alloc]init];
    _videoqueue = dispatch_queue_create("com.jimmygao.capturequeue", NULL);
    [_videoOutput setSampleBufferDelegate:self queue:_videoqueue];
    
    //通道配置
    _captureSession = [[AVCaptureSession alloc]init];
    [_captureSession beginConfiguration];
    _captureSession.sessionPreset = preset;
    if([_captureSession canAddInput:_videoInput]){
        [_captureSession addInput:_videoInput];
    }else{
        NSLog(@"error: can't add video input");
    }
    if([_captureSession canAddOutput:_videoOutput]){
        [_captureSession addOutput:_videoOutput];
    }else{
        NSLog(@"error: can't add video output");
    }
    [_captureSession commitConfiguration];
    
    //预览层
    _preview = [[AVCaptureVideoPreviewLayer alloc]initWithSession:_captureSession];
    [_preview setVideoGravity:AVLayerVideoGravityResizeAspect];

    return self;
}

- (void)dealloc{
    [self stopCapture];
    [_videoOutput setSampleBufferDelegate:nil queue:dispatch_get_main_queue()];
    [_captureSession removeInput:_videoInput];
    [_captureSession removeOutput:_videoOutput];
}

- (void)displayOnView:(NSView *)view{
    _preview.frame = view.bounds;
    view.layer = _preview;
}

- (void)startCaptureAndOutputSampleBuffer:(ReturnedSampleBuffer)sampleBuffer{
    
    self.sample = sampleBuffer;
    if(![_captureSession isRunning]){
        [_captureSession startRunning];
    }
}
- (void)stopCapture{
    if([_captureSession isRunning]){
        [_captureSession stopRunning];
    }
}


#pragma mark AVCaptureVideoDataOutputSampleBufferDelegate;
-(void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    
    if(self.sample){
        self.sample(sampleBuffer);
    }
}
@end
