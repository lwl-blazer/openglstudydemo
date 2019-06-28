//
//  SceneAnimatedMesh.h
//  OpenGLES_6
//
//  Created by luowailin on 2019/6/27.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "SceneMesh.h"

NS_ASSUME_NONNULL_BEGIN

@interface SceneAnimatedMesh : SceneMesh

- (void)drawEntireMesh;
- (void)updateMeshWithDefaultPositions;
- (void)updateMeshWithElapsedTime:(NSTimeInterval)anInterval;

@end

NS_ASSUME_NONNULL_END
