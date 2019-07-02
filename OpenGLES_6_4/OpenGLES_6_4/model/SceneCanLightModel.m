//
//  SceneCanLightModel.m
//  OpenGLES_6_4
//
//  Created by luowailin on 2019/7/1.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "SceneCanLightModel.h"
#import "SceneMesh.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "canLight.h"

@implementation SceneCanLightModel

- (instancetype)init
{
    SceneMesh *canLightMesh = [[SceneMesh alloc] initWithPositionCoords:canLightVerts
                                                           normalCoords:canLightNormals
                                                             texCoords0:NULL
                                                      numberOfPositions:canLightNumVerts
                                                                indices:NULL
                                                        numberOfIndices:0];
    
    self = [super initWithName:@"canLight"
                          mesh:canLightMesh
              numberOfVertices:canLightNumVerts];
    if (self) {
        [self updateAlignedBoundingBoxForVertices:canLightVerts
                                            count:canLightNumVerts];
    }
    return self;
}


@end
