//
//  UtilityBillboard.h
//  OpenGLES_8
//
//  Created by luowailin on 2019/7/22.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import <GLKit/GLKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UtilityBillboard : NSObject

@property(nonatomic, assign, readonly) GLKVector3 position;
@property(nonatomic, assign, readonly) GLKVector2 minTextureCoords;
@property(nonatomic, assign, readonly) GLKVector2 maxTextureCoords;
@property(nonatomic, assign, readonly) GLKVector2 size;
@property(nonatomic, assign, readonly) GLfloat distanceSquared;


- (instancetype)initWithPosition:(GLKVector3)aPosition
                            size:(GLKVector2)aSize
                minTextureCoords:(GLKVector2)minCoords
                maxTextureCoords:(GLKVector2)maxCoords;

- (void)updateWithEyePosition:(GLKVector3)eyePosition
                lookDirection:(GLKVector3)lookDirection;

@end

extern NSComparisonResult UtilityCompareBillboardDistance(UtilityBillboard *a, UtilityBillboard *b, void *context);


NS_ASSUME_NONNULL_END
