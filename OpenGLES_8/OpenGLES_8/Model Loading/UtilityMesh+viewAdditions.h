//
//  UtilityMesh+viewAdditions.h
//  OpenGLES_7
//
//  Created by luowailin on 2019/7/10.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "UtilityMesh.h"

NS_ASSUME_NONNULL_BEGIN

@interface UtilityMesh (viewAdditions)

- (void)prepareToDraw;
- (void)prepareToPick;
- (void)drawCommandsInRange:(NSRange)aRange;
- (void)drawBoundingBoxStringForCommandsInRange:(NSRange)aRange;

@end

NS_ASSUME_NONNULL_END
