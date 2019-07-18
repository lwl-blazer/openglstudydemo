//
//  UtilityMesh.m
//  OpenGLES_7
//
//  Created by luowailin on 2019/7/10.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "UtilityMesh.h"
#import <OpenGLES/ES3/glext.h>

NSString *const UtilityMeshCommandNumberOfIndices = @"numberOfIndices";
NSString *const UtilityMeshCommandFirstIndex = @"firstIndex";

@interface UtilityMesh ()

@property(nonatomic, strong, readonly) NSMutableData *mutableVertexData;
@property(nonatomic, strong, readonly) NSMutableData *mutableIndexData;

@property(nonatomic, strong, readwrite) NSMutableData *extraVertexData;
@property(nonatomic, strong, readwrite) NSArray *commands;
@property(nonatomic, assign, readwrite) GLuint indexBufferID;
@property(nonatomic, assign, readwrite) GLuint vertexBufferID;
@property(nonatomic, assign, readwrite) GLuint vertexArrayID;

@end

@implementation UtilityMesh

- (instancetype)init{
    self = [super init];
    if (self) {
        _mutableVertexData = [[NSMutableData alloc] init];
        _mutableIndexData = [[NSMutableData alloc] init];
        
        self.commands = [NSArray array];
        _shouldUseVAOExtension = YES;
    }
    return self;
}

- (instancetype)initWithPlistRepresentation:(NSDictionary *)aDictionary{
    self = [self init];
    if (self) {
        [_mutableVertexData appendData:[aDictionary objectForKey:@"vertexAttributeData"]];  //顶点数据
        [_mutableIndexData appendData:[aDictionary objectForKey:@"indexData"]];  //索引数据
        self.commands = [self.commands arrayByAddingObjectsFromArray:[aDictionary objectForKey:@"commands"]]; //索引绘制用的数据   包括绘制模式 起始顶点  一次绘制的顶点个数
    }
    return self;
}

- (void)dealloc{
    glBindVertexArray(0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    
    if (vertexArrayID_ != 0) {
        glDeleteVertexArrays(1, &vertexArrayID_);
        vertexArrayID_ = 0;
    }
    
    if (vertexBufferID_ != 0) {
        glDeleteBuffers(1, &vertexBufferID_);
        vertexBufferID_ = 0;
    }
    
    if (indexBufferID_ != 0) {
        glDeleteBuffers(1, &indexBufferID_);
        indexBufferID_ = 0;
    }
}

- (NSDictionary *)plistRepresentation{
    return [NSDictionary dictionaryWithObjectsAndKeys:self.mutableVertexData, @"vertexAttributeData",
            self.mutableIndexData, @"indexData",
            self.commands, @"commands", nil];
}

- (NSMutableData *)extraVertexData{
    if (_extraVertexData == nil) {
        _extraVertexData = [NSMutableData data];
    }
    return _extraVertexData;
}

- (NSUInteger)numberOfVertices{
    return [self.vertexData length] / sizeof(UtilityMeshVertex);
}

- (NSString *)description{
    NSMutableString *result = [NSMutableString string];
    const NSUInteger count = [self numberOfVertices];
    
    for(int i = 0; i < count; i++)
    {
        UtilityMeshVertex currentVertex = [self vertexAtIndex:i];
        
        [result appendFormat:
         @"p{%0.2f, %0.2f, %0.2f} n{%0.2f, %0.2f, %0.2f}}\n",
         currentVertex.position.v[0],
         currentVertex.position.v[1],
         currentVertex.position.v[2],
         currentVertex.normal.v[0],
         currentVertex.normal.v[1],
         currentVertex.normal.v[2]];
        [result appendFormat:
         @" t0{%0.2f %0.2f}\n",
         currentVertex.texCoords0.v[0],
         currentVertex.texCoords0.v[1]];
    }
    
    return result;
}


- (NSUInteger)numberOfIndices{
    return (NSUInteger)([self.indexData length] / sizeof(GLushort));
}

- (NSData *)indexData{
    return self.mutableIndexData;
}

- (NSData *)vertexData{
    return self.mutableVertexData;
}

- (UtilityMeshVertex)vertexAtIndex:(NSUInteger)anIndex{
    NSParameterAssert(anIndex < [self numberOfVertices]);
    
    const UtilityMeshVertex *bytes = (const UtilityMeshVertex *)[self.vertexData bytes];
    
    return bytes[anIndex];
}

- (GLushort)indexAtIndex:(NSUInteger)anIndex{
    NSParameterAssert(anIndex < [self numberOfIndices]);
    
    const GLushort *bytes = (const GLushort *)[self.indexData bytes];
    
    return bytes[anIndex];
}


- (NSString *)axisAlignedBoundingBoxStringForCommandsInRange:(NSRange)aRange{
    GLfloat minCornerVertexPosition[3] = {0.0f, 0.0f, 0.0f};
    GLfloat maxCornerVertexPosition[3] = {0.0f, 0.0f, 0.0f};
    
    if (0 < aRange.length) {
        const NSUInteger lastCommandIndex = (aRange.location + aRange.length) - 1;
        
        NSParameterAssert(aRange.location < [self.commands count]);
        NSParameterAssert(lastCommandIndex < [self.commands count]);
        
        UtilityMeshVertex *vertexAttributes = (UtilityMeshVertex *)[self.vertexData bytes];
        
        BOOL hasFoundFirstVertex = NO;
        
        for (NSUInteger i = aRange.location; i < lastCommandIndex; i++) {
            NSDictionary *currentCommand = [self.commands objectAtIndex:i];
            
            size_t numberOfIndices = (size_t)[[currentCommand objectForKey:@"numberOfIndices"] unsignedIntegerValue];
            
            size_t firstIndex = (size_t)[[currentCommand objectForKey:@"firstIndex"] unsignedIntegerValue];
            
            GLushort *indices = (GLushort *)[self.indexData bytes];
            
            if (0 < numberOfIndices && !hasFoundFirstVertex) {
                hasFoundFirstVertex = YES;
                
                GLushort index = indices[0 + firstIndex];
                UtilityMeshVertex currentVertex = vertexAttributes[index];
                
                minCornerVertexPosition[0] = currentVertex.position.x;
                minCornerVertexPosition[1] = currentVertex.position.y;
                minCornerVertexPosition[2] = currentVertex.position.z;
                
                maxCornerVertexPosition[0] = currentVertex.position.x;
                maxCornerVertexPosition[1] = currentVertex.position.y;
                maxCornerVertexPosition[2] = currentVertex.position.z;
            }
            
            for (int j = 1; j < numberOfIndices; j ++) {
                GLushort index = indices[j + firstIndex];
                UtilityMeshVertex currentVertex = vertexAttributes[index];
                
                minCornerVertexPosition[0] = MIN(currentVertex.position.x, minCornerVertexPosition[0]);
                minCornerVertexPosition[1] = MIN(currentVertex.position.y,
                                                 minCornerVertexPosition[1]);
                minCornerVertexPosition[2] = MIN(currentVertex.position.z,
                                                 minCornerVertexPosition[2]);
                
                maxCornerVertexPosition[0] = MAX(currentVertex.position.x,
                                                 maxCornerVertexPosition[0]);
                maxCornerVertexPosition[1] = MAX(currentVertex.position.y,
                                                 maxCornerVertexPosition[1]);
                maxCornerVertexPosition[2] = MAX(currentVertex.position.z,
                                                 maxCornerVertexPosition[2]);
            }
        }
    }
    return [NSString stringWithFormat:
            @"{%0.2f, %0.2f, %0.2f},{%0.2f, %0.2f, %0.2f}",
            minCornerVertexPosition[0],
            minCornerVertexPosition[1],
            minCornerVertexPosition[2],
            maxCornerVertexPosition[0],
            maxCornerVertexPosition[1],
            maxCornerVertexPosition[2]];
}

- (NSString *)axisAlignedBoundingBoxString{
    NSRange allCommandsRange = {0, [self.commands count]};
    return [self axisAlignedBoundingBoxStringForCommandsInRange:allCommandsRange];
}

@end
