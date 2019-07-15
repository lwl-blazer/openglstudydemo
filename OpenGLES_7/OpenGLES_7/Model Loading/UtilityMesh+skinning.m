//
//  UtilityMesh+skinning.m
//  OpenGLES_7
//
//  Created by luowailin on 2019/7/12.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "UtilityMesh+viewAdditions.h"
#import "UtilityMesh+skinning.h"
#import "UtilityArmatureBaseEffect.h"

@implementation UtilityMesh (skinning)

//关节的权重和
- (void)setJointInfluence:(UtilityMeshJointInfluence)aJointInfluence atIndex:(GLsizei)vertexIndex{
    NSMutableData *jointControlsData = self.extraVertexData;
    
    if ([jointControlsData length] < (self.numberOfIndices * sizeof(UtilityMeshJointInfluence))) { //确保有足够的空间来存储关节的影响
        const UtilityMeshJointInfluence defaultInfluence = {{0, 0, 0, 0}, {1, 0, 0, 0}};
        //初始化UtilityMesh的extraVertexData，
        for (int i = 0; i < self.numberOfIndices; i++) {
            [jointControlsData appendBytes:&defaultInfluence
                                    length:sizeof(UtilityMeshJointInfluence)];
        }
    }
    
    NSParameterAssert(vertexIndex < self.numberOfIndices);
    UtilityMeshJointInfluence *jointControlsPtr = (UtilityMeshJointInfluence *)[jointControlsData mutableBytes];
    
    jointControlsPtr[vertexIndex] = aJointInfluence;
    
    
    /**
     如果GPU缓存中已经存在对关节控制的Buffer,这时，如果GPU要更新buffer的内容，最直接和简单的方法，删除当前的当前buffer 然后重新创建
     */
    if (vertexExtraBufferID_ != 0) {
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        glDeleteBuffers(1, &vertexExtraBufferID_);
        vertexExtraBufferID_ = 0;
    }
}

- (void)prepareToDrawWithJointInfluence{
    [self prepareToDraw];
    
    //额外添加了两个属性 UtilityMesh类会把关节信息保存在一个缓存中，并会以一个与其他每顶点属性相似的方向向GPU发送额外的值
    if (vertexArrayID_ == 0 || vertexExtraBufferID_ == 0) {
        
        if (vertexExtraBufferID_ == 0) {
            glGenBuffers(1, &vertexExtraBufferID_);
            NSAssert(vertexExtraBufferID_ != 0, @"Faile to generate vertex array buffer");
            
            glBindBuffer(GL_ARRAY_BUFFER, vertexExtraBufferID_);
            glBufferData(GL_ARRAY_BUFFER,
                         [self.extraVertexData length],
                         [self.extraVertexData bytes],
                         GL_STATIC_DRAW);
        } else {
            glBindBuffer(GL_ARRAY_BUFFER, vertexExtraBufferID_);
        }
        glEnableVertexAttribArray(UtilityArmatureVertexAttribJointMatrixIndices);
        glVertexAttribPointer(UtilityArmatureVertexAttribJointMatrixIndices,
                              4,
                              GL_FLOAT,
                              GL_FALSE,
                              sizeof(UtilityMeshJointInfluence),
                              (GLubyte *)NULL + offsetof(UtilityMeshJointInfluence, jointIndices));
        
        glEnableVertexAttribArray(UtilityArmatureVertexAttribJointNormalizedWeights);
        glVertexAttribPointer(UtilityArmatureVertexAttribJointNormalizedWeights,
                              4,
                              GL_FLOAT,
                              GL_FALSE,
                              sizeof(UtilityMeshJointInfluence),
                              (GLubyte *)NULL + offsetof(UtilityMeshJointInfluence, jointWeights));
    }
    
#ifdef DEBUG
    GLenum error = glGetError();
    if (GL_NO_ERROR != error) {
        NSLog(@"GL ERROR: 0x%x", error);
    }
#endif
}


@end
