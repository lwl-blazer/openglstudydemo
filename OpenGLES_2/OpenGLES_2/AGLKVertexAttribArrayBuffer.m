//
//  AGLKVertexAttribArrayBuffer.m
//  OpenGLES_2
//
//  Created by luowailin on 2019/5/31.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "AGLKVertexAttribArrayBuffer.h"

@interface AGLKVertexAttribArrayBuffer ()

@property(nonatomic, readwrite) GLsizeiptr bufferSizeBytes;
@property(nonatomic, readwrite) GLsizeiptr stride;

@end


@implementation AGLKVertexAttribArrayBuffer

- (instancetype)initWithAttribStride:(GLsizeiptr)aStride
          numberOfVertices:(GLsizei)count
                      data:(const GLvoid *)dataPtr
                     usage:(GLenum)usage{
    NSParameterAssert(0 < aStride);
    NSParameterAssert(0 < count);
    NSParameterAssert(NULL != dataPtr);
    
    self = [super init];
    if (self) {
        self.stride = aStride;
        self.bufferSizeBytes = aStride * count;
        
        glGenBuffers(1, &glName);
        glBindBuffer(GL_ARRAY_BUFFER, glName);
        
        glBufferData(GL_ARRAY_BUFFER,
                     self.bufferSizeBytes,
                     dataPtr,
                     usage);
        
        NSAssert(0 != glName, @"Failed to generate glName");
    }
    return self;
}

- (void)prepareToDrawWithAttrib:(GLuint)index
            numberOfCoordinates:(GLint)count
                   attribOffset:(GLsizeiptr)offset
                   shouldEnable:(BOOL)shouldEnable{
    
    NSParameterAssert((0 < count) && (count < 4));
    NSParameterAssert(offset < self.stride);
    NSAssert(0 != glName, @"Invalid glName");
    
    glBindBuffer(GL_ARRAY_BUFFER, glName);
    
    if (shouldEnable) {
        glEnableVertexAttribArray(index);
    }
    
    glVertexAttribPointer(index,
                          count,
                          GL_FLOAT,
                          GL_FALSE,
                          (int)self.stride,
                          NULL + offset);
    
}

- (void)drawArrayWithMode:(GLenum)mode
         startVertexIndex:(GLint)first
         numberOfVertices:(GLsizei)count{
    NSAssert(self.bufferSizeBytes >= ((first + count) * self.stride), @"Attempt to draw more vertex data than available");
    glDrawArrays(mode, first, count);
}

- (void)dealloc{
    if (glName != 0) {
        glDeleteBuffers(1, &glName);
        glName = 0;
    }
}

@end
