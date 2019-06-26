//
//  SceneCar.m
//  OpenGLES_6
//
//  Created by luowailin on 2019/6/25.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "SceneCar.h"

@interface SceneCar ()

@property(nonatomic, strong, readwrite) SceneModel *model;
@property(nonatomic, assign, readwrite) GLKVector3 position;
@property(nonatomic, assign, readwrite) GLKVector3 nextPosition;
@property(nonatomic, assign, readwrite) GLKVector3 velocity;
@property(nonatomic, assign, readwrite) GLfloat yawRadians;
@property(nonatomic, assign, readwrite) GLfloat targetYawRadians;

@property(nonatomic, assign, readwrite) GLKVector4 color;
@property(nonatomic, assign, readwrite) GLfloat radius;

@end


@implementation SceneCar
- (instancetype)init{
    NSAssert(0, @"Invalid initializer");
    return nil;
}

- (instancetype)initWithModel:(SceneModel *)aModel
                     position:(GLKVector3)aPosition
                     velocity:(GLKVector3)aVelocity
                        color:(GLKVector4)aColor{
    self = [super init];
    if (self) {
        self.position = aPosition;
        self.color = aColor;
        self.velocity = aVelocity;
        self.model = aModel;
        
        SceneAxisAllignedBoundingBox axisAlignedBoundingBox = self.model.axisAlignedBoundBox;
        
        self.radius = 0.5f * MAX(axisAlignedBoundingBox.max.x - axisAlignedBoundingBox.min.x, axisAlignedBoundingBox.max.z - axisAlignedBoundingBox.min.z);
    }
    return self;
}

- (void)bounceOffWallsWithBoundingBox:(SceneAxisAllignedBoundingBox)rinkBoundingBox{
    if ((rinkBoundingBox.min.x + self.radius) > self.nextPosition.x) {
        self.nextPosition = GLKVector3Make((rinkBoundingBox.min.x + self.radius),
                                           self.nextPosition.y,
                                           self.nextPosition.z);
        
        self.velocity = GLKVector3Make(-self.velocity.x,
                                       self.velocity.y,
                                       self.velocity.z);
    } else if((rinkBoundingBox.max.x - self.radius) < self.nextPosition.x){
        self.nextPosition = GLKVector3Make((rinkBoundingBox.max.x - self.radius),
                                           self.nextPosition.y,
                                           self.nextPosition.z);
        
        self.velocity = GLKVector3Make(-self.velocity.x,
                                       self.velocity.y,
                                       self.velocity.z);
    }
    
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

- (void)bounceOffCars:(NSArray *)cars
          elapsedTime:(NSTimeInterval)elapsedTimeSeconds{
    for (SceneCar *currentCar in cars) {
        
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
                
                {
                    self.velocity = GLKVector3Subtract(ownVelocity,
                                                       tanOwnVelocity);
                    GLKVector3 travelDistance = GLKVector3MultiplyScalar(self.velocity,
                                                                         elapsedTimeSeconds);
                    
                    self.nextPosition = GLKVector3Add(self.position,
                                                      travelDistance);
                }
                {
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

- (void)updateWithController:(id<SceneCarControllerProtocol>)controller{
    NSTimeInterval elapsedTimeSeconds = MIN(MAX([controller timeSinceLastUpdate], 0.01f), 0.5f);
    
    GLKVector3 travelDistance = GLKVector3MultiplyScalar(self.velocity,
                                                         elapsedTimeSeconds);
    
    self.nextPosition = GLKVector3Add(self.position,
                                      travelDistance);
    
    SceneAxisAllignedBoundingBox rinkBoundingBox = [controller rinkBoundingBox];
    
    [self bounceOffCars:[controller cars]
            elapsedTime:elapsedTimeSeconds];
    
    [self bounceOffWallsWithBoundingBox:rinkBoundingBox];
    
    if (0.1 > GLKVector3Length(self.velocity)) {
        self.velocity = GLKVector3Make((random()/(0.5f * RAND_MAX)) - 1.0f,
                                       0.0f,
                                       (random() / (0.5f * RAND_MAX)) - 1.0f);
    } else if(4 > GLKVector3Length(self.velocity)){
        self.velocity = GLKVector3MultiplyScalar(self.velocity,
                                                 1.01f);
    }
    
    float dotProduct = GLKVector3DotProduct(GLKVector3Normalize(self.velocity),
                                            GLKVector3Make(0.0,
                                                           0,
                                                           -1.0));
    if (0.0 > self.velocity.x) {
        self.targetYawRadians = acosf(dotProduct);
    } else {
        self.targetYawRadians = -acosf(dotProduct);
    }
    
    [self spinTowardDirectionOfMotion:elapsedTimeSeconds];
    
    self.position = self.nextPosition;
}

- (void)drawWithBaseEffect:(GLKBaseEffect *)anEffect{
    GLKMatrix4 savedModelviewMatrix = anEffect.transform.modelviewMatrix;
    GLKVector4 savedDiffuseColor = anEffect.material.diffuseColor;
    GLKVector4 savedAmbientColor = anEffect.material.ambientColor;
    
    anEffect.transform.modelviewMatrix = GLKMatrix4Translate(savedModelviewMatrix,
                                                             self.position.x,
                                                             self.position.y,
                                                             self.position.z);
    
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



GLfloat SceneScalarSlowLowPassFilter(NSTimeInterval timeSinceLastUpdate,
                                            GLfloat target,
                                     GLfloat current){
    return current + (4.0 * timeSinceLastUpdate * (target - current));
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
GLfloat SceneScalarFastLowPassFilter(NSTimeInterval timeSinceLastUpdate,
                                     GLfloat target,
                                     GLfloat current){
    return current + (50.0 * timeSinceLastUpdate * (target - current));
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
