//
//  AGLKContext.m
//  OpenGLES_2
//
//  Created by luowailin on 2019/5/31.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "AGLKContext.h"

@implementation AGLKContext

- (void)setClearColor:(GLKVector4)clearColorRGBA{
    clearColor = clearColorRGBA;
    
    NSAssert(self == [[self class] currentContext], @"Receiving context required to be current context");
    
    glClearColor(clearColor.r,
                 clearColor.g,
                 clearColor.b,
                 clearColor.a);
}

- (GLKVector4)clearColor{
    return clearColor;
}

- (void)clear:(GLbitfield)mask{
    NSAssert(self == [[self class] currentContext], @"Receiving context required to be current context");
    
    glClear(mask);
}

- (void)enable:(GLenum)capability{
    NSAssert(self == [[self class] currentContext], @"Receiving context required to be current context");
    glEnable(capability);
}

- (void)disable:(GLenum)capability{
    NSAssert(self == [[self class] currentContext], @"Receiving context required to be current context");
    glDisable(capability);
}

- (void)setBlendSourceFunction:(GLenum)sfactor destinationFunction:(GLenum)dfactor{
    glBlendFunc(sfactor, dfactor);
}

@end
