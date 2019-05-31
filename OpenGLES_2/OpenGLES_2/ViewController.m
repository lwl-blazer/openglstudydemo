//
//  ViewController.m
//  OpenGLES_2
//
//  Created by luowailin on 2019/5/31.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "ViewController.h"
#import "AGLKContext.h"
#import "AGLKVertexAttribArrayBuffer.h"

typedef struct{
    GLKVector3 positionCoords;
    GLKVector2 textureCoords;
}SceneVertex;

static const SceneVertex vertices[] = {
    {{-0.5f, -0.5f, 0.0f}, {0.0f, 0.0f}},
    {{ 0.5f, -0.5f, 0.0f}, {1.0f, 0.0f}},
    {{-0.5f,  0.5f, 0.0f}, {0.0f, 1.0f}}
};


@interface ViewController ()

@property(nonatomic, strong) AGLKVertexAttribArrayBuffer *vertexBuffer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]], @"View Controller view is not a GLKView");
    
    view.context = [[AGLKContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    [AGLKContext setCurrentContext:view.context];
    
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.useConstantColor = GL_TRUE;
    self.baseEffect.constantColor = GLKVector4Make(1.0f,
                                                   1.0f,
                                                   1.0f,
                                                   1.0f);
    
    ((AGLKContext *)(view.context)).clearColor = GLKVector4Make(0.0f,
                                                                0.0f,
                                                                0.0f,
                                                                1.0f);
    
    
    self.vertexBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:sizeof(SceneVertex)
                                                                 numberOfVertices:sizeof(vertices) / sizeof(SceneVertex)
                                                                             data:vertices usage:GL_STATIC_DRAW];
    
    CGImageRef imageRef = [[UIImage imageNamed:@"leaves.gif"] CGImage];
    
    //GLKTextureInfo 接受一个CGImageRef并创建一个新的包含CGImageRef的像素数据的OpenGL ES纹理缓存. 这个方法非常强大可以接收从一个电影的单个帧到由一个应用绘制的自定义的2D图像，再到一个图像文件的内容
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:imageRef
                                                               options:nil //options参数接受一个存储了用于指定GLKTextureLoader怎么解析加载的图像数据的键值对的NSDictionary.
                                                                 error:NULL];
    //GLKTextureInfo类封装了与刚创建纹理缓存相关的信息，包括它的尺寸以及它是否包含Mip贴图
    /**
     * GLKTextureLoader会自动调用glTexParameteri()方法来为创建的纹理缓存设置OpenGL ES取样和循环模式
     * 具体的信息参考书籍 第3章 55页
     *
     * GLKTextureLoader 支持异步纹理加载，MIP贴图生成，以及比简单的2D平面更加吸引人的纹理缓存类型
     *
     * GLKBaseEffect 提供了对于使用纹理做渲染的内建的支持
     */
    self.baseEffect.texture2d0.name = textureInfo.name;
    self.baseEffect.texture2d0.target = textureInfo.target;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    [self.baseEffect prepareToDraw];
    
    [((AGLKContext *)(view.context)) clear:GL_COLOR_BUFFER_BIT];
    
    /**
     * size_t offsetof(type, member-designator)   是一个C库宏   指一个结构成员(member-designator)相对于结构(type)开头的字节偏移量
     */
    [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition
                           numberOfCoordinates:3 attribOffset:offsetof(SceneVertex, positionCoords)
                                  shouldEnable:YES];
    
    [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord0
                           numberOfCoordinates:2
                                  attribOffset:offsetof(SceneVertex, textureCoords)
                                  shouldEnable:YES];
    
    [self.vertexBuffer drawArrayWithMode:GL_TRIANGLES
                        startVertexIndex:0
                        numberOfVertices:3];
}

/** 纹理
 * 大部分的OpenGL ES实现要么需要，要么受益于使用尺寸为2的幂的纹理。  2的幂包括 2^0 = 1, 2^1 = 2, 2^2 = 4, 2^3 = 8, 2^4 = 16, 2^5 = 32, 2^6=64, 2^7=128, 2^8=256, 2^9=512
 * 所以一个256 *256像素图片符合要求  一个4 * 64的纹理是有效的， 一个128*128的纹理可以工作良好， 一个200 * 200的纹理要么不工作，要么根据使用的OpenGL ES版本在渲染时导致效率低下，限制纹理的尺寸通常不会引起任何问题，
 */


- (void)dealloc{
    GLKView *view = (GLKView *)self.view;
    [EAGLContext setCurrentContext:view.context];
    
    if (self.vertexBuffer != nil) {
        self.vertexBuffer = nil;
    }
    
    [EAGLContext setCurrentContext:nil];
}

@end
