//
//  UtilityTextureInfo+viewAdditions.h
//  OpenGLES_7
//
//  Created by luowailin on 2019/7/11.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "UtilityTextureInfo.h"
#import <GLKit/GLKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GLKTextureInfo (utilityAdditions)

+ (GLKTextureInfo *)textureInfoFromUtilityPlistRepresention:(NSDictionary *)aDictionary;

@end



@interface UtilityTextureInfo (viewAdditions)

@property(nonatomic, readonly, assign) GLuint name;
@property(nonatomic, readonly, assign) GLenum target;

@end

NS_ASSUME_NONNULL_END
