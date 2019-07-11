//
//  SceneCar.h
//  OpenGLES_6
//
//  Created by luowailin on 2019/6/25.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "SceneModel.h"

NS_ASSUME_NONNULL_BEGIN
@protocol SceneCarControllerProtocol <NSObject>

- (NSTimeInterval)timeSinceLastUpdate;
- (SceneAxisAllignedBoundingBox)rinkBoundingBox;
- (NSArray *)cars;

@end

@interface SceneCar : NSObject

@property(nonatomic, strong, readonly) SceneModel *model;
@property(nonatomic, assign, readonly) GLKVector3 position;
@property(nonatomic, assign, readonly) GLKVector3 nextPosition;
@property(nonatomic, assign, readonly) GLKVector3 velocity;

@property(nonatomic, assign, readonly) GLfloat yawRadians;
@property(nonatomic, assign, readonly) GLfloat targetYawRadians;
@property(nonatomic, assign, readonly) GLfloat radius;

@property(nonatomic, assign, readonly) GLKVector4 color;

//初始化函数 注意 这里的SceneCar并没有依赖SceneCarModel，而是依赖抽象(基类)SceneModel，实现了解耦。可以新建一个SceneOtherCar 继承SceneModel 传递给SceneCar,不需要修改SceneCar的代码就可以创建出一个新的Car
- (instancetype)initWithModel:(SceneModel *)aModel //模型类
                     position:(GLKVector3)aPosition  //位置
                     velocity:(GLKVector3)aVelocity //速度
                        color:(GLKVector4)aColor; //颜色

- (void)updateWithController:(id<SceneCarControllerProtocol>)controller;
- (void)drawWithBaseEffect:(GLKBaseEffect *)anEffect;

@end

extern GLfloat SceneScalarFastLowPassFilter(NSTimeInterval timeSinceLastUpdate,
                                            GLfloat target,
                                            GLfloat current);
extern GLfloat SceneScalarSlowLowPassFilter(NSTimeInterval timeSinceLastUpdate,
                                            GLfloat target,
                                            GLfloat current);
extern GLKVector3 SceneVector3FastLowPassFilter(NSTimeInterval timeSinceLastUpdate,
                                             GLKVector3 target,
                                             GLKVector3 current);
extern GLKVector3 SceneVector3SlowLowPassFilter(NSTimeInterval timeSinceLastUpdate,
                                             GLKVector3 target,
                                             GLKVector3 current);

NS_ASSUME_NONNULL_END
