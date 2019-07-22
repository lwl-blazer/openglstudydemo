//
//  UtilityBillboardManager+viewAdditions.h
//  OpenGLES_8
//
//  Created by luowailin on 2019/7/22.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "UtilityBillboardManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface UtilityBillboardManager (viewAdditions)

- (void)drawWithEyePosition:(GLKVector3)eyePosition
              lookDirection:(GLKVector3)lookDirection
                   upVector:(GLKVector3)upVector;

@end

NS_ASSUME_NONNULL_END
