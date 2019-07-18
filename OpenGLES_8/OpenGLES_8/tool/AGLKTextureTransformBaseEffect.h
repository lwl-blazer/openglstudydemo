//
//  AGLKTextureRotationBaseEffect.h
//  OpenGLES_5
//
//  Created by luowailin on 2019/6/20.
//  Copyright © 2019 luowailin. All rights reserved.
//
/**
 * textureMatrix 纹理矩阵
 *
 * S和T坐标系的纹理与顶点的U和V坐标之间有一个映射，纹理矩阵会向这个映射施加变换
 */

#import <GLKit/GLKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AGLKTextureTransformBaseEffect : GLKBaseEffect

@property(nonatomic, assign) GLKVector4 light0Position;
@property(nonatomic, assign) GLKVector3 light0SpotDirection;

@property(nonatomic, assign) GLKVector4 light1Position;
@property(nonatomic, assign) GLKVector3 light1SpotDirection;

@property(nonatomic, assign) GLKVector4 light2Position;

@property(nonatomic, assign) GLKMatrix4 textureMatrix2d0;
@property(nonatomic, assign) GLKMatrix4 textureMatrix2d1;

- (void)prepareToDrawMultitextures;

@end


@interface GLKEffectPropertyTexture (AGLKAdditions)

- (void)aglkSetParameter:(GLenum)parameterID value:(GLint)value;

@end

NS_ASSUME_NONNULL_END
