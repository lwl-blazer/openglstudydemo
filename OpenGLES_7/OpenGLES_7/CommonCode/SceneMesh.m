//
//  SceneMesh.m
//  OpenGLES_6
//
//  Created by luowailin on 2019/6/25.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "SceneMesh.h"
#import "AGLKVertexAttribArrayBuffer.h"

@interface SceneMesh ()

@property(nonatomic, strong, readwrite) AGLKVertexAttribArrayBuffer *vertexAttributeBuffer;
@property(nonatomic, assign, readwrite) GLuint indexBufferID;
@property(nonatomic, strong, readwrite) NSData *vertexData;
@property(nonatomic, strong, readwrite) NSData *indexData;

@end

/** 网格类
 * SceneMesh 类的存在是为了管理大量的顶点数据以及GPU控制的内存数据的坐标转换。
 * 网格(Mesh)就是共享顶点或者边，同时用于定义3D图形的三角形的一个集合
 * 通过AGLKVertexAttribArrayBuffer管理顶点数据，发送顶点数据到GPU,分配顶点数据内存，绘制顶点数据
 */
@implementation SceneMesh

- (instancetype)initWithVertexAttributeData:(NSData *)vertexAttributes
                                  indexData:(NSData *)indices{
    self = [super init];
    if (self) {
        self.vertexData = vertexAttributes;
        self.indexData = indices;
    }
    return self;
}

- (instancetype)initWithPositionCoords:(const GLfloat *)somePositions
                          normalCoords:(const GLfloat *)someNormals
                            texCoords0:(const GLfloat *)someTexCoords0
                     numberOfPositions:(size_t)countPositions
                               indices:(const GLushort *)someIndices
                       numberOfIndices:(size_t)countIndices{
    NSParameterAssert(NULL != somePositions);
    NSParameterAssert(NULL != someNormals);
    NSParameterAssert(countPositions > 0);
    
    
    NSMutableData *vertexAttributesData = [[NSMutableData alloc] init];
    NSMutableData *indicesData = [[NSMutableData alloc] init];
    
    [indicesData appendBytes:someIndices
                      length:countIndices * sizeof(GLushort)];
    //把顶点数据转换成二进制
    for (size_t i = 0; i < countPositions; i ++) {
        SceneMeshVertex currentVertex;
        currentVertex.position.x = somePositions[i * 3 + 0];
        currentVertex.position.y = somePositions[i * 3 + 1];
        currentVertex.position.z = somePositions[i * 3 + 2];
        
        currentVertex.normal.x = someNormals[i * 3 + 0];
        currentVertex.normal.y = someNormals[i * 3 + 1];
        currentVertex.normal.z = someNormals[i * 3 + 2];
        
        if (NULL != someTexCoords0) {
            currentVertex.texCoords0.s = someTexCoords0[i * 2 + 0];
            currentVertex.texCoords0.t = someTexCoords0[i * 2 + 1];
        } else {
            currentVertex.texCoords0.s = 0.0f;
            currentVertex.texCoords0.t = 0.0f;
        }
        
        [vertexAttributesData appendBytes:&currentVertex
                                   length:sizeof(currentVertex)];
    }
    
    return [self initWithVertexAttributeData:vertexAttributesData
                                   indexData:indicesData];
}

- (void)prepareToDraw{
    if (self.vertexAttributeBuffer == nil && [self.vertexData length] > 0) { //顶点数据还没送至GPU
        self.vertexAttributeBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:sizeof(SceneMeshVertex)
                                                                              numberOfVertices:(GLsizei)([self.vertexData length]/sizeof(SceneMeshVertex))
                                                                                          data:[self.vertexData bytes]
                                                                                         usage:GL_STATIC_DRAW];
        self.vertexData = nil;
    }
    
    if (self.indexBufferID == 0 && [self.indexData length] > 0) { //索引缓存
        glGenBuffers(1, &_indexBufferID);
        NSAssert(self.indexBufferID != 0, @"Failed to generate element array buffer");
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, self.indexBufferID);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, [self.indexData length], [self.indexData bytes], GL_STATIC_DRAW);
        self.indexData = nil;
        /**索引顶点提供了一个优化，这个优化可以消除奢侈的顶点数据复制。当使用索引顶点时，每个顶点只需要在内存中保存一次，无论有多少个三角形使用了这个顶点*/
    }
    
    [self.vertexAttributeBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition
                                    numberOfCoordinates:3
                                           attribOffset:offsetof(SceneMeshVertex, position)
                                           shouldEnable:YES];
    
    [self.vertexAttributeBuffer prepareToDrawWithAttrib:GLKVertexAttribNormal
                                    numberOfCoordinates:3
                                           attribOffset:offsetof(SceneMeshVertex, normal)
                                           shouldEnable:YES];
    
    [self.vertexAttributeBuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord0
                                    numberOfCoordinates:2
                                           attribOffset:offsetof(SceneMeshVertex, texCoords0)
                                           shouldEnable:YES];
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, self.indexBufferID);
}

//不使用索引绘制
- (void)drawUnidexedWithMode:(GLenum)mode
            startVertexIndex:(GLint)first
            numberOfVertices:(GLsizei)count{
    [self.vertexAttributeBuffer drawArrayWithMode:mode
                                 startVertexIndex:first
                                 numberOfVertices:count];
}

//分配经常改动的内存
- (void)makeDynamicAndUpdateWithVertices:(const SceneMeshVertex *)someVerts
                        numberOfVertices:(size_t)count{
    NSParameterAssert(someVerts != NULL);
    NSParameterAssert(count > 0);
    
    if (self.vertexAttributeBuffer == nil) {
        self.vertexAttributeBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:sizeof(SceneMeshVertex)
                                                                              numberOfVertices:(GLsizei)count
                                                                                          data:someVerts
                                                                                         usage:GL_DYNAMIC_DRAW];
    } else {
        [self.vertexAttributeBuffer reinitWithAttribStride:sizeof(SceneMeshVertex)
                                          numberOfVertices:(GLsizei)count
                                                     bytes:someVerts];
    }
    
    /**
     * 向GPU控制的内存发送更新的顶点属性，并设置网格的使用提示为GL_DYNAMIC_DRAW来表明顶点属性可能会频繁更新
     *
     * 最大限度地减少复制发生的总量是非常重要的，因为内存带宽是嵌入式系统的头号瓶颈。避免复制的一个方法是直接在GPU控制的内存中使用运行在GPU上的一个Shading Language程序来计算新的顶点数据
     */
}


- (void)dealloc{
    if (self.indexBufferID != 0 ) {
        glDeleteBuffers(1, &_indexBufferID);
        self.indexBufferID = 0;
    }
}

@end
