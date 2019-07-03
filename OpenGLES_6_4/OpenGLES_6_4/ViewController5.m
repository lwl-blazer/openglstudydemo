//
//  ViewController5.m
//  OpenGLES_6_4
//
//  Created by luowailin on 2019/7/2.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "ViewController5.h"
#import "AGLKTextureTransformBaseEffect.h"
#import "SceneAnimatedMesh.h"
#import "SceneCanLightModel.h"
#import "AGLKContext.h"

static const GLKVector4 spotLight0Position = {10.0f, 18.0f, -10.0f, 1.0f};
static const GLKVector4 spotLight1Position = {30.0f, 18.0f, -10.0f, 1.0f};
static const GLKVector4 light2Position = {1.0f, 0.5f, 0.0f, 0.0f};

static const int numberOfMovieFrames = 51;
static const int numberOfMovieFramePerRow = 8;
static const int numberOfMovieFramesPerColumn = 8;
static const int numberOfFramesPerSecond = 15;

@interface ViewController5 ()

@property(nonatomic, strong) AGLKTextureTransformBaseEffect *baseEffect;
@property(nonatomic, strong) SceneAnimatedMesh *animatedMesh;
@property(nonatomic, strong) SceneCanLightModel *canLightModel;

@property(nonatomic, assign) GLfloat spotLight0TiltAboutXAngleDeg;
@property(nonatomic, assign) GLfloat spotLight0TiltAboutZAngleDeg;

@property(nonatomic, assign) GLfloat spotLight1TiltAboutXAngleDeg;
@property(nonatomic, assign) GLfloat spotLight1TiltAboutZAngleDeg;

@property(nonatomic, assign) BOOL shouldRipple;

@end

@implementation ViewController5

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]], @"is not a glkview");
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
    self.baseEffect.material.ambientColor = GLKVector4Make(0.8f,
                                                           0.8f,
                                                           0.8f,
                                                           1.0f);
    self.baseEffect.lightModelAmbientColor = GLKVector4Make(0.8f, 0.8f, 0.8f, 1.0f);
    
    self.baseEffect.lightingType = GLKLightingTypePerVertex;
    self.baseEffect.lightModelTwoSided = GL_FALSE;
    self.baseEffect.lightModelAmbientColor = GLKVector4Make(0.6f, 0.6f, 0.6f, 1.0f);
    
    self.baseEffect.light0.enabled = GL_TRUE;
    self.baseEffect.light0.spotExponent = 20.0f;
    self.baseEffect.light0.spotCutoff = 30.0f;
    self.baseEffect.light0.diffuseColor = GLKVector4Make(1.0f, 1.0f, 0.0f, 1.0f);
    self.baseEffect.light0.specularColor = GLKVector4Make(0.0f, 0.0f, 0.0f, 1.0f);
    
    self.baseEffect.light1.enabled = GL_TRUE;
    self.baseEffect.light1.spotExponent = 20.0f;
    self.baseEffect.light1.spotCutoff = 30.0f;
    self.baseEffect.light1.diffuseColor = GLKVector4Make(0.0f, 1.0f, 1.0f, 1.0f);
    self.baseEffect.light1.specularColor = GLKVector4Make(0.0f, 0.0f, 0.0f, 1.0f);
    
    self.baseEffect.light2.enabled = GL_TRUE;
    self.baseEffect.light2Position = light2Position;
    self.baseEffect.light2.diffuseColor = GLKVector4Make(0.5f, 0.5f, 0.5f, 1.0f);
    
    self.baseEffect.material.diffuseColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
    self.baseEffect.material.specularColor = GLKVector4Make(0.0f, 0.0f, 0.0f, 1.0f);
    
    CGImageRef imageRef0 = [[UIImage imageNamed:@"RabbitTextureAtlas.png"] CGImage];
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:imageRef0
                                                               options:nil
                                                                 error:NULL];
    self.baseEffect.texture2d0.name = textureInfo.name;
    self.baseEffect.texture2d0.target = textureInfo.target;
}

- (void)updateSpotLightDirection{
    self.spotLight0TiltAboutXAngleDeg = -20.0f + 30.0f * sinf(self.timeSinceLastResume);
    self.spotLight0TiltAboutZAngleDeg = 30.0f * cosf(self.timeSinceLastResume);
    self.spotLight1TiltAboutXAngleDeg = 20.0f + 30.0f * cosf(self.timeSinceLastResume);
    self.spotLight1TiltAboutZAngleDeg = 30.0f * sinf(self.timeSinceLastResume);
}

//纹理贴图集
- (void)updateTextureTransform{
    //当前播放哪一帧
    int movieFrameNumber = (int)floor(self.timeSinceLastResume * numberOfFramesPerSecond) % numberOfMovieFrames; //floor 向下取整   原理就是用时间秒 乘以 每秒多少帧 取余总共多少帧  得到就是小于或于总共多少帧的数字
  
    //在0.0到1.0范围内的S和T纹理坐标到网格顶点之间。不用对纹理矩阵做任何修改，整个贴图集会被映射到网格几何图形上。但每次只需要渲染一个动画帧覆盖的网格。
    GLfloat currentRowPosition = (movieFrameNumber % numberOfMovieFramePerRow) * 1.0f / numberOfMovieFramePerRow;
    GLfloat currentColumPosition = (movieFrameNumber / numberOfMovieFramesPerColumn) * 1.0f / numberOfMovieFramesPerColumn;
        
    //移动到计算出来的位置
    self.baseEffect.textureMatrix2d0 = GLKMatrix4MakeTranslation(currentRowPosition, currentColumPosition, 0.0f); //首先平移纹理坐标系以使原点{0.0， 0.0}对应于当前动画帧的左下角
    self.baseEffect.textureMatrix2d0 = GLKMatrix4Scale(self.baseEffect.textureMatrix2d0,    //缩放纹理坐标系以使当前帧能够覆盖网格几何体
                                                       1.0f/numberOfMovieFramePerRow,
                                                       1.0f/numberOfMovieFramesPerColumn,
                                                       1.0f);
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
                                                                 0, 0, 1);
    
    self.baseEffect.light0Position = GLKVector4Make(0, 0, 0, 1);
    self.baseEffect.light0SpotDirection = GLKVector3Make(0, -1, 0);
    self.baseEffect.texture2d0.enabled = GL_FALSE;
    
    [self.baseEffect prepareToDrawMultitextures];
    [self.canLightModel draw];
    
    self.baseEffect.transform.modelviewMatrix = savedModelviewMatrix;
}

- (void)drawLight1{
    GLKMatrix4 savedModelviewMatrix = self.baseEffect.transform.modelviewMatrix;
    
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4Translate(savedModelviewMatrix,
                                                                    spotLight1Position.x,
                                                                    spotLight1Position.y,
                                                                    spotLight1Position.z);
    
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4Rotate(self.baseEffect.transform.modelviewMatrix,
                                                                 GLKMathDegreesToRadians(self.spotLight1TiltAboutXAngleDeg),
                                                                 1,
                                                                 0,
                                                                 0);
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4Rotate(self.baseEffect.transform.modelviewMatrix,
                                                                 GLKMathDegreesToRadians(self.spotLight1TiltAboutZAngleDeg),
                                                                 0, 0, 1);
    
    self.baseEffect.light1Position = GLKVector4Make(0, 0, 0, 1);
    self.baseEffect.light1SpotDirection = GLKVector3Make(0, -1, 0);
    self.baseEffect.texture2d0.enabled = GL_FALSE;
    
    [self.baseEffect prepareToDrawMultitextures];
    [self.canLightModel draw];
    
    self.baseEffect.transform.modelviewMatrix = savedModelviewMatrix;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    [self updateSpotLightDirection];
    [self updateTextureTransform];
    
    [((AGLKContext *)view.context) clear:GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT];
    
    const GLfloat aspectRatio = (GLfloat)view.drawableWidth / (GLfloat)view.drawableHeight;
    self.baseEffect.transform.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(80.0f),
                                                                           aspectRatio,
                                                                           0.1f, 255.0f);
    self.baseEffect.transform.projectionMatrix = GLKMatrix4Rotate(self.baseEffect.transform.projectionMatrix,
                                                                  GLKMathDegreesToRadians(-90.0f),
                                                                  0.0f,
                                                                  0.0f,
                                                                  1.0f);
    [self drawLight0];
    [self drawLight1];
    
    if (self.shouldRipple) {
        [self.animatedMesh updateMeshWithElapsedTime:self.timeSinceLastResume];
    }
    
    self.baseEffect.texture2d0.enabled = GL_TRUE;
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

- (IBAction)takeShouldRippleFrom:(UISwitch *)sender{
    self.shouldRipple = [sender isOn];
    if (!self.shouldRipple) {
        [self.animatedMesh updateMeshWithDefaultPositions];
    }
}

@end
