//
//  AGLKView.m
//  OpenGLES_1
//
//  Created by luowailin on 2019/5/31.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "AGLKView.h"
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGL.h>

@implementation AGLKView

+ (Class)layerClass{
    return [CAEAGLLayer class];   //默认是CALayer
    /**
     * CAEAGLLayer 是Core Animation提供的标准层类之一。 CEALGLLayer会与一个OpenGL ES 的帧缓存共享它的像素颜色仓库
     */
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],
                                        kEAGLDrawablePropertyRetainedBacking,
                                        kEAGLColorFormatRGBA8,
                                        kEAGLDrawablePropertyColorFormat,
                                        nil];
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],
                                    kEAGLDrawablePropertyRetainedBacking,
                                    kEAGLColorFormatRGBA8,
                                    kEAGLDrawablePropertyColorFormat,
                                    nil];
}


- (instancetype)initWithFrame:(CGRect)frame context:(EAGLContext *)aContext
{
    self = [super initWithFrame:frame];
    if (self) {
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        //为了保存层中用到的OpenGL ES的帧缓存类型信息
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:NO], //NO 告诉Core Animation 在层的任何部分需要在屏幕上显示的时候都要绘制整个层的内容(也是告诉Core Animation不要试图保留任何以前绘制的图像留作以后重用)
                                        kEAGLDrawablePropertyRetainedBacking, //是否保留背景
                                        kEAGLColorFormatRGBA8, //8位保存
                                        kEAGLDrawablePropertyColorFormat,
                                        nil];
        self.context = aContext;
    }
    return self;
}

- (void)setContext:(EAGLContext *)aContext{
    if (self.context != aContext) {
        [EAGLContext setCurrentContext:self.context];
        if (defaultFrameBuffer != 0) {
            //删除帧缓存
            glDeleteFramebuffers(1, &defaultFrameBuffer);
            defaultFrameBuffer = 0;
        }
        
        if (colorRenderBuffer != 0) {
            glDeleteRenderbuffers(1, &colorRenderBuffer);
            colorRenderBuffer = 0;
        }
        
        if (aContext != nil) {
            [EAGLContext setCurrentContext:aContext];
            
            //创建帧缓存
            glGenFramebuffers(1, &defaultFrameBuffer);
            glBindFramebuffer(GL_FRAMEBUFFER, defaultFrameBuffer);
            
            //创建渲染缓存
            glGenRenderbuffers(1, &colorRenderBuffer);
            glBindRenderbuffer(GL_RENDERBUFFER, colorRenderBuffer);
            
            //附加上
            glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderBuffer);
        }
    }
    
}

- (EAGLContext *)context{
    return self.context;
}

- (void)display{
    [EAGLContext setCurrentContext:self.context];
    glViewport(0, 0, self.drawableWidth, self.drawableHeight);
    [self drawRect:self.bounds];
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)drawRect:(CGRect)rect{
    if (self.delegate) {
        [self.delegate glkView:self drawinRect:rect];
    }
}

/**
  任何在接收到视图重新调整大小的消息时，Cocoa Touch都会调用下面的-layoutSubviews方法。
  视图附属的帧缓存和像素颜色渲染缓存取决于视图的尺寸,视图会自动调整相关层的尺寸。
  上下文的'-renderbufferStorage:fromDrawable:'方法会调整视图的缓存的尺寸以匹配层的新尺寸
 */
- (void)layoutSubviews{
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    
    [self.context renderbufferStorage:GL_RENDERBUFFER
                         fromDrawable:eaglLayer];
    
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderBuffer);
    
    //检测帧缓冲的状态
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (status != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"failed to make complet frame buffer object status no ");
    }
}

- (int)drawableWidth{
    GLint backingWidth;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER,
                                 GL_RENDERBUFFER_WIDTH,
                                 &backingWidth);
    return (int)backingWidth;
}

- (int)drawableHeight{
    GLint backingHeight;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER,
                                 GL_RENDERBUFFER_HEIGHT,
                                 &backingHeight);
    return (int)backingHeight;
}

- (void)dealloc{
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
    
    self.context = nil;
}

@end
