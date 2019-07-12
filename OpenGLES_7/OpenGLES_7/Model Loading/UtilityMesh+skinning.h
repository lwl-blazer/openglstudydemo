//
//  UtilityMesh+skinning.h
//  OpenGLES_7
//
//  Created by luowailin on 2019/7/12.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "UtilityMesh.h"

NS_ASSUME_NONNULL_BEGIN

typedef struct {
    GLKVector4 jointIndices;
    GLKVector4 jointWeights;
} UtilityMeshJointInfluence;

@interface UtilityMesh (skinning)

- (void)setJointInfluence:(UtilityMeshJointInfluence)vertexIndex;
- (void)prepareToDrawWithJointInfluence;

@end

NS_ASSUME_NONNULL_END
