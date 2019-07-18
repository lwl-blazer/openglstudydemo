//
//  AGLKViewController.m
//  OpenGLES_5
//
//  Created by luowailin on 2019/6/19.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "AGLKViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AGLKView.h"

@interface AGLKViewController () <AGLKViewDelegate>

@end

@implementation AGLKViewController

static const NSInteger kAGLKDefaultFramesPerSecond = 30;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        displayLink = [CADisplayLink displayLinkWithTarget:self
                                                  selector:@selector(drawView:)];
        
        self.preferredFramesPerSecond = kAGLKDefaultFramesPerSecond;
        
        [displayLink addToRunLoop:[NSRunLoop currentRunLoop]
                          forMode:NSDefaultRunLoopMode];
        
        self.paused = NO;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        displayLink = [CADisplayLink displayLinkWithTarget:self
                                                  selector:@selector(drawView:)];
        
        self.preferredFramesPerSecond = kAGLKDefaultFramesPerSecond;
        
        [displayLink addToRunLoop:[NSRunLoop currentRunLoop]
                          forMode:NSDefaultRunLoopMode];
        
        self.paused = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AGLKView *view = (AGLKView *)self.view;
    NSAssert([view isKindOfClass:[AGLKView class]], @"View controller's view is not a AGLKView");
    
    view.opaque = YES;   //提供渲染质量，但会消耗内存
    view.delegate = self;
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.paused = NO;
}


- (void)drawView:(id)sender{
    [(AGLKView *)self.view display];
}

- (NSInteger)framesPerSecond{
    return 60 / displayLink.preferredFramesPerSecond;
}

- (NSInteger)preferredFramesPerSecond{
    return preferredFramesPerSecond;
}

- (void)setPreferredFramesPerSecond:(NSInteger)apreferredFramesPerSecond{
    preferredFramesPerSecond = apreferredFramesPerSecond;
    displayLink.preferredFramesPerSecond = MAX(1, (60 / apreferredFramesPerSecond));
}

- (BOOL)isPaused{
    return displayLink.paused;
}

- (void)setPaused:(BOOL)paused{
    displayLink.paused = paused;
}

- (void)glkView:(AGLKView *)view drawInRect:(CGRect)rect{
    
}

@end
