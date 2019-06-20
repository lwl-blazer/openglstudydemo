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
    
    //初始化modelViewMatrix矩阵会使用一个明显的右上视角来渲染对象
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(30.0f),
                                                        1.0f,   //rotate x axis
                                                        0.0,
                                                        0.0);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix,
                                       GLKMathDegreesToRadians(-30.0),
                                       0.0,
                                       1.0,  //rotae y axis
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

/**
 * GLKBaseEffect中的transform属性是一个GLKEffectPropertyTransform类型的实例
 * GLKEffectPropertyTransform 为支持常见的操作保存了三个不同的矩阵:
     1.projectionMatrix   一个用于整个场景的坐标系
     2.modelviewMatrix   一个用于控制对旬(又叫做场景内模型)显示位置的坐标系
     3.modelviewProjectionMatrix    modelviewMatrix和projectionMatrix级联的结果 这个矩阵会把对象顶点完全地变换到OpenGL ES默认坐标系中。默认坐标系直接映射到像素颜色渲染缓存中的片元位置
 */
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    
    //正射投影
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
    
    //重新计算modelviewMatrix
    GLKMatrix4 savedModelviewMatrix = self.baseEffect.transform.modelviewMatrix;    //复制矩阵 用于参考的
    //用户控制的的三个变换矩阵  重新计算得到新的modelviewMatrix
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
    
    
    //绘制参考的图型
    self.baseEffect.transform.modelviewMatrix = savedModelviewMatrix;
    self.baseEffect.light0.diffuseColor = GLKVector4Make(1.0,
                                                         1.0,
                                                         0.0,
                                                         0.3);
    [self.baseEffect prepareToDraw];
    [AGLKVertexAttribArrayBuffer drawPreparedArraysWithMode:GL_TRIANGLES
                                           startVertexIndex:0
                                           numberOfVertices:lowPolyAxesAndModels2NumVerts];
    
    /**
     * 复制矩阵  ---- GLKit提供了一个方便的数据类型GLKMatrixStack   维护一个堆栈数据结构保存矩阵的函数集合。堆栈是一个后进先出的数据结果，它可以方便地存储某个程序可能需要恢复的矩阵。GLKMatrixStack会实现一个4 * 4矩阵的堆栈
     
     * GLKMatrixStackPush() 会复制最顶点的矩阵到堆栈的顶点。
     */
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

/**
 * 变换
 * 任意数量任意顺序的基本变换都能够被捕获并保存在一个简单的4乘4的浮点值矩阵中。一个矩阵定义一个坐标系，矩阵计算几乎完全使用加法和乘法
 *
 * 基本变换: 平移(translation) 旋转(rotation) 缩放(scale)和透视(perspective)
 *
 * 矩阵级联(concatenation) 又被称为矩阵乘法(matrix multiplication):
 *   使用一个矩阵把一个矢量或者顶点从一个坐标系变换到另一个的操作   GLKMatrix4Multiply()
 *
 * 透视
 *   通过相对于参考坐标系的坐标轴的单位长度多样化新坐标系的坐标轴的单位长度来定义一个新的坐标系。透视不会改变坐标轴的方向或者原点，但是坐标轴的每个单位离原点越远长度越短。这个效果会让在远处的物体比离原点近的物体显得更小
 *   GLKMatrix4MakeFrustum(float left, float right, float bottom, float top, float nearVal, float farVal)函数，  平截头体
 
 * 变换的顺序很重要
 */

static GLKMatrix4 SceneMatrixForTransform(SceneTransformationSelector type,
                                          SceneTransformationAxisSelector axis,
                                          float value){
    GLKMatrix4 result = GLKMatrix4Identity;
    
    switch (type) {
        case SceneRotate:{ //旋转 通过相对于参考坐标系坐标轴的方向旋转新坐标系的坐标轴来定义一个新坐标系。旋转的坐标系会与参考坐标系使用同一个原点。旋转不会影响坐标轴的单位长度，只有坐标轴的方向会发生变货
            switch (axis) {
                case SceneXAxis: //GLKMatrix4MakeRotation(angleRadians, x, y, z) x,y,z参数用于指定当前坐标系的哪一个轴作为旋转的轮毂  GLKMatrix4Rotate()会返回参数矩阵与GLKMatrix4MakeRotation()产生的新矩阵的级联
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
        case SceneScale:{ //缩放 通过相对于参考坐标系的坐标轴的单位长度改变新坐标系的坐标轴的单位长度来定义一个新坐标系。使用同一个原点，坐标轴的方向通常不会改变，不过一个负值也会改变方向的
            switch (axis) {
                case SceneXAxis: //GLKMatrix4MakeScale()   x,y,z参数指定了用来扩大或者缩小每个轴的单位长度的因子 GLKMatrix4Scale()会返回参数矩阵与GLKMatrix4MakeScale()产生的新矩阵的级联
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
        case SceneTranslate: //平移   平移不会影响坐标轴的单位长度，平移不会改变坐标轴相对于参考坐标系的方向
        default:{
            switch (axis) {
                case SceneXAxis://GLKMatrix4MakeRotation() x,y,z指定了新坐标系的原点沿着当前参考坐标系的每个轴移动的单位数   GLKMatrix4Translate会返回参数矩阵和GLKMatrix4MakeTranslation()产生新的矩阵的级联
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
