//
//  UtilityBillboardManager.h
//  OpenGLES_8
//
//  Created by luowailin on 2019/7/22.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import <GLKit/GLKit.h>

NS_ASSUME_NONNULL_BEGIN

@class UtilityBillboard;
@interface UtilityBillboardManager : NSObject

@property(nonatomic, strong, readonly) NSArray *sortedBillboards;
@property(nonatomic, assign) BOOL shouldRenderSpherical;

- (void)updateWithEyePosition:(GLKVector3)eyePosition
                lookDirection:(GLKVector3)lookDirection;

- (void)addBillboard:(UtilityBillboard *)aBillboard;

- (void)addBillboardAtPosition:(GLKVector3)aPosition
                          size:(GLKVector2)aSize
              minTextureCoords:(GLKVector2)minCoords
              maxTextureCoords:(GLKVector2)maxCoords;

@end

NS_ASSUME_NONNULL_END
