//
//  SceneRinkModel.m
//  OpenGLES_6
//
//  Created by luowailin on 2019/6/25.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "SceneRinkModel.h"
#import "SceneMesh.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "bumperRink.h"

//SceneRinkModel是SceneModel的子类，代表了溜冰场的墙壁和地面的网格
@implementation SceneRinkModel

- (instancetype)init{
    SceneMesh *rinkMesh = [[SceneMesh alloc] initWithPositionCoords:bumperRinkVerts
                                                       normalCoords:bumperRinkNormals
                                                         texCoords0:NULL
                                                  numberOfPositions:bumperRinkNumVerts
                                                            indices:NULL
                                                    numberOfIndices:0];
    
    self = [super initWithName:@"bumberRink"
                          mesh:rinkMesh
              numberOfVertices:bumperRinkNumVerts];
    if (self) {
        [self updateAlignedBoundingBoxForVertices:bumperRinkVerts
                                            count:bumperRinkNumVerts];
    }
    return self;
}

@end
