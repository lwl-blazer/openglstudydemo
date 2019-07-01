//
//  ViewController3.m
//  OpenGLES_6
//
//  Created by luowailin on 2019/6/28.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "ViewController3.h"
#import "AGLKTextureTransformBaseEffect.h"
#import "SceneAnimatedMesh.h"
#import "SceneCanLightModel.h"
#import "AGLKContext.h"


static const GLKVector4 spotLight0Position = {10.0f, 18.0f, -10.0f, 1.0f};
static const GLKVector4 spotLight1Position = {30.0f, 18.0f, -10.0f, 1.0f};
static const GLKVector4 light2Position = {1.0f, 0.5f, 0.0f, 0.0f}; //定向光的位置是最后一个元素设置为0.0的一个四元素矢量 light2Position会被初始化为矢量{0.0f, 0.5f, 1.0f, 0.0f} 这个位置表示这个定向光照射自一个无限远的光源

@interface ViewController3 ()

@property(nonatomic, strong) AGLKTextureTransformBaseEffect *baseEffect;
@property(nonatomic, strong) SceneAnimatedMesh *animatedMesh;
@property(nonatomic, strong) SceneCanLightModel *canLightModel;

@property(nonatomic, assign) GLfloat spotLight0TiltAboutXAngleDeg;
@property(nonatomic, assign) GLfloat spotLight0TiltAboutZAngleDeg;

@property(nonatomic, assign) GLfloat spotLight1TiltAboutXAngleDeg;
@property(nonatomic, assign) GLfloat spotLight1TiltAboutZAngleDeg;

@end

@implementation ViewController3

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]], @"is not GLKView");
    
    view.context = [[AGLKContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    view.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    [AGLKContext setCurrentContext:view.context];
    
    //GLKit的GLKBaseEffect和GLKEffectPropertyLight类一起实现了聚光灯。GLKit提供了两个不同的OpenGL ES灯光实现方式。设置GLKBaseEffect的LightType属性为GLKLightingTypePerVertex会告诉GLKit去计算在几何图形中的每个顶点的光线值，并在顶点之间插值。设置lightingType为GLKLightingTypePerPixel会产生一个更高质量的渲染结果，但这需要为每个片元重新计算光线效果，而这比每顶点计算要耗费更多的GPU计算量。不为聚光灯做片元计算，光照范围的边缘就会出现锯齿
    self.baseEffect = [[AGLKTextureTransformBaseEffect alloc] init];
    self.baseEffect.lightingType = GLKLightingTypePerPixel;
    self.baseEffect.lightModelTwoSided = GL_FALSE; //是否开启双面灯光
    self.baseEffect.lightModelAmbientColor = GLKVector4Make(0.6f,
                                                            0.6f,
                                                            0.6f,
                                                            1.0f);
    
    ((AGLKContext *)view.context).clearColor = GLKVector4Make(0.0,
                                                              0.0,
                                                              0.0,
                                                              1.0);
    self.animatedMesh = [[SceneAnimatedMesh alloc] init];
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4MakeLookAt(20, 25, 5,
                                                                     20, 0, -15,
                                                                     0, 1, 0);
    glEnable(GL_DEPTH_TEST);
    
    self.canLightModel = [[SceneCanLightModel alloc] init];
    self.baseEffect.material.ambientColor = GLKVector4Make(0.4f, 0.4f, 0.4f, 1.0f);
    self.baseEffect.lightModelAmbientColor = GLKVector4Make(0.4f, 0.4f, 0.4f, 1.0f);
    
    //Light0为聚光灯
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
    
    //Light1为聚光灯
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
    //Light2是定向光
    self.baseEffect.light2.enabled = GL_TRUE;
    self.baseEffect.light2Position = light2Position;
    self.baseEffect.light2.diffuseColor = GLKVector4Make(0.5f,
                                                         0.5f,
                                                         0.5f,
                                                         1.0f);
    
    //材质
    self.baseEffect.material.diffuseColor = GLKVector4Make(1.0f,
                                                           1.0f,
                                                           1.0f,
                                                           1.0f);
    self.baseEffect.material.specularColor = GLKVector4Make(0.0f,
                                                            0.0f,
                                                            0.0f,
                                                            1.0f);
}

//聚光灯的位置和方向并不是预先指定的。按照惯例，OpenGL会使用当前(实际上是设置位置和方向时)的model-view矩阵来变换位置光源的位置和方向。因此，每当灯光坐标系变化时必须重新设置位置和方向
- (void)updateSpotLightDirections{
    
    self.spotLight0TiltAboutXAngleDeg = -20.0f + 30.0f * sinf(self.timeSinceLastResume);
    
    self.spotLight0TiltAboutZAngleDeg = 30.0f + cosf(self.timeSinceLastResume);
    
    self.spotLight1TiltAboutXAngleDeg = 20.0f + 30.0f * cosf(self.timeSinceLastResume);
    
    self.spotLight1TiltAboutZAngleDeg = 30.0f * sinf(self.timeSinceLastResume);
}

- (void)update{
    [self updateSpotLightDirections];
}


- (void)drawLight0{
    GLKMatrix4 savedModelviewMatrix = self.baseEffect.transform.modelviewMatrix;
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4Translate(savedModelviewMatrix,
                                                                    spotLight0Position.x,
                                                                    spotLight0Position.y,
                                                                    spotLight0Position.z);
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4Rotate(self.baseEffect.transform.modelviewMatrix,
                                                                 GLKMathDegreesToRadians(self.spotLight0TiltAboutXAngleDeg),
                                                                 1,
                                                                 0,
                                                                 0);
    
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4Rotate(self.baseEffect.transform.modelviewMatrix,
                                                                 GLKMathDegreesToRadians(self.spotLight0TiltAboutZAngleDeg),
                                                                 0,
                                                                 0,
                                                                 1);
    
    self.baseEffect.light0Position = GLKVector4Make(0, 0, 0, 1);
    self.baseEffect.light0SpotDirection = GLKVector3Make(0, -1, 0);
    
    [self.baseEffect prepareToDraw];
    [self.canLightModel draw];
    
    self.baseEffect.transform.modelviewMatrix = savedModelviewMatrix;
}

- (void)drawLight1{
    GLKMatrix4 savedModelViewMatrix = self.baseEffect.transform.modelviewMatrix;
    
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4Translate(savedModelViewMatrix,
                                                                    spotLight1Position.x,
                                                                    spotLight1Position.y,
                                                                    spotLight1Position.z);
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4Rotate(self.baseEffect.transform.modelviewMatrix,
                                                                 GLKMathDegreesToRadians(self.spotLight1TiltAboutXAngleDeg),
                                                                 1, 0, 0);
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4Rotate(self.baseEffect.transform.modelviewMatrix,
                                                                 GLKMathDegreesToRadians(self.spotLight1TiltAboutZAngleDeg),
                                                                 0, 0, 1);
    
    self.baseEffect.light1Position = GLKVector4Make(0, 0, 0, 1);
    self.baseEffect.light1SpotDirection = GLKVector3Make(0, -1, 0);
    
    [self.baseEffect prepareToDraw];
    [self.canLightModel draw];
    
    self.baseEffect.transform.modelviewMatrix = savedModelViewMatrix;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    [((AGLKContext *)view.context) clear:GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT];
    
    const GLfloat aspectRatio = (GLfloat)view.drawableWidth / (GLfloat)view.drawableHeight;
    self.baseEffect.transform.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(60.0),
                                                                           aspectRatio,
                                                                           0.1f,
                                                                           255.0);
    
    [self drawLight0];
    [self drawLight1];
    
    [self.animatedMesh updateMeshWithElapsedTime:self.timeSinceLastResume];
    
    [self.baseEffect prepareToDraw];
    [self.animatedMesh prepareToDraw];
    [self.animatedMesh drawEntireMesh];
}

- (void)dealloc{
    GLKView *view = (GLKView *)self.view;
    [AGLKContext setCurrentContext:view.context];
    
    [EAGLContext setCurrentContext:nil];
    
    self.animatedMesh = nil;
    self.canLightModel = nil;
}

@end
