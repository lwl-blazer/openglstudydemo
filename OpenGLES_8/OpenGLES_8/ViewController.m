//
//  ViewController.m
//  OpenGLES_8
//
//  Created by luowailin on 2019/7/16.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "ViewController.h"
#import "AGLKContext.h"
#import "UtilityModel+viewAdditions.h"
#import "UtilityModelManager.h"
#import "UtilityTextureInfo+viewAdditions.h"

@interface ViewController ()

@property(nonatomic, strong) GLKBaseEffect *baseEffect;
@property(nonatomic, strong) GLKSkyboxEffect *skyboxEffect;
@property(nonatomic, strong) GLKTextureInfo *textureInfo;

@property(nonatomic, assign, readwrite) GLKVector3 eyePosition;
@property(nonatomic, assign) GLKVector3 lookAtPosition;
@property(nonatomic, assign) GLKVector3 upVector;
@property(nonatomic, assign) GLfloat angle;

@property(nonatomic, strong) UtilityModelManager *modelManager;
@property(nonatomic, strong) UtilityModel *boatModel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]], @"not a GLKView");
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    view.context = [[AGLKContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    [EAGLContext setCurrentContext:view.context];
    
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.light0.enabled = GL_TRUE;
    self.baseEffect.light0.ambientColor = GLKVector4Make(0.9f,
                                                         0.9f,
                                                         0.9f,
                                                         1.0f);
    self.baseEffect.light0.diffuseColor = GLKVector4Make(1.0f,
                                                         1.0f,
                                                         1.0f,
                                                         1.0f);
    
    self.eyePosition = GLKVector3Make(0.0, 3.0, 0.0);
    self.lookAtPosition = GLKVector3Make(0.0, 0.0, 0.0);
    self.upVector = GLKVector3Make(0.0, 1.0, 0.0);
    
    /** 立方体贴图
     * 是指将多个纹理组合起来映射到一张纹理上的一种纹理类型
     *
     * 立方体贴图就是一个包含了6个2D纹理的纹理，每个2D纹理都组成了立方体的一个面；
     * 立方体贴图有一个非常有用的特性，它可以通过一个方向向量来进行索引和采样
     */
    NSString *path = [[NSBundle mainBundle] pathForResource:@"skybox0" ofType:@"png"];
    NSAssert(nil != path, @"Path to skybox image not found");
    NSError *error = nil;
    self.textureInfo = [GLKTextureLoader cubeMapWithContentsOfFile:path
                                                           options:nil
                                                             error:&error];
    
    self.skyboxEffect = [[GLKSkyboxEffect alloc] init];
    self.skyboxEffect.textureCubeMap.name = self.textureInfo.name;
    self.skyboxEffect.textureCubeMap.target = self.textureInfo.target;
    self.skyboxEffect.xSize = 6.0f;
    self.skyboxEffect.ySize = 6.0f;
    self.skyboxEffect.zSize = 6.0f;
    
    
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"boat"
                                                          ofType:@"modelplist"];
    self.modelManager = [[UtilityModelManager alloc] initWithModelPath:modelPath];
    self.boatModel = [self.modelManager modelNamed:@"boat"];
    NSAssert(nil != self.boatModel, @"Failed to load boat model");
    
    [((AGLKContext *)view.context) enable:GL_CULL_FACE];
}

- (void)dealloc{
    [EAGLContext setCurrentContext:nil];
    self.baseEffect = nil;
    self.skyboxEffect = nil;
    self.textureInfo = nil;
}

- (void)preparePointOfViewWithAspectRatio:(GLfloat)aspectRatio{
    self.baseEffect.transform.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(85.0),
                                                                           aspectRatio,
                                                                           0.1f,
                                                                           20.0f);
    
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4MakeLookAt(self.eyePosition.x,
                                                                     self.eyePosition.y, self.eyePosition.z,
                                                                     self.lookAtPosition.x,
                                                                     self.lookAtPosition.y,
                                                                     self.lookAtPosition.z,
                                                                     self.upVector.x,
                                                                     self.upVector.y,
                                                                     self.upVector.z);
    
    self.angle += 0.01;
    self.eyePosition = GLKVector3Make(3.0f * sinf(_angle),
                                      3.0f,
                                      3.0f * cosf(_angle));
    self.lookAtPosition = GLKVector3Make(0.0,
                                         1.5 + 3.0f * sinf(0.3 * self.angle),
                                         0.0);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    const GLfloat aspectRatio = (GLfloat)view.drawableWidth / (GLfloat)view.drawableHeight;
    [(AGLKContext *)view.context clear:GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT];
    
    [self preparePointOfViewWithAspectRatio:aspectRatio];
    
    self.baseEffect.light0.position = GLKVector4Make(0.4f,
                                                     0.4f,
                                                     -0.3f,
                                                     0.0f);
    
    
   //天空盒的中心要在绘图前设定，并且必须要尽量靠近用于设置视点的眼睛位置。如果眼睛的位置太接近天空盒立方体的边缘，那么由此产生的的效果拉伸会损坏最终的渲染效果
    self.skyboxEffect.center = self.eyePosition;
    self.skyboxEffect.transform.projectionMatrix = self.baseEffect.transform.projectionMatrix;
    self.skyboxEffect.transform.modelviewMatrix = self.baseEffect.transform.modelviewMatrix;
    
    [self.skyboxEffect prepareToDraw];
    [self.skyboxEffect draw];
    
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    [self.modelManager prepareToDraw];
    [self.baseEffect prepareToDraw];
    [self.boatModel draw];
    
#ifdef DEBUG
    {  // Report any errors
        GLenum error = glGetError();
        if(GL_NO_ERROR != error)
        {
            NSLog(@"GL Error: 0x%x", error);
        }
    }
#endif
}

@end

/**
 * 与天空盒类似，还有一个效果叫做环境贴图(environment map)，又叫做反射贴图(reflection map),使用它可能容易模拟镜面和类似水面的其他反射面。
 *
 * GLKit包含GLKReflectionMapEffect类，你的应用会像GLKBaseEffect实例一样配置关于镜面反射的属性，并且会多设置一个属性-----textureMap.
 
 * 渲染反射和渲染天空盒的操作相同。两种情况下都是使用方向来取样纹理的。对于天空盒，这个方向是从观察者到包裹立方体的面，对于环境贴图，这个方向是反射面到包裹立方体的面
 */
