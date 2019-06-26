//
//  AGLKContext.h
//  OpenGLES_2
//
//  Created by luowailin on 2019/5/31.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import <GLKit/GLKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AGLKContext : EAGLContext{
    GLKVector4 clearColor;
}

@property(nonatomic, assign) GLKVector4 clearColor;

- (void)clear:(GLbitfield)mask;
- (void)enable:(GLenum)capability;
- (void)disable:(GLenum)capability;
- (void)setBlendSourceFunction:(GLenum)sfactor
           destinationFunction:(GLenum)dfactor;



@end

NS_ASSUME_NONNULL_END
