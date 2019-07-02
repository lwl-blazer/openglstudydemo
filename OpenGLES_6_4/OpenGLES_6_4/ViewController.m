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
    
    CGImageRef imageRef0 = [[UIImage imageNamed:@"RadiusSelectionTool.png"] CGImage];
    GLKTextureInfo *textInfo = [GLKTextureLoader textureWithCGImage:imageRef0 options:nil error:NULL];
    
    self.baseEffect.texture2d0.name = textInfo.name;
    self.baseEffect.texture2d0.target = textInfo.target;
    
}

- (void)updateSpotLightDirections{
    self.spotLight0TiltAboutXAngleDeg = -20.0f + 30.0f * sinf(self.timeSinceLastResume);
    self.spotLight0TiltAboutZAngleDeg = 30.0f * cosf(self.timeSinceLastResume);
    self.spotLight1TiltAboutXAngleDeg = 20.0f + 30.0f * cosf(self.timeSinceLastResume);
    self.spotLight1TiltAboutZAngleDeg = 30.0f * sinf(self.timeSinceLastResume);
}

//随着时间变换model-view坐标系会让渲染对象看起来像是相对于视点移动,反之亦然。随着时间改变纹理坐标系可以动画几何体的纹理映射过程
- (void)updateTextureTransform{
    //基于逝去的时间旋转纹理坐标系来，旋转纹理坐标，纹理坐标系会分别沿着S轴和T轴从0.0跨度到1.0。 围绕纹理中心旋转
    
    self.baseEffect.textureMatrix2d0 = GLKMatrix4MakeTranslation(0.5, 0.5, 0.0); //先平移到{0.5, 0.5}
    self.baseEffect.textureMatrix2d0 = GLKMatrix4Rotate(self.baseEffect.textureMatrix2d0, //然后旋转
                                                        -self.timeSinceLastResume,
                                                        0,
                                                        0,
                                                        1);
    self.baseEffect.textureMatrix2d0 = GLKMatrix4Translate(self.baseEffect.textureMatrix2d0, //再平移回{-0.5,-0.5}
                                                           -0.5f,
                                                           -0.5f,
                                                           0);
}

- (void)update{
    [self updateSpotLightDirections];
    [self updateTextureTransform];
}

- (void)drawLight0{
    GLKMatrix4 saveModelviewMatrix = self.baseEffect.transform.modelviewMatrix;
    
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4Translate(saveModelviewMatrix,
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
    self.baseEffect.texture2d0.enabled = GL_FALSE;
    self.baseEffect.texture2d1.enabled = GL_FALSE;
    
    [self.baseEffect prepareToDrawMultitextures];
    [self.canLightModel draw];
    
    self.baseEffect.transform.modelviewMatrix = saveModelviewMatrix;
}

- (void)drawLight1{
    GLKMatrix4 saveModelviewMatrix = self.baseEffect.transform.modelviewMatrix;
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4Translate(saveModelviewMatrix,
                                                                    spotLight1Position.x,
                                                                    spotLight1Position.y,
                                                                    spotLight1Position.z);
    
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4Rotate(self.baseEffect.transform.modelviewMatrix,
                                                                 GLKMathDegreesToRadians(self.spotLight1TiltAboutXAngleDeg),
                                                                 1,
                                                                 0,
                                                                 0);
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4Rotate(self.baseEffect.transform.modelviewMatrix,
                                                                 GLKMathDegreesToRadians(self.spotLight0TiltAboutZAngleDeg),
                                                                 0, 0, 1);
    
    self.baseEffect.light1Position = GLKVector4Make(0, 0, 0, 1);
    self.baseEffect.light1SpotDirection = GLKVector3Make(0, -1, 0);
    self.baseEffect.texture2d0.enabled = GL_FALSE;
    self.baseEffect.texture2d1.enabled = GL_FALSE;
    
    [self.baseEffect prepareToDrawMultitextures];
    [self.canLightModel draw];
    
    self.baseEffect.transform.modelviewMatrix = saveModelviewMatrix;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    [((AGLKContext *)view.context) clear:GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT];
    
    const GLfloat aspectRatio = (GLfloat)view.drawableWidth / (GLfloat)view.drawableHeight;
    
    self.baseEffect.transform.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(60.0f),
                                                                           aspectRatio,
                                                                           0.1f,
                                                                           255.0f);
    
    [self drawLight0];
    [self drawLight1];
    
    [self.animatedMesh updateMeshWithElapsedTime:self.timeSinceLastResume];
    self.baseEffect.texture2d0.enabled = GL_TRUE;
    self.baseEffect.texture2d1.enabled = GL_FALSE;
    
    [self.baseEffect prepareToDrawMultitextures];
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
