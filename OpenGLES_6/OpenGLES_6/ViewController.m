//
//  ViewController.m
//  OpenGLES_6
//
//  Created by luowailin on 2019/6/25.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "ViewController.h"
#import "SceneCarModel.h"
#import "SceneRinkModel.h"
#import "SceneCar.h"
#import "AGLKContext.h"

@interface ViewController ()<SceneCarControllerProtocol>

@property(nonatomic, strong) NSMutableArray *carArray;
@property(nonatomic, assign) SceneAxisAllignedBoundingBox rinkBoundingBox;

@property(nonatomic, strong) GLKBaseEffect *baseEffect;
@property(nonatomic, strong) SceneModel *carModel;
@property(nonatomic, strong) SceneModel *rinkModel;

@property(nonatomic, assign) BOOL shouldUseFirstPersonPOV;
@property(nonatomic, assign) GLfloat pointOfViewAnimationCountDown;

@property(nonatomic, assign) GLKVector3 eyePosition; //当前眼睛位置
@property(nonatomic, assign) GLKVector3 lookAtPosition; //当前看向的位置
@property(nonatomic, assign) GLKVector3 targetEyePosition;  //眼睛的目标位置
@property(nonatomic, assign) GLKVector3 targetLookAtPosition; //方向的目标位置   通过高通滤波器函数和低通滤波器函数实现视角平滑过渡

@end

@implementation ViewController

static const int SceneNumberOfPOVAnimationSeconds = 2.0;

- (void)viewDidLoad {
    [super viewDidLoad];

    /**
     * 动画通常包含两种情况: 1.对像相对于用户的视点移动   2.用户的视点相对于对象的位置变化
     */
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]], @"View Controller's view is not a GLKView ");
    view.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    view.context = [[AGLKContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    [AGLKContext setCurrentContext:view.context];
    
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.light0.enabled = GL_TRUE;
    self.baseEffect.light0.ambientColor = GLKVector4Make(0.6f,
                                                         0.6f,
                                                         0.6f,
                                                         1.0f);
    self.baseEffect.light0.position = GLKVector4Make(1.0f,
                                                     0.8f,
                                                     0.4f,
                                                     0.0f);
    ((AGLKContext *)view.context).clearColor = GLKVector4Make(0.0f,
                                                              0.0f,
                                                              0.0f,
                                                              1.0f);
    
    [((AGLKContext *)view.context) enable:GL_DEPTH_TEST];
    [((AGLKContext *)view.context) enable:GL_BLEND];
    
    self.carModel = [[SceneCarModel alloc] init];
    self.rinkModel = [[SceneRinkModel alloc] init];
    
    //场地
    self.rinkBoundingBox = self.rinkModel.axisAlignedBoundBox;
    NSAssert((self.rinkBoundingBox.max.x - self.rinkBoundingBox.min.x) > 0 && (self.rinkBoundingBox.max.z - self.rinkBoundingBox.min.z) > 0, @"Rink has no area");
    
    SceneCar *newCar = [[SceneCar alloc] initWithModel:self.carModel
                                              position:GLKVector3Make(1.0f, 0.0f, 1.0f)
                                              velocity:GLKVector3Make(1.5, 0.0, 1.5)
                                                 color:GLKVector4Make(0.0, 0.5, 1.0, 0.0)];
    [self.carArray addObject:newCar];
    
    newCar = [[SceneCar alloc] initWithModel:self.carModel
                                    position:GLKVector3Make(-1.0, 0.0, -1.0)
                                    velocity:GLKVector3Make(-1.5, 0.0, 1.5)
                                       color:GLKVector4Make(0.5, 0.5, 0.0, 1.0)];
    [self.carArray addObject:newCar];
    
    newCar = [[SceneCar alloc] initWithModel:self.carModel
                                    position:GLKVector3Make(1.0, 0.0, -1.0)
                                    velocity:GLKVector3Make(-1.5, 0.0, -1.5)
                                       color:GLKVector4Make(0.5, 0.0, 0.0, 1.0)];
    [self.carArray addObject:newCar];
    
    newCar = [[SceneCar alloc] initWithModel:self.carModel
                                    position:GLKVector3Make(2.0, 0.0, -2.0)
                                    velocity:GLKVector3Make(-1.5, 0.0, -0.5)
                                       color:GLKVector4Make(0.3, 0.0, 0.3, 1.0)];
    [self.carArray addObject:newCar];
    
    newCar = [[SceneCar alloc] initWithModel:self.carModel
                                    position:GLKVector3Make(1.0, 0.0, -2.0)
                                    velocity:GLKVector3Make(-1.5, 0.0, -0.5)
                                       color:GLKVector4Make(0.9, 0.8, 0.3, 1.0)];
    [self.carArray addObject:newCar];
    
    newCar = [[SceneCar alloc] initWithModel:self.carModel
                                    position:GLKVector3Make(2.0, 0.0, -1.0)
                                    velocity:GLKVector3Make(-1.5, 0.0, -0.5)
                                       color:GLKVector4Make(0.4, 0.5, 0.3, 1.0)];
    [self.carArray addObject:newCar];
    
    self.eyePosition = GLKVector3Make(10.5, 5.0, 0.0);
    self.lookAtPosition = GLKVector3Make(0.0, 0.5, 0.0);
}

- (void)updatePointOfView{
    //正射投影和透视投影之间切换  ---- 对像相对于用户的视点移动
    if (!self.shouldUseFirstPersonPOV) {
        /**
         * 观察者在碰碰车上方向下看的效果
         * 第三人称观点会把观察者的眼睛置于溜冰场的侧上部并看向溜冰场中央稍微向上的位置。第三人称眼睛和看向的位置是任意角度的并且不会发生变化
         */
        self.eyePosition = GLKVector3Make(10.5,
                                          5.0,
                                          0.0);
        self.lookAtPosition = GLKVector3Make(0.0,
                                             0.5,
                                             0.0);
    } else {
        /**
         * 从一个活动中的碰碰车中的视点所观察到的场景
         * 第一人称视点会随着观察者所乘坐的碰碰车而移动和转向。眼睛位置被设置为碰碰车当前位置的正上方，看向位置是碰碰车前面碰碰车行驶方向上的一个点
         */
        SceneCar *viewerCar = [self.cars lastObject];
        self.targetEyePosition = GLKVector3Make(viewerCar.position.x,
                                                viewerCar.position.y + 0.45f,
                                                viewerCar.position.z);
        
        //viewerCar.velocity与eyePosition相加会计算出碰碰车前方的一个位置
        self.targetLookAtPosition = GLKVector3Add(self.eyePosition,
                                                  viewerCar.velocity); //viewerCar.velocity是一个用于指定碰碰车行驶方向的带有方向的矢量，并且会指定移动的速度
    }
}

- (void)update{
    //从第三人称视点 转向 第一人称视点 提供了一个平滑的过渡动画 使用了低通滤波器来逐渐减少当前视点与用户选择的视点之间的差异产生。
    if (self.pointOfViewAnimationCountDown > 0) { //慢速切换到第三人称
        self.pointOfViewAnimationCountDown -= self.timeSinceLastDraw;
        
        self.eyePosition = SceneVector3SlowLowPassFilter(self.timeSinceLastUpdate,
                                                         self.targetEyePosition,
                                                         self.eyePosition);
        
        self.lookAtPosition = SceneVector3SlowLowPassFilter(self.timeSinceLastUpdate,
                                                            self.targetLookAtPosition,
                                                            self.lookAtPosition);
    } else { //快速切换到第一人称
        self.eyePosition = SceneVector3FastLowPassFilter(self.timeSinceLastUpdate,
                                                         self.targetEyePosition,
                                                         self.eyePosition);
        self.lookAtPosition = SceneVector3FastLowPassFilter(self.timeSinceLastUpdate,
                                                            self.targetLookAtPosition,
                                                            self.lookAtPosition);
    }
    
    //让数组中的每个元素都调用方法  把对象传进去
    [self.cars makeObjectsPerformSelector:@selector(updateWithController:) withObject:self];
    [self updatePointOfView];
}

- (SEL)extracted {
    return @selector(drawWithBaseEffect:);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    self.baseEffect.light0.diffuseColor = GLKVector4Make(1.0f,
                                                         1.0f,
                                                         1.0f,
                                                         1.0f);
    
    [((AGLKContext *)view.context) clear:GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT];
    
    const GLfloat aspectRatio = (GLfloat)view.drawableWidth / (GLfloat)view.drawableHeight;
    self.baseEffect.transform.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(35.0f),
                                                                           aspectRatio,
                                                                           0.1f,
                                                                           25.0f);
    /**
     * GLKMatrix4MakeLookAt()   相当于OpenGL中的gluLookAt()
     * 参数:
       前三个参数指定观察者眼睛的(x,y,z)位置
       接下来的3个参数指定观察者正在看向的(x,y,z)位置
       最后三个参数指定了‘上’方向的矢量(x,y,z)  改变‘上’方向与倾斜观察者头部的效果相同
     * 返回:
     * 会计算并返回一个model-view矩阵，这个矩阵会对齐从眼睛的位置到看向的位置之间的矢量与当前视域的中心线。如果眼睛的位置与看向的位置相同，就不会产生有效的结果
     */
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4MakeLookAt(self.eyePosition.x,
                                                                     self.eyePosition.y,
                                                                     self.eyePosition.z,
                                                                     self.lookAtPosition.x,
                                                                     self.lookAtPosition.y,
                                                                     self.lookAtPosition.z,
                                                                     0, 1, 0);
    
    [self.baseEffect prepareToDraw];
    [self.rinkModel draw]; //场地的渲染
    
    //碰碰车的渲染
    [self.carArray makeObjectsPerformSelector:@selector(drawWithBaseEffect:) withObject:self.baseEffect];
}

- (void)dealloc{
    GLKView *view = (GLKView *)self.view;
    [AGLKContext setCurrentContext:view.context];
    
    [EAGLContext setCurrentContext:nil];
    
    self.baseEffect = nil;
    self.carArray = nil;
    self.carModel = nil;
    self.rinkModel = nil;
}

- (NSArray *)cars{
    return self.carArray.copy;
}

- (IBAction)takeShouldUseFirstPersonPOVFrom:(UISwitch *)sender{
    self.shouldUseFirstPersonPOV = [sender isOn];
    self.pointOfViewAnimationCountDown = SceneNumberOfPOVAnimationSeconds;
}


- (NSMutableArray *)carArray{
    if (!_carArray) {
        _carArray = [NSMutableArray array];
    }
    return _carArray;
}




@end
