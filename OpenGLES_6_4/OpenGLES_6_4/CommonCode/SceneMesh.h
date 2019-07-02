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
}SceneMeshVertex; //顶点数据

@interface SceneMesh : NSObject

- (instancetype)initWithVertexAttributeData:(NSData *)vertexAttributes
                                  indexData:(NSData *)indices;

/**
 初始化
 * 顶点位置数组和顶点法线数组的大小 要大于countPositions
 * 位置和法线是 3 * GLfloat
 * 纹理是 2 * GLfloat
 * 索引是 1 * GLfloat

 @param somePositions 位置
 @param someNormals 法线
 @param someTexCoords0 纹理
 @param countPositions 顶点数量
 @param someIndices 索引
 @param countIndices 索引数量
 @return 网格
 */
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
