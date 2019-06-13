//
//  AGLKShader.h
//  OpenGLES_2
//
//  Created by luowailin on 2019/6/5.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import <GLKit/GLKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AGLKShader : NSObject

@property(nonatomic, assign) GLuint program;

- (instancetype)initWithShader:(NSString *)shaderName;

- (void)bindAttribute:(GLuint)location name:(NSString *)name;
- (int)getUniform:(NSString *)uniformName;

- (void)setMat4:(NSString *)name value:(float *)value;
- (void)setMat3:(NSString *)name value:(float *)value;
- (void)setInt:(NSString *)name value:(GLint)value;

- (void)useProgram;

@end

NS_ASSUME_NONNULL_END
