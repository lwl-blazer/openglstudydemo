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
        glBindVertexArray(vertexArrayID_);
    } else if (0 < [self.vertexData length]) {
        if (self.shouldUseVAOExtension) {
            glGenVertexArrays(1, &vertexArrayID_);
            NSAssert(0 != vertexArrayID_, @"Unable to create VAO");
            glBindVertexArray(vertexArrayID_);
        }
        
        if (vertexBufferID_ == 0) {
            glGenBuffers(1, &vertexBufferID_);
            NSAssert(vertexBufferID_ != 0, @"Failed to generate vertex array buffer");
            
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
            
            glDrawElements(model,
                           (GLsizei)numberOfIndices,
                           GL_UNSIGNED_SHORT,
                           (GLushort *)NULL + firstIndex);
        }
    }
}

- (void)drawBoundingBoxStringForCommandsInRange:(NSRange)aRange{
    if (0 < aRange.length) {
        const NSUInteger lastCommandIndex = (aRange.location + aRange.length) - 1;
        
        NSParameterAssert(aRange.location < [self.commands count]);
        NSParameterAssert(lastCommandIndex < [self.commands count]);
        
        const GLushort *indices = (const GLushort *)[self.indexData bytes];
        for (NSUInteger i = aRange.location; i < lastCommandIndex; i ++) {
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
