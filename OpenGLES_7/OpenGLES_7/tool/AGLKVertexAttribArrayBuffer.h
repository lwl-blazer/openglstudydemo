//
//  AGLKVertexAttribArrayBuffer.h
//  OpenGLES_2
//
//  Created by luowailin on 2019/5/31.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import <GLKit/GLKit.h>

NS_ASSUME_NONNULL_BEGIN
//顶点数组缓存
@interface AGLKVertexAttribArrayBuffer : NSObject
{
    GLuint glName;
}
@property(nonatomic, readonly) GLsizeiptr bufferSizeBytes;
@property(nonatomic, readonly) GLsizeiptr stride;

+ (void)drawPreparedArraysWithMode:(GLenum)mode
                  startVertexIndex:(GLint)first
                  numberOfVertices:(GLsizei)count;

- (instancetype)initWithAttribStride:(GLsizeiptr)stride
          numberOfVertices:(GLsizei)count
                      data:(const GLvoid *)dataPtr
                     usage:(GLenum)usage;

- (instancetype)initWithAttribStride:(GLsizeiptr)stride
                    numberOfVertices:(GLsizei)count
                               bytes:(const GLvoid *)dataPtr
                               usage:(GLenum)usage;

- (void)prepareToDrawWithAttrib:(GLuint)index
            numberOfCoordinates:(GLint)count
                   attribOffset:(GLsizeiptr)offset
                   shouldEnable:(BOOL)shouldEnable;

- (void)drawArrayWithMode:(GLenum)mode
         startVertexIndex:(GLint)first
         numberOfVertices:(GLsizei)count;

- (void)reinitWithAttribStride:(GLsizeiptr)stride
              numberOfVertices:(GLsizei)count
                         bytes:(const GLvoid *)dataPtr;

@end

NS_ASSUME_NONNULL_END
