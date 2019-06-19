//
//  ViewController.m
//  OpenGLES_5
//
//  Created by luowailin on 2019/6/19.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "ViewController.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "AGLKContext.h"
//#include "sphere.h"

@interface ViewController ()

@property(nonatomic, strong) GLKBaseEffect *baseEffect;
@property(nonatomic, strong) AGLKVertexAttribArrayBuffer *vertexPositionBuffer;
@property(nonatomic, strong) AGLKVertexAttribArrayBuffer *vertexNormalBuffer;
@property(nonatomic, strong) AGLKVertexAttribArrayBuffer *vertexTextureCoordBuffer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]], @"View Controller's view is not a GLKView");
    
    view.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    
    view.context = [[AGLKContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    [AGLKContext setCurrentContext:view.context];
    
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.light0.enabled = GL_TRUE;
    self.baseEffect.light0.diffuseColor = GLKVector4Make(0.7f,
                                                         0.7f,
                                                         0.7f,
                                                         1.0f);
    self.baseEffect.light0.ambientColor = GLKVector4Make(0.2f,
                                                         0.2f,
                                                         0.2f,
                                                         1.0f);
    self.baseEffect.light0.position = GLKVector4Make(1.0f,
                                                     0.0f,
                                                     -0.8f,
                                                     0.0f);
    
    CGImageRef imageRef = [[UIImage imageNamed:@"Earth512x256.jpg"] CGImage];
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:imageRef
                                                               options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],
                                                                        GLKTextureLoaderOriginBottomLeft, nil]
                                                                 error:NULL];
    self.baseEffect.texture2d0.name = textureInfo.name;
    self.baseEffect.texture2d0.target = textureInfo.target;
    
    ((AGLKContext *)view.context).clearColor = GLKVector4Make(0.0f,
                                                              0.0f,
                                                              0.0f,
                                                              1.0f);
    /*
    self.vertexPositionBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:3 * sizeof(GLfloat)
                                                                         numberOfVertices:sizeof(sphereVerts)/(3 * sizeof(GLfloat))
                                                                                     data:sphereVerts
                                                                                    usage:GL_STATIC_DRAW];
    
    self.vertexNormalBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:3 * sizeof(GLfloat)
                                                                       numberOfVertices:sizeof(sphereNormals) / (3 * sizeof(GLfloat))
                                                                                   data:sphereNormals
                                                                                  usage:GL_STATIC_DRAW];
    
    self.vertexTextureCoordBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:2 * sizeof(GLfloat)
                                                                             numberOfVertices:sizeof(sphereTexCoords) / (2 * sizeof(GLfloat))
                                                                                         data:sphereTexCoords
                                                                                        usage:GL_STATIC_DRAW];
    */
    [((AGLKContext *)view.context) enable:GL_DEPTH_TEST];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    [self.baseEffect prepareToDraw];
    
    [(AGLKContext *)view.context clear:GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT];
    
    [self.vertexPositionBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition
                                   numberOfCoordinates:3
                                          attribOffset:0
                                          shouldEnable:YES];
    
    [self.vertexNormalBuffer prepareToDrawWithAttrib:GLKVertexAttribNormal
                                 numberOfCoordinates:3
                                        attribOffset:0
                                        shouldEnable:YES];
    
    [self.vertexTextureCoordBuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord0
                                       numberOfCoordinates:2
                                              attribOffset:0
                                              shouldEnable:YES];
    
    
    
    const GLfloat aspectRatio = (GLfloat)view.drawableWidth / (GLfloat)view.drawableHeight; //计算屏幕纵横比 drawableWidth属性以像素为单位提供了视图的像素颜色渲染缓存的宽度，这个宽度与视图的全屏Core Animation层相匹配。沿着屏幕的x轴的可用像素的数量与沿着屏幕的y轴的可用像素的数量是不一样的
    //GLKMatrix4MakeScale() 创建一个基础的变换矩阵  指定一个值1.0意味着没有变化
    self.baseEffect.transform.projectionMatrix = GLKMatrix4MakeScale(1.0f, aspectRatio, 1.0f);
    
    /*[AGLKVertexAttribArrayBuffer drawPreparedArraysWithMode:GL_TRIANGLES
                                           startVertexIndex:0
                                           numberOfVertices:sphereNumVerts];*/
}

- (void)dealloc{
    GLKView *view = (GLKView *)self.view;
    [AGLKContext setCurrentContext:view.context];
    
    self.vertexPositionBuffer = nil;
    self.vertexNormalBuffer = nil;
    self.vertexTextureCoordBuffer = nil;
    
    [EAGLContext setCurrentContext:nil];
}

@end
