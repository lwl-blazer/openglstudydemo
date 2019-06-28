//
//  SceneCarModel.m
//  OpenGLES_6
//
//  Created by luowailin on 2019/6/25.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "SceneCarModel.h"
#import "SceneMesh.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "bumperCar.h"

/**
 * SceneCarModel是SceneModel的子类
 封装了一个碰碰车形状的网格，每个SceneCar实例都使用同一个SceneCarModel实例。如果想要碰碰车拥有不同的外形，那么就需要每个SceneCar实例使用一个不同的模型
 * 包括car的顶点数据和模型的基本属性，可以绘制Car模型
 */

@implementation SceneCarModel

- (instancetype)init{
    SceneMesh *carMesh = [[SceneMesh alloc] initWithPositionCoords:bumperCarVerts
                                                      normalCoords:bumperCarNormals
                                                        texCoords0:nil
                                                 numberOfPositions:bumperCarNumVerts
                                                           indices:nil
                                                   numberOfIndices:0];
    self = [super initWithName:@"bumberCar"
                          mesh:carMesh
              numberOfVertices:bumperCarNumVerts];
    if (self) {
        [self updateAlignedBoundingBoxForVertices:bumperCarVerts
                                            count:bumperCarNumVerts];
    }
    return self;
}



@end
