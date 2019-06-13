//
//  ViewController.m
//  OpenGLES_4
//
//  Created by luowailin on 2019/6/12.
//  Copyright © 2019 luowailin. All rights reserved.
//  光照 第一种渲染方式：利用GPU的能力为渲染场景中的每个单独的片元分别计算和应用灯光效果
//

#import "ViewController.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "AGLKContext.h"

typedef struct {
    GLKVector3 position;
    GLKVector3 normal;
}SceneVertex;


//一个三角形所需要的顶点结构体
typedef struct {
    SceneVertex vertices[3];
} SceneTriangle;

static const SceneVertex vertexA = {{-0.5, 0.5, -0.5}, {0.0, 0.0, 1.0}};

static const SceneVertex vertexB = {{-0.5, 0.0, -0.5}, {0.0, 0.0, 1.0}};

static const SceneVertex vertexC = {{-0.5, -0.5, -0.5}, {0.0, 0.0, 1.0}};

static const SceneVertex vertexD = {{0.0, 0.5, -0.5}, {0.0, 0.0, 1.0}};

static const SceneVertex vertexE = {{0.0, 0.0, -0.5}, {0.0, 0.0, 1.0}};

static const SceneVertex vertexF = {{0.0, -0.5, -0.5}, {0.0, 0.0, 1.0}};

static const SceneVertex vertexG = {{0.5, 0.5, -0.5}, {0.0, 0.0, 1.0}};

static const SceneVertex vertexH = {{0.5, 0.0, -0.5}, {0.0, 0.0, 1.0}};

static const SceneVertex vertexI = {{0.5, -0.5, -0.5}, {0.0, 0.0, 1.0}};

static SceneTriangle SceneTriangleMake(const SceneVertex vertexA,
                                      const SceneVertex vertexB,
                                      const SceneVertex vertexC);

static GLKVector3 SceneTriangleFaceNormal(SceneTriangle
                                           someTriangles);

static void SceneTrianglesUpdateFaceNormals(SceneTriangle someTriangles[8]);

static void SceneTrianglesUpdateVertexNormals(SceneTriangle someTriangles[8]);

static void SceneTrianglesNormalLinesUpdate(
                                            const SceneTriangle someTriangles[8],
                                            GLKVector3 lightPosition,
                                            GLKVector3 someNormalLineVertices[50]);

static GLKVector3 SceneVector3UnitNormal(const GLKVector3 vectorA,
                                         const GLKVector3 vectorB);


@interface ViewController (){
    SceneTriangle triangles[8]; //保存了8个三角形
}

@property(nonatomic, strong) GLKBaseEffect *baseEffect;
@property(nonatomic, strong) GLKBaseEffect *extraEffect;
@property(nonatomic, strong) AGLKVertexAttribArrayBuffer *vertexBuffer;
@property(nonatomic, strong) AGLKVertexAttribArrayBuffer *extraBuffer;

@property(nonatomic, assign) GLfloat centerVertexHeight;
@property(nonatomic, assign) BOOL shouldUseFaceNormals;
@property(nonatomic, assign) BOOL shouldDrawNormals;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]], @"View controller is not glkview");
    
    view.context = [[AGLKContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    [AGLKContext setCurrentContext:view.context];
    
    //本案例是按需重新计算法向量，但是大部分应用是预先计算法向量的或者从一个数据文件一起加载法向量和顶点位置信息
    //在一个或多个GLKBaseEffect的灯光被开启后，灯光决定了渲染的物体的颜色。GLKBaseEffect的常量颜色和所有的顶点颜色被忽略了
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.light0.enabled = GL_TRUE;  //开启光源
    self.baseEffect.light0.diffuseColor = GLKVector4Make(0.7f,
                                                         0.7f,
                                                         0.7f,
                                                         1.0f);  //设置漫反射光的颜色  灯光的镜面反射和环境颜色保持为GLKit的默认值
    self.baseEffect.light0.position = GLKVector4Make(1.0f,
                                                     1.0f,
                                                     0.5f,
                                                     0.0f); //光的位置  要用一个GLKVector4设置光源的位置,前三个元素要么是光源的x,y和z位置, 要么是指向一个无限远的光源的方向。 第四个元素指定前三个元素是一个位置(非0表示)还是一个方向(0表示) 如果是表位置的话，就有聚光灯的效果
    
    
    //用来绘制线段
    self.extraEffect = [[GLKBaseEffect alloc] init];
    self.extraEffect.useConstantColor = GL_TRUE;
    self.extraEffect.constantColor = GLKVector4Make(0.0f,
                                                    1.0f,
                                                    1.0f,
                                                    1.0f); //constantColor属性仅适用于渲染单调不发光的物体
    
    //模型视图矩阵 ---- 侧俯视角来渲染三角形  整个场景被旋转并定位以更容易地看到三角锥的高度变化 围绕着x和z轴做了变换
    {
        GLKMatrix4 modelViewMatrix = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(-60.0),    //尝试改变这个值的效果  以0度为分界线
                                                            1.0f,
                                                            0.0f,
                                                            0.0f);   //改变的是x值
        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix,
                                           GLKMathDegreesToRadians(-30.0),
                                           0.0f,
                                           0.0f,
                                           1.0f);
        
        
        modelViewMatrix = GLKMatrix4Translate(modelViewMatrix,
                                              0.0f,
                                              0.0f,
                                              0.25);
        
        self.baseEffect.transform.modelviewMatrix = modelViewMatrix;
        self.extraEffect.transform.modelviewMatrix = modelViewMatrix;
    } //这段代码产生了3D的效果
    
    ((AGLKContext *)view.context).clearColor = GLKVector4Make(0.0f,
                                                              0.0f,
                                                              0.0f,
                                                              1.0f);
    
    triangles[0] = SceneTriangleMake(vertexA, vertexB, vertexD);
    triangles[1] = SceneTriangleMake(vertexB, vertexC, vertexF);
    triangles[2] = SceneTriangleMake(vertexD, vertexB, vertexE);
    triangles[3] = SceneTriangleMake(vertexE, vertexB, vertexF);
    triangles[4] = SceneTriangleMake(vertexD, vertexE, vertexH);
    triangles[5] = SceneTriangleMake(vertexE, vertexF, vertexH);
    triangles[6] = SceneTriangleMake(vertexG, vertexD, vertexH);
    triangles[7] = SceneTriangleMake(vertexH, vertexF, vertexI);
    
    self.vertexBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:sizeof(SceneVertex)
                                                                 numberOfVertices:sizeof(triangles) / sizeof(SceneVertex)
                                                                             data:triangles
                                                                            usage:GL_DYNAMIC_DRAW];
    
    self.extraBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:sizeof(SceneVertex)
                                                                numberOfVertices:0
                                                                           bytes:NULL
                                                                           usage:GL_DYNAMIC_DRAW];
    
    self.centerVertexHeight = 0.0;
    self.shouldUseFaceNormals = NO;
}

- (IBAction)takeShouldUseFaceNormalsFrom:(UISwitch *)sender {
    self.shouldUseFaceNormals = sender.isOn;
}

- (IBAction)takeShouldDrawNormalsFrom:(UISwitch *)sender {
    self.shouldDrawNormals = sender.isOn;
}

- (IBAction)takeCenterVertexHeightFrom:(UISlider *)sender {
    self.centerVertexHeight = sender.value;
}

//改变高度
- (void)setCenterVertexHeight:(GLfloat)centerVertexHeight{
    _centerVertexHeight = centerVertexHeight;
    
    /**
     * 顶点E定义了三角锥的高度
     * 当顶点E上下移动的时，三角形2到5会改变
     */
    SceneVertex newVertexE = vertexE;
    newVertexE.position.z = self.centerVertexHeight;
    
    triangles[2] = SceneTriangleMake(vertexD, vertexB, newVertexE);
    triangles[3] = SceneTriangleMake(newVertexE, vertexB, vertexF);
    triangles[4] = SceneTriangleMake(vertexD, newVertexE, vertexH);
    triangles[5] = SceneTriangleMake(newVertexE, vertexF, vertexH);
    
    //当三角形的顶点发生变化的时候，法向量必须被重新计算， 这个重新计算是此案例中的关键部分
    [self updateNormals];
}


- (void)setShouldUseFaceNormals:(BOOL)shouldUseFaceNormals{
    if (shouldUseFaceNormals != self.shouldUseFaceNormals) {
        _shouldUseFaceNormals = shouldUseFaceNormals;
        [self updateNormals];
    }
}

//重新计算受影响后的法向量 ---- 此案例中的关键部分
- (void)updateNormals{
    if (self.shouldUseFaceNormals) {
        //使用平均法线(面法线)
        SceneTrianglesUpdateFaceNormals(triangles);
    } else {
        //使用顶点法线
        SceneTrianglesUpdateVertexNormals(triangles);
    }
    
    [self.vertexBuffer reinitWithAttribStride:sizeof(SceneVertex)
                             numberOfVertices:sizeof(triangles) / sizeof(SceneVertex)
                                        bytes:triangles];
}

//绘制法线(线条)
- (void)drawNormals{
    GLKVector3 normalLineVertices[50];
    
    //更新48个法向量顶点和两个灯光方向顶点
    SceneTrianglesNormalLinesUpdate(triangles,
                                    GLKVector3MakeWithArray(self.baseEffect.light0.position.v),
                                    normalLineVertices);
    
    
    [self.extraBuffer reinitWithAttribStride:sizeof(GLKVector3)
                            numberOfVertices:sizeof(normalLineVertices)
                                       bytes:normalLineVertices];

    [self.extraBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition
                          numberOfCoordinates:3
                                 attribOffset:0
                                 shouldEnable:YES];
    
    //法线
    [self.extraEffect prepareToDraw];
    [self.extraBuffer drawArrayWithMode:GL_LINES
                       startVertexIndex:0
                       numberOfVertices:48];
    
    //灯光的位置
    self.extraEffect.constantColor = GLKVector4Make(1.0, 1.0, 0.0, 1.0);
    [self.extraEffect prepareToDraw];
    [self.extraBuffer drawArrayWithMode:GL_LINES
                       startVertexIndex:48
                       numberOfVertices:2];
    
    /**
     * 摘自网络
     * 小思考:我们仅仅使用了顶点的法向量模拟灯光效果，那么相应的是不是可以给每个片元都缓存法向量呢，这样更加真实
     * 答:是可以的，这里的偏远计算，在每个RGB纹素编码的过程中加入x,y,z的法向量分量，这样的纹理叫法线贴图(或者叫凹凸贴图，DOT3灯光)
     */
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    [self.baseEffect prepareToDraw];
    
    [(AGLKContext *)view.context clear:GL_COLOR_BUFFER_BIT];
    
    [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition
                           numberOfCoordinates:3 attribOffset:offsetof(SceneVertex, position)
                                  shouldEnable:YES];
    
    //发送每个顶点的法向量给GPU
    [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribNormal
                           numberOfCoordinates:3
                                  attribOffset:offsetof(SceneVertex, normal)
                                  shouldEnable:YES];
    
    [self.vertexBuffer drawArrayWithMode:GL_TRIANGLES
                        startVertexIndex:0
                        numberOfVertices:sizeof(triangles) / sizeof(SceneVertex)];
    
    if (self.shouldDrawNormals) { //是否绘制线条
        [self drawNormals];
    }
}


#pragma mark - Triangle manipulation
//生成三角形
static SceneTriangle SceneTriangleMake(const SceneVertex vertexA,
                                      const SceneVertex vertexB,
                                      const SceneVertex vertexC){
    SceneTriangle result;
    result.vertices[0] = vertexA;
    result.vertices[1] = vertexB;
    result.vertices[2] = vertexC;
    return result;
}

//triangle 法向量
static GLKVector3 SceneTriangleFaceNormal(SceneTriangle
                                          someTriangles){
    
    //我们需要些什么来计算漫反射光照: 1.法向量(一个垂直于顶点表面的向量)  2.定向的光线(作为光的位置和片段的位置之间的向量差的方向向量。为了计算这个光线，我们需要光的位置向量和t片段的位置向量)
    GLKVector3 vectorA = GLKVector3Subtract(someTriangles.vertices[1].position,
                                            someTriangles.vertices[0].position);
    
    GLKVector3 vectorB = GLKVector3Subtract(someTriangles.vertices[2].position,
                                            someTriangles.vertices[0].position);
    
    return SceneVector3UnitNormal(vectorA, vectorB);
}

//显示光照--添加法向量
static void SceneTrianglesUpdateFaceNormals(SceneTriangle someTriangles[8]){
    for (int i = 0; i < 8; i ++) {
        GLKVector3 faceNormal = SceneTriangleFaceNormal(someTriangles[i]);
        someTriangles[i].vertices[0].normal = faceNormal;
        someTriangles[i].vertices[1].normal = faceNormal;
        someTriangles[i].vertices[2].normal = faceNormal;
    }
}

//使用顶点所包含的所有三角形的平均法向量
static void SceneTrianglesUpdateVertexNormals(SceneTriangle someTriangles[8]){
    SceneVertex newVertexA = vertexA;
    SceneVertex newVertexB = vertexB;
    SceneVertex newVertexC = vertexC;
    SceneVertex newVertexD = vertexD;
    SceneVertex newVertexE = someTriangles[3].vertices[0];
    SceneVertex newVertexF = vertexF;
    SceneVertex newVertexG = vertexG;
    SceneVertex newVertexH = vertexH;
    SceneVertex newVertexI = vertexI;
    
    GLKVector3 faceNormals[8];
    for (int i = 0; i < 8; i ++) {
        faceNormals[i] = SceneTriangleFaceNormal(someTriangles[i]);
    }
    
    //每个顶点的平均法向量
    newVertexA.normal = faceNormals[0];
    newVertexB.normal = GLKVector3MultiplyScalar(GLKVector3Add(GLKVector3Add(GLKVector3Add(faceNormals[0],
                                                                                     faceNormals[1]),
                                                                       faceNormals[2]),
                                                         faceNormals[3]),
                                           0.25f);
    
    newVertexC.normal = faceNormals[1];
    newVertexD.normal = GLKVector3MultiplyScalar(GLKVector3Add(GLKVector3Add(GLKVector3Add(faceNormals[0],
                                                                                           faceNormals[2]),
                                                                             faceNormals[4]),
                                                               faceNormals[6]),
                                                 0.25);
    
    newVertexE.normal = GLKVector3MultiplyScalar(GLKVector3Add(GLKVector3Add(GLKVector3Add(faceNormals[2],
                                                                                           faceNormals[3]),
                                                                             faceNormals[4]),
                                                               faceNormals[5]),
                                                 0.25);
    
    newVertexF.normal = GLKVector3MultiplyScalar(GLKVector3Add(GLKVector3Add(GLKVector3Add(faceNormals[1],
                                                                                           faceNormals[3]),
                                                                             faceNormals[5]),
                                                               faceNormals[7]),
                                                 0.25);
    
    newVertexG.normal = faceNormals[6];
    
    newVertexH.normal = GLKVector3MultiplyScalar(GLKVector3Add(GLKVector3Add(GLKVector3Add(faceNormals[4],
                                                                                           faceNormals[5]),
                                                                             faceNormals[6]),
                                                               faceNormals[7]),
                                                 0.25);
    
    newVertexI.normal = faceNormals[7];
    
    //更新triangles
    someTriangles[0] = SceneTriangleMake(newVertexA,
                                         newVertexB,
                                         newVertexD);
    someTriangles[1] = SceneTriangleMake(newVertexB,
                                         newVertexC,
                                         newVertexF);
    someTriangles[2] = SceneTriangleMake(newVertexD,
                                         newVertexB,
                                         newVertexE);
    someTriangles[3] = SceneTriangleMake(newVertexE,
                                         newVertexB,
                                         newVertexF);
    someTriangles[4] = SceneTriangleMake(newVertexD,
                                         newVertexE,
                                         newVertexH);
    someTriangles[5] = SceneTriangleMake(newVertexE,
                                         newVertexF,
                                         newVertexH);
    someTriangles[6] = SceneTriangleMake(newVertexG,
                                         newVertexD,
                                         newVertexH);
    someTriangles[7] = SceneTriangleMake(newVertexH,
                                         newVertexF,
                                         newVertexI);
}

//更新三角形法线 还有灯光方向线
static void SceneTrianglesNormalLinesUpdate(
                                            const SceneTriangle someTriangles[8],
                                            GLKVector3 lightPosition,
                                            GLKVector3 someNormalLineVertices[50]){ //为什么这里是50  8个三角形 每个三角形3个顶点  总共24个顶点  每条法线需要绘制起始和终止两个顶点，也就是48个数据源顶点，额外2个顶点用于绘制灯光方向
    int trianglesIndex;
    int lineVetexIndex = 0;
    
    //每条法向量的顶点确定，用于绘制法线
    for (trianglesIndex = 0; trianglesIndex < 8; trianglesIndex++) {
        someNormalLineVertices[lineVetexIndex++] = someTriangles[trianglesIndex].vertices[0].position;
        
        someNormalLineVertices[lineVetexIndex++] = GLKVector3Add(someTriangles[trianglesIndex].vertices[0].position,
                                                                 GLKVector3MultiplyScalar(someTriangles[trianglesIndex].vertices[0].normal, 0.5));
        
        someNormalLineVertices[lineVetexIndex++] = someTriangles[trianglesIndex].vertices[1].position;
        
        someNormalLineVertices[lineVetexIndex++] = GLKVector3Add(someTriangles[trianglesIndex].vertices[1].position,
                                                                 GLKVector3MultiplyScalar(someTriangles[trianglesIndex].vertices[1].normal,
                                                                                          0.5));
        
        someNormalLineVertices[lineVetexIndex++] = someTriangles[trianglesIndex].vertices[2].position;
        
        someNormalLineVertices[lineVetexIndex++] = GLKVector3Add(someTriangles[trianglesIndex].vertices[2].position,
                                                                 GLKVector3MultiplyScalar(someTriangles[trianglesIndex].vertices[2].normal,
                                                                                          0.5));
        
    }
    
    someNormalLineVertices[lineVetexIndex++] = lightPosition;
    
    someNormalLineVertices[lineVetexIndex] = GLKVector3Make(0.0,
                                                            0.0,
                                                            -0.5);
}

//单位法向量
static GLKVector3 SceneVector3UnitNormal(const GLKVector3 vectorA,
                                         const GLKVector3 vectorB){
    /**
     * 光线计算依赖于表面法向量(normal vector)  法向量也是单位向量(意味着一个法向量的大小(长度)总是1.0)
     *
     * GLKVector3Normalize() 转换成单位向量(也称为标准化操作) 内部实现原理:通过用这个矢量的长度(长度由标准距离公式得到)除了这个矢量的每个分量。结果是一个与原先的矢量方向相同的并且长度等于1.0的新矢量
     *
     *
     * 向量积:
     * GLKVector3CrossProduct()  叉乘  结果是一个向量(法向量) 叉乘只在3D空间中有定义，它需要两个不平行向量行为输入，生成一个正交于两个输入向量的第三个向量。如果输入的两个向量也是正交的，那么叉乘之后将会产生3个互相正交的向量。
     *
     * GLKVector3DotProduct()  点乘  几何意义:得到的是两个单位向量夹角的余弦值  b向量在a向量方向上的投影
     *
     * 注意:确保使用的都是单位向量(Unit Vector, 长度是1的向量)
     */
    return GLKVector3Normalize(GLKVector3CrossProduct(vectorA,
                                                      vectorB));
}


- (void)dealloc{
    GLKView *view = (GLKView *)self.view;
    [AGLKContext setCurrentContext:view.context];
    
    self.vertexBuffer = nil;
    [EAGLContext setCurrentContext:nil];
}


/** 冯氏光照模型
 * 灯光模拟由每个光源的三个截然不同的部分组成：
 * 1.环境光  --- 来自各个方向，因此同等增强所有几何图形的亮度，程序通过设置模拟环境光的颜色和亮度来设置场景中的背景灯光的基础水平
 * 2.漫反射光 --- 定向的，会基于三角形相对于光线的方向来照亮场景中的每个三角形。如果一个三角形的平面垂直于光线的方向，那么漫反射光会直接投射到三角形上
 * 3.镜面反射光  --- 从几何图形对象反射出来的光线 。 镜面物体会反射大量的光线，但是钝面的物体不会。 因此镜面反射光的感知亮度是由照射到每个三角形上的光线的量和三角形的反光度决定的
 
 * 所以一个渲染的三角形中的每个光线组成部分的效果取决于三个相互关联的因素：光线的设置、三角形相对于光线的方向，以及三角形的材质属性
 */


/** 面法线和顶点法线
 * 在3D世界中每一个顶点都有颜色，除了使用光源和物体的材质信息之外，还需要知道每个顶点的法向量，根据光照入射方向和法向量的夹角，计算顶点的最终颜色。
 *
 * 顶点法线: 每一个顶点都有法向量，就能知道光线到达物体表面的入射角
 * 面法线: 垂直一个平面的直线叫面法线
 *
 */

@end
