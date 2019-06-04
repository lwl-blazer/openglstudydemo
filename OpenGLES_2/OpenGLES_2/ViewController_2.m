//
//  ViewController_2.m
//  OpenGLES_2
//
//  Created by luowailin on 2019/6/3.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "ViewController_2.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "AGLKContext.h"
#import "GLKEffectPropertyTexture+AGLKAdditions.h"

typedef struct {
    GLKVector3 positionCoords;
    GLKVector2 textureCoords;
}SceneVertex;

static SceneVertex vertices[] = {
    {{-0.5f, -0.5f, 0.0f}, {0.0f, 0.0f}},
    {{ 0.5f, -0.5f, 0.0f}, {1.0f, 0.0f}},
    {{-0.5f,  0.5f, 0.0f}, {0.0f, 1.0f}}
};

static const SceneVertex defaultVertices[] = {
    {{-0.5f, -0.5f, 0.0f}, {0.0f, 0.0f}},
    {{ 0.5f, -0.5f, 0.0f}, {1.0f, 0.0f}},
    {{-0.5f,  0.5f, 0.0f}, {0.0f, 1.0f}}
};

static GLKVector3 movementVectors[3] = {
    {-0.02f, -0.01f,  0.0f},
    { 0.01f, -0.005f, 0.0f},
    {-0.01f,   0.01f, 0.0f}
};

@interface ViewController_2 ()

@property(nonatomic, strong) GLKBaseEffect *baseEffect;
@property(nonatomic, strong) AGLKVertexAttribArrayBuffer *vertexBuffer;

@property(nonatomic, assign) BOOL shouldUseLinearFilter;
@property(nonatomic, assign) BOOL shouldAnimate;
@property(nonatomic, assign) BOOL shouldRepeatTexture;

@property(nonatomic, assign) GLfloat sCoordinateOffset;

@end

//纹理的取样模式、纹理的循环模式，以及当一个纹理被映射到顶点并修改在视口中的位置时的图像失真
@implementation ViewController_2

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.preferredFramesPerSecond = 60; //帧率
    self.shouldAnimate = YES;
    self.shouldRepeatTexture = YES;
    
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]], @"View Controller view is not GLKView");
    
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
                                                                             data:vertices usage:GL_DYNAMIC_DRAW];
    
    CGImageRef imageRef = [[UIImage imageNamed:@"grid"] CGImage];
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:imageRef
                                                               options:nil
                                                                 error:NULL];
    
    self.baseEffect.texture2d0.name = textureInfo.name;
    self.baseEffect.texture2d0.target = textureInfo.target;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    [self.baseEffect prepareToDraw];
    
    [((AGLKContext *)view.context) clear:GL_COLOR_BUFFER_BIT];
    
    [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition
                           numberOfCoordinates:3
                                  attribOffset:offsetof(SceneVertex, positionCoords)
                                  shouldEnable:YES];
    
    [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord0
                           numberOfCoordinates:2
                                  attribOffset:offsetof(SceneVertex, textureCoords)
                                  shouldEnable:YES];
    
    [self.vertexBuffer drawArrayWithMode:GL_TRIANGLES
                        startVertexIndex:0
                        numberOfVertices:3];
}

- (void)updateTextureParameters{
    //纹理的环绕方式
    [self.baseEffect.texture2d0 aglkSetParameter:GL_TEXTURE_WRAP_S
                                           value:(self.shouldRepeatTexture ? GL_REPEAT : GL_CLAMP_TO_EDGE)];
    //纹理过滤
    [self.baseEffect.texture2d0 aglkSetParameter:GL_TEXTURE_MAG_FILTER
                                           value:(self.shouldUseLinearFilter ? GL_LINEAR : GL_NEAREST)];
}

- (void)updateAnimatedVertexPositions{
    if (self.shouldAnimate) {
        int i;
        for (i = 0; i < 3; i++) {
            vertices[i].positionCoords.x += movementVectors[i].x;
            if (vertices[i].positionCoords.x >= 1.0f || vertices[i].positionCoords.x <= -1.0f) {
                movementVectors[i].x = -movementVectors[i].x;
            }
            
            vertices[i].positionCoords.y += movementVectors[i].y;
            if (vertices[i].positionCoords.y >= 1.0f || vertices[i].positionCoords.y <= -1.0f) {
                movementVectors[i].y = -movementVectors[i].y;
            }
            
            vertices[i].positionCoords.z += movementVectors[i].z;
            if (vertices[i].positionCoords.z >= 1.0f || vertices[i].positionCoords.z <= -1.0f) {
                movementVectors[i].z = -movementVectors[i].z;
            }
        }
    } else {
        int i;
        for (i = 0; i < 3; i++) {
            vertices[i].positionCoords.x = defaultVertices[i].positionCoords.x;
            vertices[i].positionCoords.y = defaultVertices[i].positionCoords.y;
            vertices[i].positionCoords.z = defaultVertices[i].positionCoords.z;
        }
    }
    
    {
        int i;
        for (i = 0; i < 3; i ++) {
            vertices[i].textureCoords.s = (defaultVertices[i].textureCoords.s + self.sCoordinateOffset);
        }
    }
}

- (void)update{
    //改变的数据
    [self updateAnimatedVertexPositions];
    [self updateTextureParameters];
    
    //重新绘制
    [self.vertexBuffer reinitWithAttribStride:sizeof(SceneVertex)
                             numberOfVertices:sizeof(vertices)/sizeof(SceneVertex)
                                        bytes:vertices];
}

- (IBAction)takeShouldUseLinearFilterFrom:(UISwitch *)sender {
    self.shouldUseLinearFilter = [sender isOn];
}

- (IBAction)takeShouldAnimateFrom:(UISwitch *)sender {
    self.shouldAnimate = [sender isOn];
}

- (IBAction)takeShouldRepeatTextureFrom:(UISwitch *)sender {
    self.shouldRepeatTexture = [sender isOn];
}

- (IBAction)takeSCoordinateOffsetFrom:(UISlider *)sender {
    self.sCoordinateOffset = [sender value];
}

- (void)dealloc{
    GLKView *view = (GLKView *)self.view;
    [AGLKContext setCurrentContext:view.context];
    
    self.vertexBuffer = nil;
    [EAGLContext setCurrentContext:nil];
}

@end
