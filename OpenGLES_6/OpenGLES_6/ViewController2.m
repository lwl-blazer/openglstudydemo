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
    
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.light0.enabled = GL_TRUE;
    self.baseEffect.light0.ambientColor = GLKVector4Make(0.6f,
                                                         0.6f,
                                                         0.6f,
                                                         1.0f);
    self.baseEffect.light0.diffuseColor = GLKVector4Make(1.0f,
                                                         1.0f,
                                                         1.0f,
                                                         1.0f);
    self.baseEffect.light0.position = GLKVector4Make(1.0f,
                                                     0.8f,
                                                     0.4f,
                                                     0.0);
    
    ((AGLKContext *)view.context).clearColor = GLKVector4Make(0.0f,
                                                              0.0f,
                                                              0.0f,
                                                              1.0f);
    
    self.animateMesh = [[SceneAnimatedMesh alloc] init];
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4MakeLookAt(20, 25, 5,
                                                                     20, 0, -15,
                                                                     0, 1, 0);
    [((AGLKContext *)view.context) enable:GL_DEPTH_TEST];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    [((AGLKContext *)view.context) clear:GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT];
    
    const GLfloat aspectRatio = (GLfloat)view.drawableWidth / (GLfloat)view.drawableHeight;
    
    self.baseEffect.transform.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(60.0f),
                                                                           aspectRatio,
                                                                           0.1f,
                                                                           255.0f);
    
    [self.animateMesh updateMeshWithElapsedTime:self.timeSinceLastResume];   //timeSinceLastResume 最后一次发送更新消息后的时间
    
    [self.baseEffect prepareToDraw];
    [self.animateMesh prepareToDraw];
    [self.animateMesh drawEntireMesh];
}

- (void)dealloc{
    GLKView *view = (GLKView *)self.view;
    [AGLKContext setCurrentContext:view.context];
    
    [EAGLContext setCurrentContext:nil];
    
    self.baseEffect = nil;
    self.animateMesh = nil;
}


@end
