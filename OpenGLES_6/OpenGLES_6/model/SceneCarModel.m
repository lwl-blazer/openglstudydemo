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
