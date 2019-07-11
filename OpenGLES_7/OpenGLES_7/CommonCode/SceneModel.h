//
//  SceneModel.h
//  OpenGLES_6
//
//  Created by luowailin on 2019/6/25.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "AGLKAxisAllignedBoundingBox.h"

NS_ASSUME_NONNULL_BEGIN
@class AGLKVertexAttribArrayBuffer, SceneMesh;

@interface SceneModel : NSObject

@property(nonatomic, copy, readonly) NSString *name;
@property(nonatomic, assign, readonly) AGLKAxisAllignedBoundingBox axisAlignedBoundBox;

- (instancetype)initWithName:(NSString *)name
                        mesh:(SceneMesh *)aMesh
            numberOfVertices:(GLsizei)aCount;

- (void)draw;
- (void)updateAlignedBoundingBoxForVertices:(float *)verts
                                      count:(unsigned int)aCount;

@end

NS_ASSUME_NONNULL_END
