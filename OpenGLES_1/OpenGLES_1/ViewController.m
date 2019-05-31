//
//  ViewController.m
//  OpenGLES_1
//
//  Created by luowailin on 2019/5/30.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "ViewController.h"

typedef struct {
    GLKVector3 positionCoords;
} SceneVertex;

static const SceneVertex vertices[] = {
    {{-0.5f, -0.5f, 0.0}},
    {{ 0.5f, -0.5f, 0.0}},
    {{-0.5f,  0.5f, 0.0}}
};

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]], @"not a GLKView");

    /**
     * OpenGL ES的上下文不仅会保存OpenGL ES的状态，还会控制GPU去执行渲染运算
     *
     * 在GLKViewController的-viewDidLoad方法会分配并初始化一个内建的EAGLContext类的实例，这个实例会封装一个特定于某个平台的OpenGL ES上下文
     */
    view.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    [EAGLContext setCurrentContext:view.context];
    
    //恒定不变的颜色来渲染三角形
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.useConstantColor = GL_TRUE;
    self.baseEffect.constantColor = GLKVector4Make(1.0f,   //Red
                                                   1.0f,    //Green
                                                   1.0f,  //Blue
                                                   1.0f);  //Alpha
    //在当前上下文储存背景颜色
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    
    glGenBuffers(1, &vertexBufferID);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferID);
    glBufferData(GL_ARRAY_BUFFER,
                 sizeof(vertices),    //要复制进这个缓存的字节的数量
                 vertices,   //地址
                 GL_STATIC_DRAW);   //缓存在未来的运算中可能将会被怎样使用
    /**
     * GL_STATIC_DRAW 提示会告诉上下文，缓存中的内容适合复制到GPU控制的内存，因为很少对其进行修改
     *
     * GL_DYNAMIC_DRAW 提示会告诉上下文，缓存内的数据会频繁改变，同时提示OpenGL ES以不同的方式来处理缓存的存储
     */
}

/**
 每当一个GLKView实例需要被被重绘时，它都会让保存在视图的上下文属性中的OpenGL ES的上下文成为当前上下文。如果需要的话，GLKView实例会绑定与一个Core Animation层分享的帧缓存，执行其他的标准OpenGL ES配置，并发送一个消息来调用这个代理方法
 */
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    [self.baseEffect prepareToDraw]; //准备好当前OpenGL ES 的上下文，以便为使用BaseEffect生成的属性和Shading Language程序的绘图做好准备
    
    glClear(GL_COLOR_BUFFER_BIT);  //GL_COLOR_BUFFER_BIT 有效地设置帧缓存中的每一个像素的颜色为背景色
    
    //启动
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    //设置指针    告诉OpenGL ES顶点数据在哪里，以及怎么解释为每个顶点保存的数据
    glVertexAttribPointer(GLKVertexAttribPosition,
                          3,
                          GL_FLOAT,
                          GL_FALSE,
                          sizeof(SceneVertex),    //‘步幅’--指定了每个顶点的保存需要多少个字节 步幅指定了GPU从一个顶点的内存开始位置转到下一个顶点的内存开位置需要跳过多少字节
                          NULL); //NULL OpenGL ES可以从当前绑定的顶点缓存的开始位置访问顶点数据
    //绘图
    glDrawArrays(GL_TRIANGLES,
                 0,
                 3);
}

- (void)dealloc{
    GLKView *view = (GLKView *)self.view;
    [EAGLContext setCurrentContext:view.context];
    
    if (vertexBufferID != 0) {
        glDeleteBuffers(1, &vertexBufferID);
        vertexBufferID = 0;
    }
    
    [EAGLContext setCurrentContext:nil];
}

@end
