//
//  ViewController.m
//  OpenGLES_7
//
//  Created by luowailin on 2019/7/10.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "ViewController.h"
#import "SceneCar.h"
#import "AGLKAxisAllignedBoundingBox.h"
#import "UtilityModel+viewAdditions.h"
#import "UtilityModelManager.h"
#import "UtilityTextureInfo.h"
#import "AGLKContext.h"

@interface ViewController ()<SceneCarControllerProtocol>

@property(nonatomic, strong) NSMutableArray *cars;
@property(nonatomic, assign) AGLKAxisAllignedBoundingBox rinkBoudingBox;

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
    
    self.cars = [NSMutableArray array];
    
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]], @"View controller's view is not a GLKView");
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    view.context = [[AGLKContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    
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
    self.baseEffect.light0.position = GLKVector4Make(1.0f,
                                                     0.8f,
                                                     0.4f,
                                                     0.0f);
    
    ((AGLKContext *)view.context).clearColor = GLKVector4Make(0.0f,
                                                              0.0f,
                                                              0.0f,
                                                              1.0f);
    
    
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"bumper"
                                                          ofType:@"modelplist"];
    self.modelManager = [[UtilityModelManager alloc] initWithModelPath:modelPath];
    
    self.carModel = [self.modelManager modelNamed:@"bumperCar"];
    NSAssert(self.carModel != nil, @"Failed to load car model");
    
    self.rinkModelFloor = [self.modelManager modelNamed:@"bumperRinkFloor"];
    NSAssert(self.rinkModelFloor != nil, @"Failed to load rink floor model");
    
    self.rinkModelWalls = [self.modelManager modelNamed:@"bumperRinkWalls"];
    NSAssert(self.rinkModelWalls != nil, @"Failed to load rink walls model");
    
    
    self.rinkBoudingBox = self.rinkModelFloor.axisAlignedBoundingBox;
    NSAssert(0 < (self.rinkBoudingBox.max.x - self.rinkBoudingBox.min.x) && 0 < (self.rinkBoudingBox.max.z - self.rinkBoudingBox.min.z), @"Rink has no area");
    
    [self.cars addObject:[[SceneCar alloc] initWithModel:self.carModel
                                                position:GLKVector3Make(1.0, 0.0, 1.0)
                                                velocity:GLKVector3Make(1.5, 0.0, 1.5)
                                                   color:GLKVector4Make(0.0, 0.5, 0.0, 1.0)]];
    
    
}


@end
