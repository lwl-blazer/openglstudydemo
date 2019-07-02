//
//  ViewController.m
//  OpenGLES_6_4
//
//  Created by luowailin on 2019/7/1.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "ViewController.h"
#import "AGLKTextureTransformBaseEffect.h"
#import "SceneAnimatedMesh.h"
#import "SceneCanLightModel.h"

#import "AGLKContext.h"

static const GLKVector4 spotLight0Position = {10.0f, 18.0f, -10.0f, 1.0f};
static const GLKVector4 spotLight1Position = {30.0f, 18.0f, -10.0f, 1.0f};
static const GLKVector4 light2Position = {1.0f, 0.5f, 0.0f, 0.0f};

@interface ViewController ()

@property(nonatomic, strong) AGLKTextureTransformBaseEffect *baseEffect;
@property(nonatomic, strong) SceneAnimatedMesh *animatedMesh;
@property(nonatomic, strong) SceneCanLightModel *canLightModel;
@property(nonatomic, assign) GLfloat spotLight0TiltAboutXAngleDeg;
@property(nonatomic, assign) GLfloat spotLight0TiltAboutZAngleDeg;
@property(nonatomic, assign) GLfloat spotLight1TiltAboutXAngleDeg;
@property(nonatomic, assign) GLfloat spotLight1TiltAboutZAngleDeg;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]], @"view controller is not a GLKView");
    view.context = [[AGLKContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    view.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    [AGLKContext setCurrentContext:view.context];
    
    self.baseEffect = [[AGLKTextureTransformBaseEffect alloc] init];
    ((AGLKContext *)view.context).clearColor = GLKVector4Make(0.0f,
                                                              0.0f,
                                                              0.0f,
                                                              1.0f);
    
    self.animatedMesh = [[SceneAnimatedMesh alloc] init];
    
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4MakeLookAt(20, 25, 5,
                                                                     20, 0, -15,
                                                                     0, 1, 0);
    [((AGLKContext *)view.context) enable:GL_DEPTH_TEST];
    [((AGLKContext *)view.context) enable:GL_BLEND];
    
    self.canLightModel = [[SceneCanLightModel alloc] init];
    
    self.baseEffect.material.ambientColor = GLKVector4Make(0.1f,
                                                           0.1f,
                                                           0.1f,
                                                           1.0f);
    self.baseEffect.lightModelAmbientColor = GLKVector4Make(0.1f,
                                                            0.1f,
                                                            0.1f,
                                                            1.0f);
    
    self.baseEffect.lightingType = GLKLightingTypePerVertex;
    self.baseEffect.lightModelTwoSided = GL_FALSE;
    self.baseEffect.lightModelAmbientColor = GLKVector4Make(0.6f,
                                                            0.6f,
                                                            0.6f,
                                                            1.0f);
    
    
    self.baseEffect.light0.enabled = GL_TRUE;
    self.baseEffect.light0.spotExponent = 20.0f;
    self.baseEffect.light0.spotCutoff = 30.0f;
    self.baseEffect.light0.diffuseColor = GLKVector4Make(1.0f,
                                                         1.0f,
                                                         0.0f,
                                                         1.0f);
    self.baseEffect.light0.specularColor = GLKVector4Make(0.0f,
                                                          0.0f,
                                                          0.0f,
                                                          1.0f);
    
    self.baseEffect.light1.enabled = GL_TRUE;
    self.baseEffect.light1.spotExponent = 20.0f;
    self.baseEffect.light1.spotCutoff = 30.0f;
    self.baseEffect.light1.diffuseColor = GLKVector4Make(0.0f,
                                                         1.0f,
                                                         1.0f,
                                                         1.0f);
    self.baseEffect.light1.specularColor = GLKVector4Make(0.0f,
                                                          0.0f,
                                                          0.0f,
                                                          1.0f);
    
    self.baseEffect.light2.enabled = GL_TRUE;
    self.baseEffect.light2Position = light2Position;
    self.baseEffect.light2.diffuseColor = GLKVector4Make(0.5f,
                                                         0.5f,
                                                         0.5f,
                                                         1.0f);
    
    self.baseEffect.material.diffuseColor = GLKVector4Make(1.0f,
                                                           1.0f,
                                                           1.0f,
                                                           1.0f);
    self.baseEffect.material.specularColor = GLKVector4Make(0.0f,
                                                            0.0f,
                                                            0.0f,
                                                            1.0f);
    
    CGImageRef imageRef0 = [[UIImage imageNamed:@""] CGImage];
    GLKTextureInfo *textInfo = [GLKTextureLoader textureWithCGImage:imageRef0 options:nil error:NULL];
    
    self.baseEffect.texture2d0.name = textInfo.name;
    self.baseEffect.texture2d0.target = textInfo.target;
    
}


@end
