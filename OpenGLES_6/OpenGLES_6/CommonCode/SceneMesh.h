//
//  SceneMesh.h
//  OpenGLES_6
//
//  Created by luowailin on 2019/6/25.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef struct {
    GLKVector3 position;
    GLKVector3 normal;
    GLKVector2 texCoords0;
}SceneMeshVertex;

@interface SceneMesh : NSObject

- (instancetype)initWithVertexAttributeData:(NSData *)vertexAttributes
                                  indexData:(NSData *)indices;

- (instancetype)initWithPositionCoords:(const GLfloat *)somePositions
                          normalCoords:(const GLfloat *)someNormals
                            texCoords0:(const GLfloat *)someTexCoords0
                     numberOfPositions:(size_t)countPositions
                               indices:(const GLushort *)someIndices
                       numberOfIndices:(size_t)countIndices;

- (void)prepareToDraw;
- (void)drawUnidexedWithMode:(GLenum)mode
            startVertexIndex:(GLint)first
            numberOfVertices:(GLsizei)count;
- (void)makeDynamicAndUpdateWithVertices:(const SceneMeshVertex *)someVerts
                        numberOfVertices:(size_t)count;

@end

NS_ASSUME_NONNULL_END
