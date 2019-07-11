//
//  UtilityModel+viewAdditions.m
//  OpenGLES_7
//
//  Created by luowailin on 2019/7/11.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "UtilityModel+viewAdditions.h"
#import "UtilityMesh+viewAdditions.h"

@implementation UtilityModel (viewAdditions)

- (void)draw{
    [self.mesh drawCommandsInRange:NSMakeRange(self.indexOfFirstCommand, self.numberOfCommands)];
}

@end
