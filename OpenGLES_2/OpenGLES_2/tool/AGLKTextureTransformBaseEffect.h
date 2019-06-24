//
//  AGLKTextureRotationBaseEffect.h
//  OpenGLES_5
//
//  Created by luowailin on 2019/6/20.
//  Copyright © 2019 luowailin. All rights reserved.
//


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


/*
//
//  AGLKTextureRotationBaseEffect.h
//
//

#import <GLKit/GLKit.h>

/////////////////////////////////////////////////////////////////
// This class extends GLKBaseEffect to enable use of separate
// texture matrices for each texture
//
// Use -prepareToDrawWithTextures to when using multi-texture
// with textureMatrix0 and textureMatrix1.
//
// Use -prepareToDraw to get the inherited behavior from
// GLKBaseEffect.
//
@interface AGLKTextureTransformBaseEffect : GLKBaseEffect

@property (assign) GLKVector4 light0Position;
@property (assign) GLKVector3 light0SpotDirection;
@property (assign) GLKVector4 light1Position;
@property (assign) GLKVector3 light1SpotDirection;
@property (assign) GLKVector4 light2Position;
@property (nonatomic, assign) GLKMatrix4 textureMatrix2d0;
@property (nonatomic, assign) GLKMatrix4 textureMatrix2d1;

- (void)prepareToDrawMultitextures;

@end


/////////////////////////////////////////////////////////////////
// Add convenience methods to GLKEffectPropertyTexture
//
// Use like
// [baseEffect.texture2d1 aglkSetParameter:GL_TEXTURE_WRAP_S
//    value:GL_REPEAT];
//
@interface GLKEffectPropertyTexture (AGLKAdditions)

- (void)aglkSetParameter:(GLenum)parameterID
                   value:(GLint)value;

@end

*/
