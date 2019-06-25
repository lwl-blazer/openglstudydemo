//
//  ViewController4.m
//  OpenGLES_5
//
//  Created by luowailin on 2019/6/24.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "ViewController4.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "AGLKContext.h"
#import "sphere.h"

@interface ViewController4 ()

@property(nonatomic, strong) GLKBaseEffect *baseEffect;
@property(nonatomic, strong) AGLKVertexAttribArrayBuffer *vertexPositionBuffer;
@property(nonatomic, strong) AGLKVertexAttribArrayBuffer *vertexNormalBuffer;
@property(nonatomic, strong) AGLKVertexAttribArrayBuffer *vertexTextureCoordBuffer;

@property(nonatomic, strong) GLKTextureInfo *earthTextureInfo;
@property(nonatomic, strong) GLKTextureInfo *moonTextureInfo;

@property(nonatomic, assign) GLKMatrixStackRef modelviewMatrixStack;
@property(nonatomic, assign) GLfloat earthRotationAngleDegrees;
@property(nonatomic, assign) GLfloat moonRotationAngleDegrees;

@end

@implementation ViewController4

//constants
static const GLfloat SceneEarthAxialTiltDeg = 23.5f;
static const GLfloat SceneDaysPerMoonOrbit = 28.0f;
static const GLfloat SceneMoonRadiusFractionOfEarth = 0.25;
static const GLfloat SceneMoonDistanceFromEarth = 3.0f;

- (void)configureLight{
    self.baseEffect.light0.enabled = GL_TRUE;
    self.baseEffect.light0.diffuseColor = GLKVector4Make(1.0f,
                                                         1.0f,
                                                         1.0f,
                                                         1.0f);
    self.baseEffect.light0.position = GLKVector4Make(1.0f,
                                                     0.0f,
                                                     0.8f,
                                                     0.0f);
    
    self.baseEffect.light0.ambientColor = GLKVector4Make(0.2f,
                                                         0.2f,
                                                         0.2f,
                                                         1.0f);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.modelviewMatrixStack = GLKMatrixStackCreate(kCFAllocatorDefault);
    
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]], @"view is not GLKView");
    view.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    
    view.context = [[AGLKContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    [AGLKContext setCurrentContext:view.context];
    
    self.baseEffect = [[GLKBaseEffect alloc] init];
    [self configureLight];
    
    self.baseEffect.transform.projectionMatrix = GLKMatrix4MakeOrtho(-1.0 * 4.0 / 3.0,
                                                                     1.0 * 4.0 / 3.0,
                                                                     -1.0,
                                                                     1.0,
                                                                     1.0,
                                                                     120.0);
    
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4MakeTranslation(0.0f,
                                                                          0.0f,
                                                                          -5.0f);
    
    ((AGLKContext *)view.context).clearColor = GLKVector4Make(0.0f,
                                                              0.0f,
                                                              0.0f,
                                                              1.0f);
    
    self.vertexPositionBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:3 * sizeof(GLfloat)
                                                                         numberOfVertices:sizeof(sphereVerts) / (3 * sizeof(GLfloat))
                                                                                     data:sphereVerts
                                                                                    usage:GL_STATIC_DRAW];
    
    self.vertexNormalBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:3 * sizeof(GLfloat)
                                                                       numberOfVertices:sizeof(sphereNormals)/(3 * sizeof(GLfloat))
                                                                                   data:sphereNormals
                                                                                  usage:GL_STATIC_DRAW];
    
    self.vertexTextureCoordBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:2 * sizeof(GLfloat)
                                                                             numberOfVertices:sizeof(sphereTexCoords)/(2 * sizeof(GLfloat))
                                                                                         data:sphereTexCoords
                                                                                        usage:GL_STATIC_DRAW];
    
    CGImageRef earthImageRef = [UIImage imageNamed:@"Earth512x256.jpg"].CGImage;
    self.earthTextureInfo = [GLKTextureLoader textureWithCGImage:earthImageRef
                                                         options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],
                                                                  GLKTextureLoaderOriginBottomLeft, nil]
                                                           error:NULL];
    
    CGImageRef moonImageRef = [UIImage imageNamed:@"Moon256x128.png"].CGImage;
    self.moonTextureInfo = [GLKTextureLoader textureWithCGImage:moonImageRef
                                                        options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],
                                                                 GLKTextureLoaderOriginBottomLeft, nil]
                                                          error:NULL];
    
    GLKMatrixStackLoadMatrix4(self.modelviewMatrixStack, self.baseEffect.transform.modelviewMatrix);
    self.moonRotationAngleDegrees = -20.0f;
}

- (void)drawEarth{
    self.baseEffect.texture2d0.name = self.earthTextureInfo.name;
    self.baseEffect.texture2d0.target = self.earthTextureInfo.target;
    
    GLKMatrixStackPush(self.modelviewMatrixStack);
    GLKMatrixStackRotate(self.modelviewMatrixStack,
                         GLKMathDegreesToRadians(SceneEarthAxialTiltDeg),
                         1.0,
                         0.0,
                         0.0);
    
    GLKMatrixStackRotate(self.modelviewMatrixStack,
                         GLKMathDegreesToRadians(self.earthRotationAngleDegrees),
                         0.0,
                         1.0,
                         0.0);
    self.baseEffect.transform.modelviewMatrix = GLKMatrixStackGetMatrix4(self.modelviewMatrixStack);
    
    [self.baseEffect prepareToDraw];
    [AGLKVertexAttribArrayBuffer drawPreparedArraysWithMode:GL_TRIANGLES
                                           startVertexIndex:0
                                           numberOfVertices:sphereNumVerts];
    
    GLKMatrixStackPop(self.modelviewMatrixStack);
    self.baseEffect.transform.modelviewMatrix = GLKMatrixStackGetMatrix4(self.modelviewMatrixStack);
}

- (void)drawMoon{
    self.baseEffect.texture2d0.name = self.moonTextureInfo.name;
    self.baseEffect.texture2d0.target = self.moonTextureInfo.target;
    
    GLKMatrixStackPush(self.modelviewMatrixStack);
    GLKMatrixStackRotate(self.modelviewMatrixStack,
                         GLKMathDegreesToRadians(self.moonRotationAngleDegrees),
                         0.0,
                         1.0,
                         0.0);
    GLKMatrixStackTranslate(self.modelviewMatrixStack,
                            0.0,
                            0.0,
                            SceneMoonDistanceFromEarth);
    
    GLKMatrixStackScale(self.modelviewMatrixStack,
                        SceneMoonRadiusFractionOfEarth,
                        SceneMoonRadiusFractionOfEarth,
                        SceneMoonRadiusFractionOfEarth);
    
    GLKMatrixStackRotate(self.modelviewMatrixStack,
                         GLKMathDegreesToRadians(self.moonRotationAngleDegrees),
                         0.0,
                         1.0,
                         0.0);
    
    self.baseEffect.transform.modelviewMatrix = GLKMatrixStackGetMatrix4(self.modelviewMatrixStack);
    
    [self.baseEffect prepareToDraw];
    [AGLKVertexAttribArrayBuffer drawPreparedArraysWithMode:GL_TRIANGLES
                                           startVertexIndex:0
                                           numberOfVertices:sphereNumVerts];
    
    GLKMatrixStackPop(self.modelviewMatrixStack);
    self.baseEffect.transform.modelviewMatrix = GLKMatrixStackGetMatrix4(self.modelviewMatrixStack);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    self.earthRotationAngleDegrees += 360.0f/60.0f;
    self.moonRotationAngleDegrees += (360.0f / 60.0f) / SceneDaysPerMoonOrbit;
    
    [((AGLKContext *)view.context) clear:GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT];
    
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
    
    [self drawEarth];
    [self drawMoon];
    
    [(AGLKContext *)view.context enable:GL_DEPTH_TEST];

}


- (void)dealloc{
    GLKView *view = (GLKView *)self.view;
    [AGLKContext setCurrentContext:view.context];
    
    self.vertexPositionBuffer = nil;
    self.vertexNormalBuffer = nil;
    self.vertexTextureCoordBuffer = nil;
    
    [EAGLContext setCurrentContext:nil];
    
    CFRelease(self.modelviewMatrixStack);
    self.modelviewMatrixStack = NULL;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return (interfaceOrientation !=
            UIInterfaceOrientationPortraitUpsideDown &&
            interfaceOrientation !=
            UIInterfaceOrientationPortrait);
}

/**
 * 透视和平截头体
 */
- (IBAction)takeShouldUsePerspectiveFrom:(UISwitch *)sender{
    GLfloat aspectRatio = (float)((GLKView *)self.view).drawableWidth / (float)((GLKView *)self.view).drawableHeight;
    
    if ([sender isOn]) {
        //平截头体
        self.baseEffect.transform.projectionMatrix = GLKMatrix4MakeFrustum(-1.0 * aspectRatio,
                                                                           1.0 * aspectRatio,
                                                                           -1.0,
                                                                           1.0,
                                                                           1.0,
                                                                           120.0);
    } else { //透视(正射投影)
        self.baseEffect.transform.projectionMatrix = GLKMatrix4MakeOrtho(-1.0 * aspectRatio,
                                                                         1.0 *aspectRatio,
                                                                         -1.0,
                                                                         1.0,
                                                                         1.0,
                                                                         120.0);
    }
}

@end
