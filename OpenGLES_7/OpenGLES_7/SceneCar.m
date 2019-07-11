//
//  SceneCar.m
//  OpenGLES_6
//
//  Created by luowailin on 2019/6/25.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "SceneCar.h"
#import "UtilityModel+viewAdditions.h"

/** car的逻辑类
 * SceneCar 类封装了每个碰碰车的当前位置、速度、颜色、偏航角和模型。偏航(yaw)是来自轮船和航空的一个术语，代表了围绕垂直轴的旋转度，在这个案例中围绕Y轴。偏航定义了碰碰车的方向并且会随着时间变化而让碰碰车面向它的移动的方向
 *
 * 包括car的速度、位置、偏航角、半径、还有滤波函数、cars的碰撞处理、car与场景的碰撞处理、绘制car模型
 */

@interface SceneCar ()

@property(nonatomic, strong, readwrite) UtilityModel *model;
@property(nonatomic, assign, readwrite) GLKVector3 position;
@property(nonatomic, assign, readwrite) GLKVector3 nextPosition;
@property(nonatomic, assign, readwrite) GLKVector3 velocity;
@property(nonatomic, assign, readwrite) GLfloat yawRadians;
@property(nonatomic, assign, readwrite) GLfloat targetYawRadians;

@property(nonatomic, assign, readwrite) GLKVector4 color;
@property(nonatomic, assign, readwrite) GLfloat radius; //car的半径

@end


@implementation SceneCar
- (instancetype)init{
    NSAssert(0, @"Invalid initializer");
    return nil;
}

- (instancetype)initWithModel:(UtilityModel *)aModel
                     position:(GLKVector3)aPosition
                     velocity:(GLKVector3)aVelocity
                        color:(GLKVector4)aColor{
    self = [super init];
    if (self) {
        self.position = aPosition;
        self.color = aColor;
        self.velocity = aVelocity;
        self.model = aModel;
        
        AGLKAxisAllignedBoundingBox axisAlignedBoundingBox = self.model.axisAlignedBoundingBox;
        
        //通过得到墙壁的最大小边界，得到car的半径
        self.radius = 0.5f * MAX(axisAlignedBoundingBox.max.x - axisAlignedBoundingBox.min.x, axisAlignedBoundingBox.max.z - axisAlignedBoundingBox.min.z);
    }
    return self;
}

//car与墙壁碰撞模拟
- (void)bounceOffWallsWithBoundingBox:(AGLKAxisAllignedBoundingBox)rinkBoundingBox{
    //根据car的半径，通过半径+nextPosition与RinkBoundingBox判断是否到达边界,如果到达边界则把对应轴的速度向量反向
    if ((rinkBoundingBox.min.x + self.radius) > self.nextPosition.x) {
        //下一个点超过了x最小的边界
        self.nextPosition = GLKVector3Make((rinkBoundingBox.min.x + self.radius),
                                           self.nextPosition.y,
                                           self.nextPosition.z);
        //撞墙后x方向相反
        self.velocity = GLKVector3Make(-self.velocity.x,
                                       self.velocity.y,
                                       self.velocity.z);
    } else if((rinkBoundingBox.max.x - self.radius) < self.nextPosition.x){
        //下一个点超过了x最大的边界
        self.nextPosition = GLKVector3Make((rinkBoundingBox.max.x - self.radius),
                                           self.nextPosition.y,
                                           self.nextPosition.z);
        
        self.velocity = GLKVector3Make(-self.velocity.x,
                                       self.velocity.y,
                                       self.velocity.z);
    }
    
    //z的边界判断
    if ((rinkBoundingBox.min.z + self.radius) > self.nextPosition.z) {
        
        self.nextPosition = GLKVector3Make(self.nextPosition.x,
                                           self.nextPosition.y,
                                           (rinkBoundingBox.min.z + self.radius));
        
        self.velocity = GLKVector3Make(self.velocity.x,
                                       self.velocity.y,
                                       -self.velocity.z);
    } else if ((rinkBoundingBox.max.z - self.radius) < self.nextPosition.z) {
        self.nextPosition = GLKVector3Make(self.nextPosition.x,
                                           self.nextPosition.y,
                                           (rinkBoundingBox.max.z - self.radius));
        
        self.velocity = GLKVector3Make(self.velocity.x,
                                       self.velocity.y,
                                       -self.velocity.z);
    }
}

//car之间的碰撞
- (void)bounceOffCars:(NSArray *)cars
          elapsedTime:(NSTimeInterval)elapsedTimeSeconds{
    for (SceneCar *currentCar in cars) {
        /**
         * 假设两辆车分别为self和other
         * selfCar的速度为velocity 位置为position, otherCar的速度为otherVelocity位置为otherPosition
         * 通过position和otherPosition,可以得到一条直线，car的碰撞就发生在这一条线上的方向上
         
         * velocity在直线上的分量是tanOwnVelocity,otherVelocity在直线上的分量为tanOtherVelocity,otherVelocity在直线上的分量为tanOtherVelocity
         */
        if (currentCar != self) {
            float distance = GLKVector3Distance(self.nextPosition,
                                                currentCar.nextPosition);
            
            if ((2.0 * self.radius) > distance) {
                GLKVector3 ownVelocity = self.velocity;
                GLKVector3 otherVelocity = currentCar.velocity;
                GLKVector3 directionToOtherCar = GLKVector3Subtract(currentCar.position, self.position);
                
                directionToOtherCar = GLKVector3Normalize(directionToOtherCar);
                GLKVector3 negDirectionToOtherCar = GLKVector3Negate(directionToOtherCar);
                
                GLKVector3 tanOwnVelocity = GLKVector3MultiplyScalar(negDirectionToOtherCar,
                                                                     GLKVector3DotProduct(ownVelocity,
                                                                                          negDirectionToOtherCar));
                
                GLKVector3 tanOtherVelocity = GLKVector3MultiplyScalar(directionToOtherCar,
                                                                       GLKVector3DotProduct(otherVelocity,
                                                                                            directionToOtherCar));
                //碰撞完成后selfCar的速度为velocity - thanOwnVelocity otherCar的速度为otherVelocity - tanOtherVelocity
                { //更新自己的速度
                    self.velocity = GLKVector3Subtract(ownVelocity,
                                                       tanOwnVelocity);
                    GLKVector3 travelDistance = GLKVector3MultiplyScalar(self.velocity,
                                                                         elapsedTimeSeconds);
                    
                    self.nextPosition = GLKVector3Add(self.position,
                                                      travelDistance);
                }
                {//更新其它car的速度
                    currentCar.velocity = GLKVector3Subtract(otherVelocity,
                                                             tanOtherVelocity);
                    GLKVector3 traveDistance = GLKVector3MultiplyScalar(currentCar.velocity,
                                                                        elapsedTimeSeconds);
                    
                    currentCar.nextPosition = GLKVector3Add(currentCar.position,
                                                            traveDistance);
                }
            }
        }
    }
}

//当碰碰车从墙壁弹回并转向时，碰碰车并不会瞬间转向新的方向，而是先让目标方向变为新的方向，然后碰碰车的当前方向逐步更新直到与目标方向一致
- (void)spinTowardDirectionOfMotion:(NSTimeInterval)elapsed{
    self.yawRadians = SceneScalarSlowLowPassFilter(elapsed,
                                                   self.targetYawRadians,
                                                   self.yawRadians);
}


//更新car的位置、偏航角和速度 模拟与墙和其他car的碰撞
- (void)updateWithController:(id<SceneCarControllerProtocol>)controller{
    //0.01秒和0.5秒之间
    NSTimeInterval elapsedTimeSeconds = MIN(MAX([controller timeSinceLastUpdate], 0.01f), 0.5f);
    
    GLKVector3 travelDistance = GLKVector3MultiplyScalar(self.velocity,
                                                         elapsedTimeSeconds);
    
    self.nextPosition = GLKVector3Add(self.position,
                                      travelDistance);
    
    AGLKAxisAllignedBoundingBox rinkBoundingBox = [controller rinkBoundingBox];
    
    [self bounceOffCars:[controller cars]
            elapsedTime:elapsedTimeSeconds];
    
    [self bounceOffWallsWithBoundingBox:rinkBoundingBox];
    
    if (0.1 > GLKVector3Length(self.velocity)) {
        //速度太小，方向可能是死角，随机换一个方向
        self.velocity = GLKVector3Make((random()/(0.5f * RAND_MAX)) - 1.0f,
                                       0.0f,
                                       (random() / (0.5f * RAND_MAX)) - 1.0f);
    } else if(4 > GLKVector3Length(self.velocity)){
        //缓慢加速
        self.velocity = GLKVector3MultiplyScalar(self.velocity,
                                                 1.01f);
    }
    
    //car的方向和标准方向的余弦值
    float dotProduct = GLKVector3DotProduct(GLKVector3Normalize(self.velocity),
                                            GLKVector3Make(0.0,
                                                           0,
                                                           -1.0));
    if (0.0 > self.velocity.x) { //偏航角为正
        self.targetYawRadians = acosf(dotProduct);
    } else { //偏航角为负
        self.targetYawRadians = -acosf(dotProduct);
    }
    
    [self spinTowardDirectionOfMotion:elapsedTimeSeconds];
    
    self.position = self.nextPosition;
}

//绘制
- (void)drawWithBaseEffect:(GLKBaseEffect *)anEffect{
    //设置当前材质的颜色以匹配碰碰车的颜色，
    GLKMatrix4 savedModelviewMatrix = anEffect.transform.modelviewMatrix;
    GLKVector4 savedDiffuseColor = anEffect.material.diffuseColor;
    GLKVector4 savedAmbientColor = anEffect.material.ambientColor;
    
    //平移model-view坐标系到碰碰车的当前位置，旋转坐标系以匹配碰碰车的当前偏航角，并绘制碰碰车模型。
    anEffect.transform.modelviewMatrix = GLKMatrix4Translate(savedModelviewMatrix,
                                                             self.position.x,
                                                             self.position.y,
                                                             self.position.z);
    //旋转Y轴的偏航角
    anEffect.transform.modelviewMatrix = GLKMatrix4Rotate(anEffect.transform.modelviewMatrix,
                                                          self.yawRadians,
                                                          0.0,
                                                          1.0,
                                                          0.0);
    
    anEffect.material.diffuseColor = self.color;
    anEffect.material.ambientColor = self.color;
    
    [anEffect prepareToDraw];
    
    [self.model draw];
    
    anEffect.transform.modelviewMatrix = savedModelviewMatrix;
    anEffect.material.diffuseColor = savedDiffuseColor;
    anEffect.material.ambientColor = savedAmbientColor;
}

@end


//高通滤波器函数
GLfloat SceneScalarFastLowPassFilter(NSTimeInterval timeSinceLastUpdate,
                                     GLfloat target,
                                     GLfloat current){
    return current + (50.0 * timeSinceLastUpdate * (target - current));  //50是一个可替换的较大的函数。可以模拟撞墙后震动的效果， 因为50比较大，current的值再增加后可能超过target
}

GLKVector3 SceneVector3FastLowPassFilter(NSTimeInterval timeSinceLastUpdate,
                                         GLKVector3 target,
                                         GLKVector3 current){
    return GLKVector3Make(SceneScalarFastLowPassFilter(timeSinceLastUpdate,
                                                       target.x,
                                                       current.x),
                          SceneScalarFastLowPassFilter(timeSinceLastUpdate,
                                                       target.y,
                                                       current.y),
                          SceneScalarFastLowPassFilter(timeSinceLastUpdate,
                                                       target.z,
                                                       current.z));
}

/** 低通滤波器
 * 低通滤波器会反复逐渐地改变计算出来的值，并且必须调用很多次才能产生一个明显的效果。之所以叫‘低通’是因为对于正在被过滤的值来说，低频的、长期的变化会有一个明显的影响，而高频变化的影响甚微。
 * 低通滤波器是通过反复调用来工作的，每次调用会返回一个更接近‘目标’值的新的当前值。
 * 几乎所有的3D模拟都受益于这样或那样的过滤器
 */
//ease in
GLfloat SceneScalarSlowLowPassFilter(NSTimeInterval timeSinceLastUpdate,
                                     GLfloat target,
                                     GLfloat current){
    return current + (4.0 * timeSinceLastUpdate * (target - current)); //4.0是一个可替换的较小的常数，可以模拟视角切换过程的效果，因为4.0比较小，current会逐渐接近target
}

GLKVector3 SceneVector3SlowLowPassFilter(NSTimeInterval timeSinceLastUpdate,
                                             GLKVector3 target,
                                         GLKVector3 current){
    return GLKVector3Make(SceneScalarSlowLowPassFilter(timeSinceLastUpdate,
                                                       target.x,
                                                       current.x),
                          SceneScalarSlowLowPassFilter(timeSinceLastUpdate,
                                                       target.y,
                                                       current.y),
                          SceneScalarSlowLowPassFilter(timeSinceLastUpdate,
                                                       target.z,
                                                       current.z));
}
