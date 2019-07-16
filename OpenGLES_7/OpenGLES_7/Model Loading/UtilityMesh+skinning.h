//
//  UtilityMesh+skinning.h
//  OpenGLES_7
//
//  Created by luowailin on 2019/7/12.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "UtilityMesh.h"

NS_ASSUME_NONNULL_BEGIN

//用下面的结构来存储每个顶点关节索引和权重
typedef struct {
    GLKVector4 jointIndices;
    GLKVector4 jointWeights;
} UtilityMeshJointInfluence;
/** UtilityMeshJointInfluence
 * 每个顶点只会保存四个关节索引和四个关节权重。四个关节通常就足以产生一个逼真的蒙皮效果。
 *
 * 注意：多个关节可能被用来变形一个单独的网格。这些关节中的任何一个都可能潜在地影响网格中的一个单独顶点。每个顶点选择四个关节。虽然索引值通常是整数或者字节，但是关节索引是用GlKVector4数据结构中的四个浮点值来存储的。OpenGL ES 2.0 Shading Language 不能接收每个顶点的整数或者字节属性。这是大部分嵌入式GPU的一个限制
 *
 * OpenGL ES 2.0 Shading Language 会为将来的执行保留类型的名字，比如短整型和字节
 */



@interface UtilityMesh (skinning)

- (void)setJointInfluence:(UtilityMeshJointInfluence)aJointInfluence
                  atIndex:(GLsizei)vertexIndex;
- (void)prepareToDrawWithJointInfluence;

@end

NS_ASSUME_NONNULL_END
