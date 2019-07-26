//
//  UtilityBillboard.m
//  OpenGLES_8
//
//  Created by luowailin on 2019/7/22.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "UtilityBillboard.h"

@interface UtilityBillboard ()

@property(nonatomic, assign, readwrite) GLKVector3 position;
@property(nonatomic, assign, readwrite) GLKVector2 minTextureCoords;
@property(nonatomic, assign, readwrite) GLKVector2 maxTextureCoords;
@property(nonatomic, assign, readwrite) GLKVector2 size;
@property(nonatomic, assign, readwrite) GLfloat distanceSquared;

@end

@implementation UtilityBillboard

- (instancetype)init{
    NSAssert(0, @"Invalid initializer");
    return nil;
}

- (instancetype)initWithPosition:(GLKVector3)aPosition
                            size:(GLKVector2)aSize
                minTextureCoords:(GLKVector2)minCoords
                maxTextureCoords:(GLKVector2)maxCoords{
    self = [super init];
    if (self) {
        self.position = aPosition;
        self.size = aSize;
        self.minTextureCoords = minCoords;
        self.maxTextureCoords = maxCoords;
    }
    return self;
}

//应用牛顿物理和滤波器来更改接收者的位置和重力
- (void)updateWithEyePosition:(GLKVector3)eyePosition
                lookDirection:(GLKVector3)lookDirection{
    const GLKVector3 vectorFromEye = GLKVector3Subtract(eyePosition, self.position);
    self.distanceSquared = GLKVector3DotProduct(vectorFromEye,
                                                lookDirection); //GLKVector3DotProduct()函数计算公告牌和眼睛位置之间的一个有符号的距离。这个有符号的距离用于从远处到近对比排序公告牌。当公告牌的位置在观察者后面时这个有符号的距离就是负值。利用这一点可以实现一个简单的优化:给定的一个根据距离排序的公告牌数组，当第一次碰到距离是负值的公告牌时就可以安全地停止绘制更多的公告牌。数组中剩下的公告牌都是不可见的。因为它们都在观察者后面
}

@end

//根据距离排序公告牌
NSComparisonResult UtilityCompareBillboardDistance(UtilityBillboard *a, UtilityBillboard *b, void *context){
    NSInteger result = NSOrderedSame;
    
    if (a.distanceSquared < b.distanceSquared) {
        result = NSOrderedDescending;
    } else if (a.distanceSquared > b.distanceSquared) {
        result = NSOrderedAscending;
    }
    return result;
}


