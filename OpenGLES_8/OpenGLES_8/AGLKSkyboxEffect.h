//
//  AGLKSkyboxEffect.h
//  OpenGLES_8
//
//  Created by luowailin on 2019/7/17.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import <GLKit/GLKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AGLKSkyboxEffect : NSObject <GLKNamedEffect>

@property(nonatomic, assign) GLKVector3 center;
@property(nonatomic, assign) GLfloat xSize;
@property(nonatomic, assign) GLfloat ySize;
@property(nonatomic, assign) GLfloat zSize;

@property(nonatomic, strong, readonly) GLKEffectPropertyTexture *textureCubeMap;
@property(nonatomic, strong, readonly) GLKEffectPropertyTransform *transform;


- (void)prepareToDraw;
- (void)draw;

@end

NS_ASSUME_NONNULL_END
