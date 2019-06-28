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

- (void)drawEntireMesh; //利用glDrawElements()函数进行绘制
- (void)updateMeshWithDefaultPositions;
- (void)updateMeshWithElapsedTime:(NSTimeInterval)anInterval; //本例子的核心方法

@end

NS_ASSUME_NONNULL_END
