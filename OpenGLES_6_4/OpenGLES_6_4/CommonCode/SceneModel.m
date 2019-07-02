//
//  SceneModel.m
//  OpenGLES_6
//
//  Created by luowailin on 2019/6/25.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "SceneModel.h"
#import "SceneMesh.h"
#import "AGLKVertexAttribArrayBuffer.h"

@interface SceneModel ()

@property(nonatomic, strong, readwrite) SceneMesh *mesh;
@property(nonatomic, assign, readwrite) SceneAxisAllignedBoundingBox axisAlignedBoundBox;
@property(nonatomic, assign) GLsizei numberOfVertices;
@property(nonatomic, copy, readwrite) NSString *name;

@end

/** 模型类
 * SceneModel 类会绘制全部或者部分的网格。一个单独的模型可能由多个网格组成，多个模型可能共用相同的网格，模型代表了汽车、山脉或人物等3D对象，这些3D对象的形状由网格定义的。模型聚合了描绘3D对象所需的网格。
 */

@implementation SceneModel

- (instancetype)initWithName:(NSString *)name
                        mesh:(SceneMesh *)aMesh
            numberOfVertices:(GLsizei)aCount{
    self = [super init];
    if (self) {
        self.name = name;
        self.mesh = aMesh;
        self.numberOfVertices = aCount;
    }
    return self;
}

- (instancetype)init{
    return nil;
}

- (void)draw{
    [self.mesh prepareToDraw];
    [self.mesh drawUnidexedWithMode:GL_TRIANGLES
                   startVertexIndex:0
                   numberOfVertices:self.numberOfVertices];
}

//顶点数据改变后，重新计算边界
- (void)updateAlignedBoundingBoxForVertices:(float *)verts
                                      count:(unsigned int)aCount{
    SceneAxisAllignedBoundingBox result = {{0, 0, 0}, {0, 0, 0}};
    const GLKVector3 *positions = (const GLKVector3 *)verts;
    
    if (aCount > 0) {
        result.min.x = result.max.x = positions[0].x;
        result.min.y = result.max.y = positions[0].y;
        result.min.z = result.max.z = positions[0].y;
    }
    
    for (int i = 1; i < aCount; i ++) {
        result.min.x = MIN(result.min.x, positions[i].x);
        result.min.y = MIN(result.min.y, positions[i].y);
        result.min.z = MIN(result.min.z, positions[i].z);
        result.max.x = MAX(result.max.x, positions[i].x);
        result.max.y = MAX(result.max.y, positions[i].y);
        result.max.z = MAX(result.max.z, positions[i].z);
    }
    
    self.axisAlignedBoundBox = result;
}


@end
