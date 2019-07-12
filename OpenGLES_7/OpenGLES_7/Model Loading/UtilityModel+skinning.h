//
//  UtilityModel+skinning.h
//  OpenGLES_7
//
//  Created by luowailin on 2019/7/12.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "UtilityModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface UtilityModel (skinning)

- (void)assignJoint:(NSUInteger)anIndex;

- (void)automaticallySkinRigidWithJoints:(NSArray *)joints;
- (void)automaticallySkinSmoothWithJoints:(NSArray *)joints;

@end

NS_ASSUME_NONNULL_END
