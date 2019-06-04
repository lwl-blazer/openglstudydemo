//
//  ViewController_3.m
//  OpenGLES_2
//
//  Created by luowailin on 2019/6/4.
//  Copyright © 2019 luowailin. All rights reserved.
//  纹理混合

#import "ViewController_3.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "AGLKContext.h"

typedef struct {
    GLKVector3 positionCoords;
    GLKVector3 textureCoords;
} SceneVertex;

static const SceneVertex vertices[] = {
    {{-1.0f, -0.67f, 0.0f}, {0.0f, 0.0f}}, //first triangle
    {{ 1.0f, -0.67f, 0.0f}, {1.0f, 0.0f}},
    {{-1.0f,  0.67f, 0.0f}, {0.0f, 1.0f}},
    {{ 1.0f, -0.67f, 0.0f}, {1.0f, 0.0f}}, //second triangle
    {{-1.0f,  0.67f, 0.0f}, {0.0f, 1.0f}},
    {{ 1.0f,  0.67f, 0.0f}, {1.0f, 1.0f}},
};

@interface ViewController_3 ()

@property(nonatomic, strong) GLKBaseEffect *baseEffect;
@property(nonatomic, strong) AGLKVertexAttribArrayBuffer *vertexBuffer;
@property(nonatomic, strong) GLKTextureInfo *textureInfo0;
@property(nonatomic, strong) GLKTextureInfo *textureInfo1;

@end

@implementation ViewController_3

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //EAGLContext设置
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]], @"View controller's view is not a GLKView");
    view.context = [[AGLKContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    [AGLKContext setCurrentContext:view.context];
    
    //GLKEffectBase的设置
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.useConstantColor = GL_TRUE;
    self.baseEffect.constantColor = GLKVector4Make(1.0f,
                                                   1.0f,
                                                   1.0f,
                                                   1.0f);
    
    ((AGLKContext *)view.context).clearColor = GLKVector4Make(0.0f,
                                                              0.0f,
                                                              0.0f,
                                                              1.0f);
    
    //顶点
    self.vertexBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:sizeof(SceneVertex)
                                                                 numberOfVertices:sizeof(vertices)/sizeof(SceneVertex)
                                                                             data:vertices
                                                                            usage:GL_STATIC_DRAW];
    //GLKTextureLoaderOriginBottomLeft--YES 为了命令GLKit的GLKTextureLoader类垂直翻转图像数据，这个翻转可以抵消图像的原点与OpenGL ES标准原点之间的差异
    CGImageRef imageRef0 = [[UIImage imageNamed:@"leaves.gif"] CGImage];
    self.textureInfo0 = [GLKTextureLoader textureWithCGImage:imageRef0
                                                     options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],
                                                              GLKTextureLoaderOriginBottomLeft, nil]
                                                       error:NULL];
    
    CGImageRef imageRef1 = [[UIImage imageNamed:@"beetle.png"] CGImage];
    self.textureInfo1 = [GLKTextureLoader textureWithCGImage:imageRef1
                                                     options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],
                                                              GLKTextureLoaderOriginBottomLeft, nil]
                                                       error:NULL];
    
    //设置混合
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    [(AGLKContext *)view.context clear:GL_COLOR_BUFFER_BIT];
    
    [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition
                           numberOfCoordinates:3
                                  attribOffset:offsetof(SceneVertex, positionCoords)
                                  shouldEnable:YES];
    
    [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord0
                           numberOfCoordinates:2
                                  attribOffset:offsetof(SceneVertex, textureCoords)
                                  shouldEnable:YES];
    
    //第一次渲染
    self.baseEffect.texture2d0.name = self.textureInfo0.name;
    self.baseEffect.texture2d0.target = self.textureInfo0.target;
    [self.baseEffect prepareToDraw];
    [self.vertexBuffer drawArrayWithMode:GL_TRIANGLES
                        startVertexIndex:0
                        numberOfVertices:sizeof(vertices)/sizeof(SceneVertex)];
    
    //第二次渲染
    self.baseEffect.texture2d0.name = self.textureInfo1.name;
    self.baseEffect.texture2d0.target = self.textureInfo1.target;
    [self.baseEffect prepareToDraw];
    [self.vertexBuffer drawArrayWithMode:GL_TRIANGLES
                        startVertexIndex:0
                        numberOfVertices:sizeof(vertices)/sizeof(SceneVertex)];
    
    //第一次渲染使用了一个纹理 第二次使用了另一个，混合发生在每次被一个纹理着色的一个片元与在像素颜色渲染缓存中已存的像素颜色混合的时候。绘图顺序决定了哪一个纹理会出现在另一个之上
}

/**
 * 片元颜色与在像素颜色渲染缓存中现存的颜色相混合来实现，但是这个技术主要有两个缺点:
 * 1.每次更新时几何图形必须被渲染一到更多次
 * 2.混合函数需要从像素颜色渲染缓存读取颜色数据以便与片元颜色混合
 
 * 结果被写回帧缓存
 *
 * 每个纹理的像素颜色渲染缓存的颜色会被再次读取、混合、重写。通过多次读写像素颜色渲染缓存来创建一个最终的渲染像素的过程叫做多道通渲染
 * 内存访问限制了性能，因此多通道渲染是次优的
 *
 * 最优的方案是多重纹理
 */

- (void)dealloc{
    GLKView *view = (GLKView *)self.view;
    [AGLKContext setCurrentContext:view.context];
    
    self.vertexBuffer = nil;
    [EAGLContext setCurrentContext:nil];
}



@end
