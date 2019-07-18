//
//  AGLKPointParticleEffect.h
//  OpenGLES_8
//
//  Created by luowailin on 2019/7/18.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import <GLKit/GLKit.h>

extern const GLKVector3 AGLKDefaultGravity;

NS_ASSUME_NONNULL_BEGIN

@interface AGLKPointParticleEffect : NSObject <GLKNamedEffect>

@property(nonatomic, assign) GLKVector3 gravity;
@property(nonatomic, assign) GLfloat elapsedSeconds;

@property(nonatomic, strong, readonly) GLKEffectPropertyTexture *texture2d0;
@property(nonatomic, strong, readonly) GLKEffectPropertyTransform *transform;


- (void)addParticleAtPosition:(GLKVector3)aPosition
                     velocity:(GLKVector3)aVelocity
                        force:(GLKVector3)aForce
                         size:(float)size
              lifeSpanSeconds:(NSTimeInterval)aSpan
          fadeDurationSeconds:(NSTimeInterval)aDuration;

- (void)prepareToDraw;
- (void)draw;

@end

NS_ASSUME_NONNULL_END
