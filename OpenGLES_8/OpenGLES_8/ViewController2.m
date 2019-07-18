//
//  ViewController2.m
//  OpenGLES_8
//
//  Created by luowailin on 2019/7/17.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "ViewController2.h"

#import "AGLKContext.h"
#import "AGLKSkyboxEffect.h"
#import "UtilityModelManager.h"
#import "UtilityTextureInfo+viewAdditions.h"
#import "UtilityModel+viewAdditions.h"
#import <OpenGLES/ES3/glext.h>

@interface ViewController2 ()

@property(nonatomic, strong) GLKBaseEffect *baseEffect;
@property(nonatomic, strong) AGLKSkyboxEffect *skyboxEffect;
@property(nonatomic, strong) GLKTextureInfo *textureInfo;

@property(nonatomic, assign, readwrite) GLKVector3 eyePosition;
@property(nonatomic, assign) GLKVector3 lookAtPosition;
@property(nonatomic, assign) GLKVector3 upVector;

@property(nonatomic, assign) float angle;

@property(nonatomic, strong) UtilityModelManager *modelManager;
@property(nonatomic, strong) UtilityModel *boatModel;

@end

@implementation ViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]], @"is not a GLKView");
    
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
    
    self.eyePosition = GLKVector3Make(0.0, 3.0, 3.0);
    self.lookAtPosition = GLKVector3Make(0.0, 0.0, 0.0);
    self.upVector = GLKVector3Make(0.0, 1.0, 0.0);
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"skybox0"
                                                     ofType:@"png"];
    NSAssert(nil != path, @"no png");
    NSError *error = nil;
    self.textureInfo = [GLKTextureLoader cubeMapWithContentsOfFile:path
                                                           options:nil
                                                             error:&error];
    
    self.skyboxEffect = [[AGLKSkyboxEffect alloc] init];
    self.skyboxEffect.textureCubeMap.name = self.textureInfo.name;
    self.skyboxEffect.textureCubeMap.target = self.textureInfo.target;
    
    self.skyboxEffect.xSize = 6.0f;
    self.skyboxEffect.ySize = 6.0f;
    self.skyboxEffect.zSize = 6.0f;
    
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"boat" ofType:@"modelplist"];
    self.modelManager = [[UtilityModelManager alloc] initWithModelPath:modelPath];
    
    self.boatModel = [self.modelManager modelNamed:@"boat"];
    NSAssert(nil != self.boatModel,
             @"Failed to load boat model");
    
    [((AGLKContext *)view.context) enable:GL_CULL_FACE];
}

- (void)preparePointOfViewWithAspectRatio:(GLfloat)aspectRatio{
    self.baseEffect.transform.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(85.0),
                                                                           aspectRatio,
                                                                           0.1f,
                                                                           20.0f);
    
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4MakeLookAt(self.eyePosition.x, self.eyePosition.y, self.eyePosition.z,
                                                                     self.lookAtPosition.x, self.lookAtPosition.y, self.lookAtPosition.z,
                                                                     self.upVector.x, self.upVector.y, self.upVector.z);
    
    
    self.angle += 0.01;
    self.eyePosition = GLKVector3Make(3.0f * sinf(self.angle),
                                      3.0f,
                                      3.0f * cosf(self.angle));
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
    
    self.skyboxEffect.center = self.eyePosition;
    self.skyboxEffect.transform.projectionMatrix = self.baseEffect.transform.projectionMatrix;
    self.skyboxEffect.transform.modelviewMatrix = self.baseEffect.transform.modelviewMatrix;
    
    [self.skyboxEffect prepareToDraw];
    [self.skyboxEffect draw];
    
    glBindVertexArray(0);
    
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


- (void)dealloc{
    self.baseEffect = nil;
    self.skyboxEffect = nil;
    self.textureInfo = nil;
}
@end
