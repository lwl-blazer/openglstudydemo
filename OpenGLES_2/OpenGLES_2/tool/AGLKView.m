//
//  AGLKView.m
//  OpenGLES_5
//
//  Created by luowailin on 2019/6/19.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "AGLKView.h"
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGL.h>

@implementation AGLKView

+ (Class)layerClass{
    return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame context:(EAGLContext *)aContext{
    self = [super initWithFrame:frame];
    if (self) {
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],
                                        kEAGLDrawablePropertyRetainedBacking,
                                        kEAGLColorFormatRGBA8,
                                        kEAGLDrawablePropertyColorFormat, nil];
        
        self.context = aContext;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],
                                        kEAGLDrawablePropertyRetainedBacking,
                                        kEAGLColorFormatRGBA8,
                                        kEAGLDrawablePropertyColorFormat, nil];
    }
    return self;
}

- (void)setContext:(EAGLContext *)acontext{
    
    if (context != acontext) {
        [EAGLContext setCurrentContext:acontext];
        if (0 != defaultFrameBuffer) {
            glDeleteFramebuffers(1, &defaultFrameBuffer);
            defaultFrameBuffer = 0;
        }
        
        if (0 != colorRenderBuffer) {
            glDeleteRenderbuffers(1, &colorRenderBuffer);
            colorRenderBuffer = 0;
        }
        
        if (0 != depthRenderBuffer) {
            glDeleteRenderbuffers(1, &depthRenderBuffer);
            depthRenderBuffer = 0;
        }
        
        context = acontext;
        
        if (acontext != nil) {
            context = acontext;
            [EAGLContext setCurrentContext:acontext];
            
            //创建一个帧缓存
            glGenFramebuffers(1, &defaultFrameBuffer);
            glBindFramebuffer(GL_FRAMEBUFFER, defaultFrameBuffer);
            
            //纹理
            glGenRenderbuffers(1, &colorRenderBuffer);
            glBindRenderbuffer(GL_RENDERBUFFER, colorRenderBuffer);
            
            glFramebufferRenderbuffer(GL_FRAMEBUFFER,
                                      GL_COLOR_ATTACHMENT0,   //颜色附件 0表示可以有多个颜色附件
                                      GL_RENDERBUFFER,
                                      colorRenderBuffer);  //GL_COLOR_ATTACHMENT0  把纹理附加到帧缓冲上
            
            [self layoutSubviews];
        }
    }
}

- (EAGLContext *)context{
    return context;
}

- (void)display{
    [EAGLContext setCurrentContext:self.context];
    glViewport(0, 0, (GLsizei)self.drawableWidth, (GLsizei)self.drawableHeight);
    [self drawRect:[self bounds]];
    [self.context presentRenderbuffer:GL_RENDERBUFFER];   //展示、渲染的意思
}


- (void)drawRect:(CGRect)rect{
    if (self.delegate) {
        [self.delegate glkView:self drawInRect:[self bounds]];
    }
}

- (void)layoutSubviews{
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    [EAGLContext setCurrentContext:self.context];
    
    [self.context renderbufferStorage:GL_RENDERBUFFER
                         fromDrawable:eaglLayer];
    
    if (depthRenderBuffer != 0) {//如果深度缓存存在把它删除
        glDeleteRenderbuffers(1,
                              &depthRenderBuffer);
        depthRenderBuffer = 0;
    }
    
    GLint currentDrawableWidth = (GLint)self.drawableWidth;
    GLint currentDrawableHeight = (GLint)self.drawableHeight;
    
    if (self.drawableDepthFormat != AGLKViewDrawableDepthFormat16 && currentDrawableWidth > 0 && currentDrawableHeight > 0) {
        
        //step 1 创建一个深度渲染缓冲对象
        glGenRenderbuffers(1, &depthRenderBuffer);
        //step 2 绑定--告诉OpenGL ES在接下来的操作中使用哪一个缓存
        glBindRenderbuffer(GL_RENDERBUFFER,
                           depthRenderBuffer);
        //step 3 配置存储--指定深度缓存的大小
        glRenderbufferStorage(GL_RENDERBUFFER,
                              GL_DEPTH_COMPONENT16,
                              currentDrawableWidth,
                              currentDrawableHeight);    //我们将它创建为一个深度和模板附件渲染缓冲对象 GL_DEPTH_COMPONENT16    内部格式设置为GL_DEPTH_COMPONENT16    GL_DEPTH24_STENCIL8 深度和模板附件格式
        //step 4 附加深度缓存到一个帧缓存
        glFramebufferRenderbuffer(GL_FRAMEBUFFER,
                                  GL_DEPTH_ATTACHMENT,
                                  GL_RENDERBUFFER,
                                  depthRenderBuffer); //将渲染缓冲对象附加到帧缓冲的深度附件上  GL_DEPTH_STENCIL_ATTACHMENT深度和模板附件
    }
    
    //检查帧缓冲是否是完整的，
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (status != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"Faile to make complete frame buffer object %x", status);
    }
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderBuffer);   //
}

- (NSInteger)drawableWidth{
    GLint backingWidth;
    
    glGetRenderbufferParameteriv(GL_RENDERBUFFER,
                                 GL_RENDERBUFFER_WIDTH,
                                 &backingWidth);
    
    return (NSInteger)backingWidth;
}

- (NSInteger)drawableHeight{
    GLint backingHeight;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER,
                                 GL_RENDERBUFFER_HEIGHT,
                                 &backingHeight);
    return (NSInteger)backingHeight;
}

- (void)dealloc{
    if ([EAGLContext currentContext] == context) {
        [EAGLContext setCurrentContext:nil];
    }
    
    context = nil;
}


@end
