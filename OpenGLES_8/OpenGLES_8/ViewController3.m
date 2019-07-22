//
//  ViewController3.m
//  OpenGLES_8
//
//  Created by luowailin on 2019/7/18.
//  Copyright © 2019 luowailin. All rights reserved.
//
/**
 * 本实例的缺陷，在某此粒子上出现的黑色轮廓的可视瑕疵，这些瑕疵是由粒子渲染的顺序导致的。每个粒子都会与像素颜色渲染缓存中的现存的内容相融合。
 *
 * 涉及的重点是无法排序顶点，顶点通常是按顺序提交给GPU的
 
 */
#import "ViewController3.h"
#import "AGLKContext.h"
#import "AGLKPointParticleEffect.h"

@interface ViewController3 ()

@property(nonatomic, strong) GLKBaseEffect *baseEffect;
@property(nonatomic, strong) AGLKPointParticleEffect *particleEffect;

@property(nonatomic, assign) NSTimeInterval autoSpawnDelta;
@property(nonatomic, assign) NSTimeInterval lastSpawnTime;
@property(nonatomic, assign) NSInteger currentEmitterIndex;
@property(nonatomic, strong) NSArray *emitterBlocks;

@property(nonatomic, strong) GLKTextureInfo *ballParticleTexture;
@property(nonatomic, strong) GLKTextureInfo *burstParticleTexture;
@property(nonatomic, strong) GLKTextureInfo *smokeParticleTexture;

@end

@implementation ViewController3

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]], @"is not a glkview");
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
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ball"
                                                     ofType:@"png"];
    NSAssert(path != nil, @"ball texture not found");
    NSError *error = nil;
    self.ballParticleTexture = [GLKTextureLoader textureWithContentsOfFile:path
                                                                   options:nil
                                                                     error:&error];
    
    path = [[NSBundle mainBundle] pathForResource:@"burst"
                                           ofType:@"png"];
    NSAssert(path != nil, @"burst texture not found");
    self.burstParticleTexture = [GLKTextureLoader textureWithContentsOfFile:path
                                                                    options:nil
                                                                      error:&error];
    
    path = [[NSBundle mainBundle] pathForResource:@"smoke"
                                           ofType:@"png"];
    NSAssert(path != nil, @"smoke texture not found");
    self.smokeParticleTexture = [GLKTextureLoader textureWithContentsOfFile:path
                                                                    options:nil
                                                                      error:&error];
    
    self.particleEffect = [[AGLKPointParticleEffect alloc] init];
    self.particleEffect.texture2d0.name = self.ballParticleTexture.name;
    self.particleEffect.texture2d0.target = self.ballParticleTexture.target;
    
    [(AGLKContext *)view.context setClearColor:GLKVector4Make(0.2f,
                                                              0.2f,
                                                              0.2f,
                                                              1.0f)];
    [(AGLKContext *)view.context enable:GL_DEPTH_TEST];
    [(AGLKContext *)view.context enable:GL_BLEND];
    [(AGLKContext *)view.context setBlendSourceFunction:GL_SRC_ALPHA
                                    destinationFunction:GL_ONE_MINUS_SRC_ALPHA];
    
    self.autoSpawnDelta = 0.0f;
    self.currentEmitterIndex = 0;
    
    self.emitterBlocks = [NSArray arrayWithObjects:[^{
        self.autoSpawnDelta = 0.5f;
        self.particleEffect.gravity = AGLKDefaultGravity;
        
        float randomXVelocity = -0.5f + 1.0f * (float)random() / (float)RAND_MAX;
        
        [self.particleEffect addParticleAtPosition:GLKVector3Make(0.0f,
                                                                  0.0f,
                                                                  0.9f)
                                          velocity:GLKVector3Make(randomXVelocity,
                                                                  1.0f,
                                                                  -1.0f)
                                             force:GLKVector3Make(0.0f, 9.0f, 0.0f)
                                              size:4.0f
                                   lifeSpanSeconds:3.2f
                               fadeDurationSeconds:0.5f];
    } copy],
                          [^{
        self.autoSpawnDelta = 0.05f;
        self.particleEffect.gravity = GLKVector3Make(0.0f,
                                                     0.5f,
                                                     0.0f);
        for (int i = 0; i < 20; i++) {
            float randomXVelocity = -0.1f + 0.2f * (float)random()/(float)RAND_MAX;
            float randomZVelocity = 0.1f + 0.2f * (float)random()/(float)RAND_MAX;
            
            [self.particleEffect addParticleAtPosition:GLKVector3Make(0.0f, -0.5f, 0.0f)
                                              velocity:GLKVector3Make(randomXVelocity,
                                                                      0.0,
                                                                      randomZVelocity)
                                                 force:GLKVector3Make(0.0f, 0.0f, 0.0f)
                                                  size:64.0
                                       lifeSpanSeconds:2.2f
                                   fadeDurationSeconds:3.0f];
        }
    } copy],
                          [^{
        self.autoSpawnDelta = 0.5f;
        self.particleEffect.gravity = GLKVector3Make(0.0f,
                                                     0.0f,
                                                     0.0f);
        for (int i = 0; i < 100; i ++) {
            float randomXVelocity = -0.5f + 1.0f * (float)random() / (float)RAND_MAX;
            float randomYVelocity = -0.5f + 1.0f * (float)random() / (float)RAND_MAX;
            float randomZVelocity = -0.5f + 1.0f * (float)random() / (float)RAND_MAX;
            
            [self.particleEffect addParticleAtPosition:GLKVector3Make(0.0f,
                                                                      0.0f,
                                                                      0.0f)
                                              velocity:GLKVector3Make(randomXVelocity,
                                                                      randomYVelocity,
                                                                      randomZVelocity)
                                                 force:GLKVector3Make(0.0f, 0.0f, 0.0f)
                                                  size:4.0f
                                       lifeSpanSeconds:3.2f
                                   fadeDurationSeconds:0.5f];
        }
    } copy],
                          [^{
        self.autoSpawnDelta = 3.2f;
        self.particleEffect.gravity = GLKVector3Make(0.0f, 0.0f, 0.0f);
        for (int i = 0;i < 100; i++) {
            float randomXVelocity = -0.5f + 1.0f * (float)random() / (float)RAND_MAX;
            float randomYVelocity = -0.5f + 1.0f * (float)random() / (float)RAND_MAX;
            
            GLKVector3 velocity = GLKVector3Normalize(GLKVector3Make(randomXVelocity, randomYVelocity, 0.0f));
            
            [self.particleEffect addParticleAtPosition:GLKVector3Make(0.0f,
                                                                      0.0f,
                                                                      0.0f)
                                              velocity:velocity
                                                 force:GLKVector3MultiplyScalar(velocity, -1.0f)
                                                  size:4.0f
                                       lifeSpanSeconds:3.2f
                                   fadeDurationSeconds:0.1f];
        }
    } copy], nil];
}

- (void)update{
    // gravity和elapsedSeconds用于控制支配粒子运动的物理引擎。gravity属性默认与地球重力加速度相匹配：-9.80665(下落物体的速度每秒增加9.8米/秒)。在准备一个用于绘图的AGLKPointParticleEffect实例之前，必须要设置elapsedSeconds属性.粒子的当前位置是基于连续增加的elapsedSeconds属性计算出来的。
    
    NSTimeInterval timeElapsed = self.timeSinceLastResume;
    self.particleEffect.elapsedSeconds = timeElapsed;
    
    if (self.autoSpawnDelta < (timeElapsed - self.lastSpawnTime)) {
        self.lastSpawnTime = timeElapsed;
        
        void(^emitterBlock)(void) = [self.emitterBlocks objectAtIndex:self.currentEmitterIndex];
        emitterBlock();
    }
}

- (void)preparePointOfViewWithAspectRatio:(GLfloat)aspectRatio{
    self.baseEffect.transform.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(85.0f),
                                                                           aspectRatio,
                                                                           0.1f,
                                                                           20.0f);
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4MakeLookAt(0.0, 0.0, 1.0,
                                                                     0.0, 0.0, 0.0,
                                                                     0.0, 1.0, 0.0);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    const GLfloat aspectRatio = (GLfloat)view.drawableWidth / (GLfloat)view.drawableHeight;
    [(AGLKContext *)view.context clear:GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT];
    [self preparePointOfViewWithAspectRatio:aspectRatio];
    
    self.baseEffect.light0.position = GLKVector4Make(0.4f,
                                                     0.4f,
                                                     -0.2f,
                                                     0.0f);
    
    self.particleEffect.transform.projectionMatrix = self.baseEffect.transform.projectionMatrix;
    self.particleEffect.transform.modelviewMatrix = self.baseEffect.transform.modelviewMatrix;
    
    [self.particleEffect prepareToDraw];
    [self.particleEffect draw];
    
    [self.baseEffect prepareToDraw];
    
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
    self.particleEffect = nil;
    [EAGLContext setCurrentContext:nil];
}

- (IBAction)takeSelectedEmitterFrom:(UISegmentedControl *)sender {
    self.currentEmitterIndex = [sender selectedSegmentIndex];
}

- (IBAction)takeSelectedTextureFrom:(UISegmentedControl *)sender {
    
    NSUInteger index = [sender selectedSegmentIndex];
    switch (index) {
        case 0:
            self.particleEffect.texture2d0.name = self.ballParticleTexture.name;
            self.particleEffect.texture2d0.target = self.ballParticleTexture.target;
            break;
        case 1:
            self.particleEffect.texture2d0.name = self.burstParticleTexture.name;
            self.particleEffect.texture2d0.target = self.burstParticleTexture.target;
            break;
        case 2:
            self.particleEffect.texture2d0.name = self.smokeParticleTexture.name;
            self.particleEffect.texture2d0.target = self.smokeParticleTexture.target;
            break;
        default:
            self.particleEffect.texture2d0.name = 0;
            break;
    }
}

@end
