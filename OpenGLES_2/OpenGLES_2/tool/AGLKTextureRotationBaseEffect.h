//
//  AGLKTextureRotationBaseEffect.h
//  OpenGLES_5
//
//  Created by luowailin on 2019/6/20.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import <GLKit/GLKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AGLKTextureRotationBaseEffect : GLKBaseEffect

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
