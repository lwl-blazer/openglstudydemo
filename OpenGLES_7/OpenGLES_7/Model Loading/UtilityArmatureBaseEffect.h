//
//  UtilityArmatureBaseEffect.h
//  OpenGLES_7
//
//  Created by luowailin on 2019/7/12.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import <GLKit/GLKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef enum {
    UtilityArmatureVertexAttribPosition = GLKVertexAttribPosition,
    UtilityArmatureVertexAttribNormal = GLKVertexAttribNormal,
    UtilityArmatureVertexAttribTexCoord0 = GLKVertexAttribTexCoord0,
    UtilityArmatureVertexAttribTexCoord1 = GLKVertexAttribTexCoord1,
    
    UtilityArmatureVertexAttribJointMatrixIndices,
    UtilityArmatureVertexAttribJointNormalizedWeights,
} UtilityArmatureVertexAttrib;


@interface UtilityArmatureBaseEffect : GLKBaseEffect

@property(nonatomic, assign) GLKVector4 light0Position;
@property(nonatomic, assign) GLKVector3 light0SpotDirection;
@property(nonatomic, assign) GLKVector4 light1Position;
@property(nonatomic, assign) GLKVector3 light1SpotDirection;
@property(nonatomic, assign) GLKVector4 light2Position;

@property(nonatomic, assign) GLKMatrix4 textureMatrix2d0;
@property(nonatomic, assign) GLKMatrix4 textureMatrix2d1;

@property(nonatomic, strong) NSArray *jointsArray;

- (void)prepareToDrawArmature;

@end

@interface GLKEffectPropertyTexture (AGLKAdditions)

- (void)aglkSetParameter:(GLenum)parameterID
                   value:(GLint)value;

@end


NS_ASSUME_NONNULL_END
