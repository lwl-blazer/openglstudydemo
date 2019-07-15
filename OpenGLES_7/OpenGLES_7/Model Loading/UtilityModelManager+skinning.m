//
//  UtilityModelManager+skinning.m
//  OpenGLES_7
//
//  Created by luowailin on 2019/7/15.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "UtilityModelManager+skinning.h"
#import "UtilityMesh+skinning.h"

@implementation UtilityModelManager (skinning)

- (void)prepareToDrawWithJointInfluence{
    [self.consolidatedMesh prepareToDrawWithJointInfluence];
}

@end
