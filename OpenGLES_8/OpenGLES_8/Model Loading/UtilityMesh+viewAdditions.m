//
//  UtilityMesh+viewAdditions.m
//  OpenGLES_7
//
//  Created by luowailin on 2019/7/10.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "UtilityMesh+viewAdditions.h"
#import "UtilityModelEffect.h"
#import <OpenGLES/ES3/glext.h>

@implementation UtilityMesh (viewAdditions)

- (void)prepareToDraw{
    if (vertexArrayID_ != 0) {
        //绑定顶点缓冲对象
        glBindVertexArray(vertexArrayID_);
    } else if (0 < [self.vertexData length]) { //只在第一次运行的时候，进行创建和绑定顶点、索引缓存数组
        
        if (self.shouldUseVAOExtension) { //顶点数组对象 VAO
            glGenVertexArrays(1, &vertexArrayID_);
            NSAssert(0 != vertexArrayID_, @"Unable to create VAO");
            glBindVertexArray(vertexArrayID_);
        }
        
        if (vertexBufferID_ == 0) {//顶点缓存对象 VBO
            glGenBuffers(1, &vertexBufferID_);
            NSAssert(vertexBufferID_ != 0, @"Failed to generate vertex array buffer");
            
            glBindBuffer(GL_ARRAY_BUFFER, vertexBufferID_);
            glBufferData(GL_ARRAY_BUFFER, [self.vertexData length],
                         [self.vertexData bytes], GL_STATIC_DRAW);
        } else {
            glBindBuffer(GL_ARRAY_BUFFER, vertexBufferID_);
        }

        glEnableVertexAttribArray(UtilityVertexAttribPosition);
        glVertexAttribPointer(UtilityVertexAttribPosition,
                              3,
                              GL_FLOAT,
                              GL_FALSE,
                              sizeof(UtilityMeshVertex),
                              (GLbyte *)NULL + offsetof(UtilityMeshVertex, position));
        
        glEnableVertexAttribArray(UtilityVertexAttribNormal);
        glVertexAttribPointer(UtilityVertexAttribNormal,
                              3,
                              GL_FLOAT,
                              GL_FALSE,
                              sizeof(UtilityMeshVertex),
                              (GLbyte *)NULL + offsetof(UtilityMeshVertex, normal));
        
        glEnableVertexAttribArray(UtilityVertexAttribTexCoord0);
        glVertexAttribPointer(UtilityVertexAttribTexCoord0,
                              2,
                              GL_FLOAT,
                              GL_FALSE,
                              sizeof(UtilityMeshVertex),
                              (GLbyte *)NULL + offsetof(UtilityMeshVertex, texCoords0));
        
        glEnableVertexAttribArray(UtilityVertexAttribTexCoord1);
        glVertexAttribPointer(UtilityVertexAttribTexCoord1,
                              2,
                              GL_FLOAT,
                              GL_FALSE,
                              sizeof(UtilityMeshVertex),
                              (GLbyte *)NULL + offsetof(UtilityMeshVertex, texCoords1));
    }
    
    //绑定索引缓冲对象
    if (indexBufferID_ != 0) {
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBufferID_);
    } else if (0 < [self.indexData length]) {
        glGenBuffers(1, &indexBufferID_);
        
        NSAssert(0 != indexBufferID_, @"Failed to generate element array buffer");
        
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER,
                     indexBufferID_);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER,
                     [self.indexData length],
                     [self.indexData bytes],
                     GL_STATIC_DRAW);
    }
}

- (void)prepareToPick{
    if (vertexBufferID_ == 0 && 0 < [self.vertexData length]) {
        glGenBuffers(1, &vertexBufferID_);
        NSAssert(0 != vertexBufferID_, @"Failed to generate vertex array buffer");
        
        glBindBuffer(GL_ARRAY_BUFFER, vertexBufferID_);
        glBufferData(GL_ARRAY_BUFFER, [self.vertexData length], [self.vertexData bytes], GL_STATIC_DRAW);
    } else {
        glBindBuffer(GL_ARRAY_BUFFER, vertexBufferID_);
    }
    
    glEnableVertexAttribArray(UtilityVertexAttribPosition);
    glVertexAttribPointer(UtilityVertexAttribPosition,
                          3,
                          GL_FLOAT,
                          GL_FALSE,
                          sizeof(UtilityMeshVertex),
                          (GLbyte *)NULL + offsetof(UtilityMeshVertex, position));
    
    glDisableVertexAttribArray(UtilityVertexAttribNormal);
    glDisableVertexAttribArray(UtilityVertexAttribTexCoord0);
    
    if (indexBufferID_ == 0 && [self.indexData length] > 0) {
        glGenBuffers(1, &indexBufferID_);
        NSAssert(indexBufferID_ != 0, @"Failed to generate element array buffer");
        
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, vertexBufferID_);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER,
                     [self.indexData length], [self.indexData bytes], GL_STATIC_DRAW);
        
    }else {
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, vertexBufferID_);
    }
}

//使用模型命令范围内的命令循环调用glDrawElements()函数
- (void)drawCommandsInRange:(NSRange)aRange{
    if (0 < aRange.length) {
        const NSUInteger lastCommandIndex = (aRange.location + aRange.length) - 1;
        
        NSParameterAssert(aRange.location < [self.commands count]);
        NSParameterAssert(lastCommandIndex < [self.commands count]);
        
        for (NSUInteger i = aRange.location; i <= lastCommandIndex; i ++) {
            NSDictionary *currentCommand = [self.commands objectAtIndex:i];
            
            const GLsizei numberOfIndices = (GLsizei)[[currentCommand objectForKey:@"numberOfIndices"] unsignedIntegerValue];
            
            const GLsizei firstIndex = (GLsizei)[[currentCommand objectForKey:@"firstIndex"] unsignedIntegerValue];
            
            GLenum model = (GLenum)[[currentCommand objectForKey:@"command"] unsignedIntegerValue];
            
            //EBO 索引缓冲对象:专门存储索引,OpenGL调用这些顶点的索引来决定绘制哪个顶点。
            glDrawElements(model,                    //绘制的模式 model = 4 也就是GL_TRIANGLES
                           (GLsizei)numberOfIndices, //绘制的顶点个数
                           GL_UNSIGNED_SHORT,        //索引的类型
                           (GLushort *)NULL + firstIndex);   //偏移量
        }
    }
}

- (void)drawBoundingBoxStringForCommandsInRange:(NSRange)aRange{
    if (0 < aRange.length) {
        const NSUInteger lastCommandIndex = (aRange.location + aRange.length) - 1;
        
        NSParameterAssert(aRange.location < [self.commands count]);
        NSParameterAssert(lastCommandIndex < [self.commands count]);
        
        const GLushort *indices = (const GLushort *)[self.indexData bytes];
        for (NSUInteger i = aRange.location; i <= lastCommandIndex; i ++) {
            NSDictionary *currentCommand = [self.commands objectAtIndex:i];
            
            size_t numberOfIndices = (size_t)[[currentCommand objectForKey:UtilityMeshCommandNumberOfIndices] unsignedIntegerValue];
            size_t firstIndex = (size_t)[[currentCommand objectForKey:UtilityMeshCommandFirstIndex] unsignedIntegerValue];
            
            glDrawElements(GL_LINE_STRIP,
                           (GLsizei)numberOfIndices,
                           GL_UNSIGNED_SHORT,
                           indices + firstIndex);
        }
    }
}

@end
