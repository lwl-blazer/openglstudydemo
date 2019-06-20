//
//  ViewController2.m
//  OpenGLES_5
//
//  Created by luowailin on 2019/6/20.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "ViewController2.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "AGLKContext.h"
#import "lowPolyAxesAndModels2.h"

typedef enum {
    SceneTranslate = 0,
    SceneRotate,
    SceneScale,
} SceneTransformationSelector;

typedef enum {
    SceneXAxis = 0,
    SceneYAxis,
    SceneZAxis,
}SceneTransformationAxisSelector;

static GLKMatrix4 SceneMatrixForTransform(SceneTransformationSelector type,
                                          SceneTransformationAxisSelector axis,
                                          float value);

@interface ViewController2 ()

@property(nonatomic, assign) SceneTransformationSelector transform1Type;
@property(nonatomic, assign) SceneTransformationAxisSelector transform1Axis;

@property(nonatomic, assign) float transform1Value;

@property(nonatomic, assign) SceneTransformationSelector transform2Type;
@property(nonatomic, assign) SceneTransformationAxisSelector transform2Axis;
@property(nonatomic, assign) float transform2Value;

@property(nonatomic, assign) SceneTransformationSelector transform3Type;
@property(nonatomic, assign) SceneTransformationAxisSelector transform3Axis;
@property(nonatomic, assign) float transform3Value;

@property(nonatomic, strong) GLKBaseEffect *baseEffect;
@property(nonatomic, strong) AGLKVertexAttribArrayBuffer *vertexPositionBuffer;
@property(nonatomic, strong) AGLKVertexAttribArrayBuffer *vertexNormalValueBuffer;

@property (weak, nonatomic) IBOutlet UISlider *transform1ValueSlider;
@property (weak, nonatomic) IBOutlet UISlider *transform2ValueSlider;
@property (weak, nonatomic) IBOutlet UISlider *transform3ValueSlider;

@end

@implementation ViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]], @"View controller's view is not a GLKView");
    
    view.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    view.context = [[AGLKContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    [AGLKContext setCurrentContext:view.context];
    
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.light0.enabled = GL_TRUE;
    self.baseEffect.light0.ambientColor = GLKVector4Make(0.4,
                                                         0.4,
                                                         0.4,
                                                         1.0);
    self.baseEffect.light0.position = GLKVector4Make(1.0,
                                                     0.8,
                                                     0.4,
                                                     0.0);
    
    ((AGLKContext *)view.context).clearColor = GLKVector4Make(0.0f,
                                                              0.0f,
                                                              0.0f,
                                                              1.0f);
    
    self.vertexPositionBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:3 * sizeof(GLfloat)
                                                                         numberOfVertices:sizeof(lowPolyAxesAndModels2Verts)/(3 * sizeof(GLfloat))
                                                                                     data:lowPolyAxesAndModels2Verts
                                                                                    usage:GL_STATIC_DRAW];
    
    self.vertexNormalValueBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:3 * sizeof(GLfloat)
                                                                            numberOfVertices:sizeof(lowPolyAxesAndModels2Normals) / (3 * sizeof(GLfloat))
                                                                                        data:lowPolyAxesAndModels2Normals
                                                                                       usage:GL_STATIC_DRAW];
    
    [((AGLKContext *)view.context) enable:GL_DEPTH_TEST];
    
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(30.0f),
                                                        1.0f,
                                                        0.0,
                                                        0.0);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix,
                                       GLKMathDegreesToRadians(-30.0),
                                       0.0,
                                       1.0,
                                       0.0);
    
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix,
                                          -0.25,
                                          0.0,
                                          -0.20);
    
    self.baseEffect.transform.modelviewMatrix = modelViewMatrix;
    
    [((AGLKContext *)view.context) enable:GL_BLEND];
    [((AGLKContext *)view.context) setBlendSourceFunction:GL_SRC_ALPHA
                                      destinationFunction:GL_ONE_MINUS_SRC_ALPHA];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    const GLfloat aspectRatio = (GLfloat)view.drawableWidth / (GLfloat)view.drawableHeight;
    
    self.baseEffect.transform.projectionMatrix = GLKMatrix4MakeOrtho(-0.5 * aspectRatio,
                                                                     0.5 * aspectRatio,
                                                                     -0.5,
                                                                     0.5,
                                                                     -5.0,
                                                                     5.0);
    
    [((AGLKContext *)view.context) clear:GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT];
    
    [self.vertexPositionBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition
                                   numberOfCoordinates:3
                                          attribOffset:0
                                          shouldEnable:YES];
    
    [self.vertexNormalValueBuffer prepareToDrawWithAttrib:GLKVertexAttribNormal
                                      numberOfCoordinates:3
                                             attribOffset:0
                                             shouldEnable:YES];
    
    GLKMatrix4 savedModelviewMatrix = self.baseEffect.transform.modelviewMatrix;
    
    GLKMatrix4 newModelviewMatrix = GLKMatrix4Multiply(savedModelviewMatrix,
                                                       SceneMatrixForTransform(self.transform1Type,
                                                                               self.transform1Axis,
                                                                               self.transform1Value));
    
    newModelviewMatrix = GLKMatrix4Multiply(newModelviewMatrix,
                                            SceneMatrixForTransform(self.transform2Type,
                                                                    self.transform2Axis,
                                                                    self.transform2Value));
    
    newModelviewMatrix = GLKMatrix4Multiply(newModelviewMatrix,
                                            SceneMatrixForTransform(self.transform3Type,
                                                                    self.transform3Axis,
                                                                    self.transform3Value));
    
    self.baseEffect.transform.modelviewMatrix = newModelviewMatrix;
    
    self.baseEffect.light0.diffuseColor = GLKVector4Make(1.0f,
                                                         1.0f,
                                                         1.0f,
                                                         1.0f);
    
    [self.baseEffect prepareToDraw];
    
    [AGLKVertexAttribArrayBuffer drawPreparedArraysWithMode:GL_TRIANGLES
                                           startVertexIndex:0
                                           numberOfVertices:lowPolyAxesAndModels2NumVerts];
    
    self.baseEffect.transform.modelviewMatrix = savedModelviewMatrix;
    self.baseEffect.light0.diffuseColor = GLKVector4Make(1.0,
                                                         1.0,
                                                         0.0,
                                                         0.3);
    [self.baseEffect prepareToDraw];
    [AGLKVertexAttribArrayBuffer drawPreparedArraysWithMode:GL_TRIANGLES
                                           startVertexIndex:0
                                           numberOfVertices:lowPolyAxesAndModels2NumVerts];
    
}

- (void)dealloc{
    GLKView *view = (GLKView *)self.view;
    [AGLKContext setCurrentContext:view.context];
    
    self.vertexPositionBuffer = nil;
    self.vertexNormalValueBuffer = nil;
    
    [EAGLContext setCurrentContext:nil];
}

- (IBAction)takeTransform1TypeFrom:(UISegmentedControl *)sender {
    self.transform1Type = (SceneTransformationSelector)[sender selectedSegmentIndex];
}

- (IBAction)takeTransform1AxisFrom:(UISegmentedControl *)sender {
    self.transform1Axis = (SceneTransformationAxisSelector)[sender selectedSegmentIndex];
}

- (IBAction)takeTransform1ValueFrom:(UISlider *)sender {
    self.transform1Value = sender.value;
}

- (IBAction)takeTransform2TypeFrom:(UISegmentedControl *)sender {
    self.transform2Type = (SceneTransformationSelector)[sender selectedSegmentIndex];
}

- (IBAction)takeTransform2AxisFrom:(UISegmentedControl *)sender {
    self.transform2Axis = (SceneTransformationAxisSelector)[sender selectedSegmentIndex];
}

- (IBAction)takeTransform2ValueFrom:(UISlider *)sender {
    self.transform2Value = sender.value;
}

- (IBAction)takeTransform3TypeFrom:(UISegmentedControl *)sender {
    self.transform3Type = (SceneTransformationSelector)[sender selectedSegmentIndex];
}

- (IBAction)takeTransform3AxisFrom:(UISegmentedControl *)sender {
    self.transform3Axis = (SceneTransformationAxisSelector)[sender selectedSegmentIndex];
}

- (IBAction)takeTransform3ValueFrom:(UISlider *)sender {
    self.transform3Value = sender.value;
}

- (IBAction)resetIdentity:(UIButton *)sender {
    [self.transform1ValueSlider setValue:0.0];
    [self.transform2ValueSlider setValue:0.0];
    [self.transform3ValueSlider setValue:0.0];
    
    self.transform1Value = 0.0;
    self.transform2Value = 0.0;
    self.transform3Value = 0.0;
}


static GLKMatrix4 SceneMatrixForTransform(SceneTransformationSelector type,
                                          SceneTransformationAxisSelector axis,
                                          float value){
    GLKMatrix4 result = GLKMatrix4Identity;
    
    switch (type) {
        case SceneRotate:{
            switch (axis) {
                case SceneXAxis:
                    result = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(180 * value),
                                                    1.0,
                                                    0.0,
                                                    0.0);
                    break;
                case SceneYAxis:
                    result = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(180 * value),
                                                    0.0,
                                                    1.0,
                                                    0.0);
                    break;
                case SceneZAxis:
                default:
                    result = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(180 *value),
                                                    0.0,
                                                    0.0,
                                                    1.0);
                    break;
            }
        }
            break;
        case SceneScale:{
            switch (axis) {
                case SceneXAxis:
                    result = GLKMatrix4MakeScale(1.0 + value,
                                                 1.0,
                                                 1.0);
                    break;
                case SceneYAxis:
                    result = GLKMatrix4MakeScale(1.0,
                                                 1.0 + value,
                                                 1.0);
                    break;
                case SceneZAxis:
                default:
                    result = GLKMatrix4MakeScale(1.0,
                                                 1.0,
                                                 1.0 + value);
                    break;
            }
        }
            break;
        default:{
            switch (axis) {
                case SceneXAxis:
                    result = GLKMatrix4MakeTranslation(0.3 * value,
                                                       0.0,
                                                       0.0);
                    break;
                case SceneYAxis:
                    result = GLKMatrix4MakeTranslation(0.0,
                                                       0.3 * value,
                                                       0.0);
                    break;
                case SceneZAxis:
                default:
                    result = GLKMatrix4MakeTranslation(0.0,
                                                       0.0,
                                                       0.3 * value);
                    break;
            }
        }
            break;
    }
    
    return result;
}
@end
