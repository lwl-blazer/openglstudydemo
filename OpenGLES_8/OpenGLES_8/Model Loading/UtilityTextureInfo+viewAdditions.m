//
//  UtilityTextureInfo+viewAdditions.m
//  OpenGLES_7
//
//  Created by luowailin on 2019/7/11.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "UtilityTextureInfo+viewAdditions.h"

@implementation GLKTextureInfo (utilityAdditions)

+ (GLKTextureInfo *)textureInfoFromUtilityPlistRepresention:(NSDictionary *)aDictionary{
    GLKTextureInfo *result = nil;
    
    const size_t imageWidth = (size_t)[[aDictionary objectForKey:@"width"] unsignedIntegerValue];
    const size_t imageHeight = (size_t)[[aDictionary objectForKey:@"height"] unsignedIntegerValue];
    
    UIImage *image = [UIImage imageWithData:[aDictionary objectForKey:@"imageData"]];
    
    if (image != nil && imageWidth != 0 && imageHeight != 0) {
        NSError *error;
        
        result = [GLKTextureLoader textureWithCGImage:[image CGImage]
                                              options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],
                                                      GLKTextureLoaderGenerateMipmaps,
                                                       [NSNumber numberWithBool:NO],
                                                       GLKTextureLoaderOriginBottomLeft,
                                                       [NSNumber numberWithBool:NO],
                                                       GLKTextureLoaderApplyPremultiplication,nil] error:&error];
        
        if (result == nil) {
            NSLog(@"%@", error);
        } else {
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST_MIPMAP_LINEAR);
            
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
        }
    }
    return result;
}

@end


@implementation UtilityTextureInfo (viewAdditions)


- (GLuint)name{
    if (self.userInfo == nil) {
        self.userInfo = [GLKTextureInfo textureInfoFromUtilityPlistRepresention:self.plist];
        
        [self discardPlist];
    }
    
    NSAssert([self.userInfo isKindOfClass:[GLKTextureInfo class]], @"Invalid userInfo");
    
    return [(GLKTextureInfo *)self.userInfo name];
}

- (GLenum)target{
    if (self.userInfo == nil) {
        self.userInfo = [GLKTextureInfo textureInfoFromUtilityPlistRepresention:self.plist];
        [self discardPlist];
    }
    
    NSAssert([self.userInfo isKindOfClass:[GLKTextureInfo class]],
             @"Invalid userInfo");
    
    return [(GLKTextureInfo *)self.userInfo target];
}

@end
