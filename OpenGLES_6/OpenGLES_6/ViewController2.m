//
//  ViewController2.m
//  OpenGLES_6
//
//  Created by luowailin on 2019/6/27.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "ViewController2.h"
#import "AGLKContext.h"
#import "SceneAnimatedMesh.h"

@interface ViewController2 ()

@property(nonatomic, strong) GLKBaseEffect *baseEffect;
@property(nonatomic, strong) SceneAnimatedMesh *animateMesh;

@end

@implementation ViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]], @"view controller is not a GLKView");
    
    view.context = [[AGLKContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    view.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    
    [AGLKContext setCurrentContext:view.context];
    
    
}



@end
