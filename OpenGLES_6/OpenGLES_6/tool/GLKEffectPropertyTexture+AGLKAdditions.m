//
//  GLKEffectPropertyTexture+AGLKAdditions.m
//  OpenGLES_2
//
//  Created by luowailin on 2019/6/4.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "GLKEffectPropertyTexture+AGLKAdditions.h"

@implementation GLKEffectPropertyTexture (AGLKAdditions)

- (void)aglkSetParameter:(GLenum)parameterID
                   value:(GLint)value{
    glBindTexture(self.target, self.name);
    //OpenGL ES该怎样对纹理采样
    glTexParameteri(self.target,
                    parameterID,
                    value);
}

@end
