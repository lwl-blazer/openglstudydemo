//
//  AGLKViewController.h
//  OpenGLES_5
//
//  Created by luowailin on 2019/6/19.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import <GLKit/GLKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AGLKViewController : UIViewController
{
    CADisplayLink *displayLink;
    NSInteger preferredFramesPerSecond;
}

@property(nonatomic, assign) NSInteger preferredFramesPerSecond;
@property(nonatomic, assign, readonly) NSInteger framesPerSecond;
@property(nonatomic, getter=isPaused, assign) BOOL paused;

@end

NS_ASSUME_NONNULL_END
