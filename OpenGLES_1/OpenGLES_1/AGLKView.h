//
//  AGLKView.h
//  OpenGLES_1
//
//  Created by luowailin on 2019/5/31.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/ES3/gl.h>


NS_ASSUME_NONNULL_BEGIN
@class AGLKView, EAGLContext;
@protocol AGLKViewDelegate <NSObject>

- (void)glkView:(AGLKView *)view drawinRect:(CGRect)rect;

@end


@interface AGLKView : UIView{
    GLuint defaultFrameBuffer;
    GLuint colorRenderBuffer;
}

@property(nonatomic, weak) id<AGLKViewDelegate>delegate;
@property(nonatomic, strong) EAGLContext *context;

@property(nonatomic, assign) int drawableWidth;
@property(nonatomic, assign) int drawableHeight;

- (void)display;

@end

NS_ASSUME_NONNULL_END
