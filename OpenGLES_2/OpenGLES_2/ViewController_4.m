//
//  ViewController_4.m
//  OpenGLES_2
//
//  Created by luowailin on 2019/6/4.
//  Copyright © 2019 luowailin. All rights reserved.
//
//  多重纹理


#import "ViewController_4.h"
#import "AGLKContext.h"
#import "AGLKVertexAttribArrayBuffer.h"

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


@interface ViewController_4 ()

@property(nonatomic, strong) GLKBaseEffect *baseEffect;
@property(nonatomic, strong) AGLKVertexAttribArrayBuffer *vertexBuffer;

@end

@implementation ViewController_4

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]], @"no glkview");
    view.context = [[AGLKContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    [AGLKContext setCurrentContext:view.context];
    
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
    
    self.vertexBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:sizeof(SceneVertex)
                                                                 numberOfVertices:sizeof(vertices)/sizeof(SceneVertex)
                                                                             data:vertices
                                                                            usage:GL_STATIC_DRAW];
    
    CGImageRef imageRef0 = [[UIImage imageNamed:@"leaves.gif"] CGImage];
    GLKTextureInfo *textureInfo0 = [GLKTextureLoader textureWithCGImage:imageRef0
                                                                options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], GLKTextureLoaderOriginBottomLeft, nil]
                                                                  error:nil];
    self.baseEffect.texture2d0.name = textureInfo0.name;
    self.baseEffect.texture2d0.target = textureInfo0.target;
    
    CGImageRef imageRef1 = [[UIImage imageNamed:@"beetle.png"] CGImage];
    GLKTextureInfo *textureInfo1 = [GLKTextureLoader textureWithCGImage:imageRef1
                                                                options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], GLKTextureLoaderOriginBottomLeft, nil]
                                                                  error:nil];
    self.baseEffect.texture2d1.name = textureInfo1.name;
    self.baseEffect.texture2d1.target = textureInfo1.target;
    /**
     * GLKit的GLKEffectPropertyTexture类操作了3种常见的多重纹理模式:GLKTextureEnvModeReplace,GLKTextureEnvModeModulate,GLKTextureEnvModeDecal
     * 默认使用GLKTextureEnvModeModulate模式---这种模式几乎总是产生最好的结果    这种模式会让所有的为灯光和其他效果计算出来的颜色与从一个纹理取样的颜色相混合
     */
    self.baseEffect.texture2d1.envMode = GLKTextureEnvModeDecal; //混合模式
    
    /**
     * 现在GPU都能同时从至少两个纹理缓存中取样纹素 opengl 判断代码:
     GLint iUnits;
     glGetIntegerv(GL_MAX_TEXTURES_UNITS, &iUnits);
     *
     * GLKit的GLKBaseEffect类同时支持两种纹理。执行纹素取样和混合的硬件组件叫做一个纹理单元或者一个取样器
     *
     */
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
    
    [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord1
                           numberOfCoordinates:2
                                  attribOffset:offsetof(SceneVertex, textureCoords)
                                  shouldEnable:YES];
    
    [self.baseEffect prepareToDraw];
    
    [self.vertexBuffer drawArrayWithMode:GL_TRIANGLES
                        startVertexIndex:0
                        numberOfVertices:sizeof(vertices)/sizeof(SceneVertex)];
    
    //除了树叶和虫子纹理被混合在了一个通道中，而且与像素颜色渲染缓存的内容混合来产生结果片元颜色的过程只会在每次显示器更新中发生一次
}

- (void)dealloc{
    GLKView *view = (GLKView *)self.view;
    [AGLKContext setCurrentContext:view.context];
    
    self.vertexBuffer = nil;
    [EAGLContext setCurrentContext:nil];
}

@end
