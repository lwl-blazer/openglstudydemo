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

- (void)updateWithEyePosition:(GLKVector3)eyePosition
                lookDirection:(GLKVector3)lookDirection{
    const GLKVector3 vectorFromEye = GLKVector3Subtract(eyePosition, self.position);
    self.distanceSquared = GLKVector3DotProduct(vectorFromEye,
                                                lookDirection);
}

@end

NSComparisonResult UtilityCompareBillboardDistance(UtilityBillboard *a, UtilityBillboard *b, void *context){
    NSInteger result = NSOrderedSame;
    
    if (a.distanceSquared < b.distanceSquared) {
        result = NSOrderedDescending;
    } else if (a.distanceSquared > b.distanceSquared) {
        result = NSOrderedAscending;
    }
    return result;
}


