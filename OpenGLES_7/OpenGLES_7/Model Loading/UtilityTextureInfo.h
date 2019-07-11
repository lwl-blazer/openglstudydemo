//
//  UtilityTextureInfo.h
//  OpenGLES_7
//
//  Created by luowailin on 2019/7/11.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import <GLKit/GLKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UtilityTextureInfo : NSObject<NSCoding>

@property(nonatomic, strong, readonly) NSDictionary *plist;
@property(nonatomic, strong, readwrite) id userInfo;

- (void)discardPlist;

@end

NS_ASSUME_NONNULL_END
