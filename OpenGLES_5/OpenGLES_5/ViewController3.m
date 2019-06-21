//
//  ViewController3.m
//  OpenGLES_5
//
//  Created by luowailin on 2019/6/20.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "ViewController3.h"
#import "AGLKTextureRotationBaseEffect.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "AGLKContext.h"

typedef struct {
    GLKVector3 positionCoords;
    GLKVector3 textureCoords;
} SceneVertex;

static const SceneVertex vertics[] = {
    {{-1.0f, -0.67f, 0.0f}, {0.0f, 0.0f}},  //first trian
    {{ 1.0f, -0.67f, 0.0f}, {1.0f, 0.0f}},
    {{-1.0f,  0.67f, 0.0f}, {0.0f, 1.0f}},
    {{ 1.0f, -0.67f, 0.0f}, {1.0f, 0.0f}}, //second triangle
    {{-1.0f,  0.67f, 0.0f}, {0.0f, 1.0f}},
    {{ 1.0f,  0.67f, 0.0f}, {1.0f, 1.0f}},
};

@interface ViewController3 ()

@property(nonatomic, strong) AGLKTextureRotationBaseEffect *baseEffect;
@property(nonatomic, strong) AGLKVertexAttribArrayBuffer *vertexBuffer;

@property(nonatomic, assign) float textureScaleFactor;
@property(nonatomic, assign) float textureAngle;
@property(nonatomic, assign) GLKMatrixStackRef textureMatrixStack;

@end

@implementation ViewController3

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textureMatrixStack = GLKMatrixStackCreate(kCFAllocatorDefault);
    self.textureScaleFactor = 1.0f;
    
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]], @"View Controller's view is not a GLKView");
    view.context = [[AGLKContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    
    [AGLKContext setCurrentContext:view.context];
    
    self.baseEffect = [[AGLKTextureRotationBaseEffect alloc] init];
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
                                                                 numberOfVertices:sizeof(vertics)/sizeof(SceneVertex)
                                                                             data:vertics
                                                                            usage:GL_STATIC_DRAW];
    
    CGImageRef imageRef0 = [[UIImage imageNamed:@"leaves.gif"] CGImage];
    
    GLKTextureInfo *textureInfo0 = [GLKTextureLoader textureWithCGImage:imageRef0
                                                                options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],
                                                                         GLKTextureLoaderOriginBottomLeft, nil]
                                                                  error:NULL];
    
    self.baseEffect.texture2d0.name = textureInfo0.name;
    self.baseEffect.texture2d0.target = textureInfo0.target;
    self.baseEffect.texture2d0.enabled = GL_TRUE;
    
    CGImageRef imageRef1 = [[UIImage imageNamed:@"bettle.png"] CGImage];
    GLKTextureInfo *textureInfo1 = [GLKTextureLoader textureWithCGImage:imageRef1
                                                                options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],
                                                                         GLKTextureLoaderOriginBottomLeft, nil]
                                                                  error:NULL];
    self.baseEffect.texture2d1.name = textureInfo1.name;
    self.baseEffect.texture2d1.target = textureInfo1.target;
    self.baseEffect.texture2d1.enabled = GL_TRUE;
    self.baseEffect.texture2d1.envMode = GLKTextureEnvModeDecal;
    
    [self.baseEffect.texture2d1 aglkSetParameter:GL_TEXTURE_WRAP_S
                                           value:GL_REPEAT];
    [self.baseEffect.texture2d1 aglkSetParameter:GL_TEXTURE_WRAP_T
                                           value:GL_REPEAT];
    
    GLKMatrixStackLoadMatrix4(self.textureMatrixStack,
                              self.baseEffect.textureMatrix2d1);

}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    
    [((AGLKContext *)view.context) clear:GL_COLOR_BUFFER_BIT];
    
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

    /**
     * 复制矩阵  ---- GLKit提供了一个方便的数据类型GLKMatrixStack   维护一个堆栈数据结构保存矩阵的函数集合。堆栈是一个后进先出的数据结果，它可以方便地存储某个程序可能需要恢复的矩阵。GLKMatrixStack会实现一个4 * 4矩阵的堆栈
     
     * GLKMatrixStackPush() 会复制最顶点的矩阵到堆栈的顶点。
     *
     * GLKit为修改矩阵堆栈顶部的矩阵蝗供了一个综合的函数集合，包括:
     * GLKMatrixStackMulitplyMatrix4()函数  --- 这个函数是其它函数的基础
     * GLKMatrixStackGetMatrix4() 函数会返回最顶部的矩阵
     * GLKMatrixStackPop()函数会移除堆栈最顶部的项，并把前一个顶部矩阵恢复到最顶部的位置
     */
    
    GLKMatrixStackPush(self.textureMatrixStack);
    //Scale and rotate about the center of the texture
    GLKMatrixStackTranslate(self.textureMatrixStack,
                            0.5,
                            0.5,
                            0.0);
    GLKMatrixStackScale(self.textureMatrixStack,
                        self.textureScaleFactor,
                        self.textureScaleFactor,
                        1.0);
    
    GLKMatrixStackRotate(self.textureMatrixStack,
                         GLKMathDegreesToRadians(self.textureAngle),
                         0.0, 0.0, 1.0);
    
    GLKMatrixStackTranslate(self.textureMatrixStack,
                            -0.5, -0.5, 0.0);
    
    self.baseEffect.textureMatrix2d1 = GLKMatrixStackGetMatrix4(self.textureMatrixStack);
    
    [self.baseEffect prepareToDrawMultitextures];
    
    [self.vertexBuffer drawArrayWithMode:GL_TRIANGLES
                        startVertexIndex:0
                        numberOfVertices:sizeof(vertics)/sizeof(SceneVertex)];
    
    GLKMatrixStackPop(self.textureMatrixStack);
    self.baseEffect.textureMatrix2d1 = GLKMatrixStackGetMatrix4(self.textureMatrixStack);
}

- (void)dealloc{
    GLKView *view = (GLKView *)self.view;
    [AGLKContext setCurrentContext:view.context];
    
    self.vertexBuffer = nil;
    [EAGLContext setCurrentContext:nil];
    
    CFRelease(self.textureMatrixStack);
    self.textureMatrixStack = NULL;
}


- (IBAction)takeTextureAngleFrom:(UISlider *)sender {
    self.textureScaleFactor = sender.value;
}

- (IBAction)takeTextureScaleFactorFrom:(UISlider *)sender {
    self.textureAngle = sender.value;
}


@end
