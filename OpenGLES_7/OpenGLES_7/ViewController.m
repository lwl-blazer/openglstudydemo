//
//  ViewController.m
//  OpenGLES_7
//
//  Created by luowailin on 2019/7/10.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "ViewController.h"
#import "UtilityModel+viewAdditions.h"
#import "UtilityModelManager.h"
#import "UtilityTextureInfo.h"
#import "AGLKContext.h"

@interface ViewController ()
{
    NSMutableArray *cars;
}

@property(nonatomic, strong) UtilityModelManager *modelManager;
@property(nonatomic, strong) GLKBaseEffect *baseEffect;
@property(nonatomic, strong) UtilityModel *carModel;
@property(nonatomic, strong) UtilityModel *rinkModelFloor;
@property(nonatomic, strong) UtilityModel *rinkModelWalls;

@property(nonatomic, assign, readwrite) AGLKAxisAllignedBoundingBox rinkBoundingBox;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    cars = [[NSMutableArray alloc] init];
    
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]], @"View controller's view is not a GLKView");
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    view.context = [[AGLKContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    [AGLKContext setCurrentContext:view.context];
    [((AGLKContext *)view.context) enable:GL_DEPTH_TEST];
    
    self.baseEffect = [[GLKBaseEffect alloc] init];
    
    self.baseEffect.light0.enabled = GL_TRUE;
    self.baseEffect.light0.ambientColor = GLKVector4Make(0.7f,
                                                         0.7f,
                                                         0.7f,
                                                         1.0f);
    self.baseEffect.light0.diffuseColor = GLKVector4Make(1.0f,
                                                         1.0f,
                                                         1.0f,
                                                         1.0f);
    self.baseEffect.light0.position = GLKVector4Make(0.0f,
                                                     0.0f,
                                                     0.4f,
                                                     0.0f);
    
    ((AGLKContext *)view.context).clearColor = GLKVector4Make(0.0f,
                                                              0.0f,
                                                              0.0f,
                                                              1.0f);
    
    
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"bumper"
                                                          ofType:@"modelplist"];
    self.modelManager = [[UtilityModelManager alloc] initWithModelPath:modelPath];
    
    //四个Model
    self.carModel = [self.modelManager modelNamed:@"bumperCar"];
    NSAssert(self.carModel != nil, @"Failed to load car model");
    
    self.rinkModelFloor = [self.modelManager modelNamed:@"bumperRinkFloor"];
    NSAssert(self.rinkModelFloor != nil, @"Failed to load rink floor model");
    
    self.rinkModelWalls = [self.modelManager modelNamed:@"bumperRinkWalls"];
    NSAssert(self.rinkModelWalls != nil, @"Failed to load rink walls model");
    
    self.rinkBoundingBox = self.rinkModelFloor.axisAlignedBoundingBox;
    NSAssert(0 < (self.rinkBoundingBox.max.x - self.rinkBoundingBox.min.x) && 0 < (self.rinkBoundingBox.max.z - self.rinkBoundingBox.min.z), @"Rink has no area");
    
    [cars addObject:[[SceneCar alloc] initWithModel:self.carModel
                                                position:GLKVector3Make(1.0, 0.0, 1.0)
                                                velocity:GLKVector3Make(1.5, 0.0, 1.5)
                                                   color:GLKVector4Make(0.0, 0.5, 0.0, 1.0)]];
    
    [cars addObject:[[SceneCar alloc] initWithModel:self.carModel
                                                position:GLKVector3Make(-1.0, 0.0, 1.0)
                                                velocity:GLKVector3Make(-1.5, 0.0, 1.5)
                                                   color:GLKVector4Make(0.5, 0.5, 0.0, 1.0)]];
    
    [cars addObject:[[SceneCar alloc] initWithModel:self.carModel
                                                position:GLKVector3Make(1.0, 0.0, -1.0)
                                                velocity:GLKVector3Make(-1.5, 0.0, -1.0)
                                                   color:GLKVector4Make(0.5, 0.0, 0.0, 1.0)]];
    
    [cars addObject:[[SceneCar alloc] initWithModel:self.carModel
                                                position:GLKVector3Make(2.0, 0.0, -2.0)
                                                velocity:GLKVector3Make(-1.5, 0.0, -0.5)
                                                   color:GLKVector4Make(0.3, 0.0, 0.3, 1.0)]];
    
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4MakeLookAt(10.5, 5.0, 0.0,
                                                                     0.0, 0.5, 0.0,
                                                                     0.0, 1.0, 0.0);
    
    self.baseEffect.texture2d0.name = self.modelManager.textureInfo.name;
    self.baseEffect.texture2d0.target = self.modelManager.textureInfo.target;
}

- (void)update{
    [cars makeObjectsPerformSelector:@selector(updateWithController:) withObject:self];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    [((AGLKContext *)view.context) clear:GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT];
    //背面剔除
    [((AGLKContext *)view.context) enable:GL_CULL_FACE];
    
    const GLfloat aspectRatio = (GLfloat)view.drawableWidth / (GLfloat)view.drawableHeight;
    
    self.baseEffect.transform.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(35.0f),
                                                                           aspectRatio,
                                                                           4.0f,
                                                                           20.0f);
    [self.modelManager prepareToDraw];
    [self.baseEffect prepareToDraw];
    
    [self.rinkModelFloor draw];
    [self.rinkModelWalls draw];
    
    [cars makeObjectsPerformSelector:@selector(drawWithBaseEffect:) withObject:self.baseEffect];
}

- (void)dealloc{
    GLKView *view = (GLKView *)self.view;
    [AGLKContext setCurrentContext:view.context];
    
    [EAGLContext setCurrentContext:nil];
    
    self.baseEffect = nil;
    cars = nil;
    self.carModel = nil;
    self.rinkModelFloor = nil;
    self.rinkModelWalls = nil;
}

- (NSArray *)cars{
    return cars;
}

@end


