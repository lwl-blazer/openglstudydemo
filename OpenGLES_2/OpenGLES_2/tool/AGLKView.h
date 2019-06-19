//
//  AGLKView.h
//  OpenGLES_5
//
//  Created by luowailin on 2019/6/19.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>

typedef enum {
    AGLKViewDrawableDepthFormatNone = 0,
    AGLKViewDrawableDepthFormat16,
} AGLKViewDrawableDepthFormat;


NS_ASSUME_NONNULL_BEGIN
@class EAGLContext, AGLKView;
@protocol AGLKViewDelegate <NSObject>

@optional
- (void)glkView:(AGLKView *)view drawInRect:(CGRect)rect;

@end


@interface AGLKView : UIView
{
    EAGLContext *context;
    GLuint defaultFrameBuffer;
    GLuint colorRenderBuffer;
    GLuint depthRenderBuffer;
}

@property(nonatomic, strong) EAGLContext *context;
@property(nonatomic, assign, readonly) NSInteger drawableWidth;
@property(nonatomic, assign, readonly) NSInteger drawableHeight;
@property(nonatomic, assign) AGLKViewDrawableDepthFormat drawableDepthFormat;
@property(nonatomic, weak) id<AGLKViewDelegate>delegate;

- (void)display;

@end

NS_ASSUME_NONNULL_END
