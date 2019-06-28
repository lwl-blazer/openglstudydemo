//
//  SceneAnimatedMesh.m
//  OpenGLES_6
//
//  Created by luowailin on 2019/6/27.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "SceneAnimatedMesh.h"

#define NUM_MESH_ROWS (20)
#define NUM_MESH_COLUMNS (40)
#define NUM_MESH_TRIANGLES ((NUM_MESH_ROWS - 1) * (NUM_MESH_COLUMNS - 1) * 2)

#define NUM_MESH_INDICES (NUM_MESH_TRIANGLES + 2 + (NUM_MESH_COLUMNS - 2))

@interface SceneAnimatedMesh ()
{
    SceneMeshVertex mesh[NUM_MESH_COLUMNS][NUM_MESH_ROWS];
}

@end

static void SceneMeshInitIndices(GLushort meshIndices[NUM_MESH_INDICES]);
static void SceneMeshUpdateNormals(SceneMeshVertex mesh[NUM_MESH_COLUMNS][NUM_MESH_ROWS]);
static void SceneMeshUpdateMeshWithDefaultPositions(SceneMeshVertex mesh[NUM_MESH_COLUMNS][NUM_MESH_ROWS]);


@implementation SceneAnimatedMesh


- (instancetype)init
{
    //setup indices
    GLushort meshIndices[NUM_MESH_INDICES];
    SceneMeshInitIndices(meshIndices);
    SceneMeshUpdateMeshWithDefaultPositions(mesh);
    
    //dataWithBytesNoCopy:length:freeWhenDone  如果freeWhenDone为YES,bytes必须是指向一块malloc出来的内存地址
    NSData *someMeshData = [NSData dataWithBytesNoCopy:mesh length:sizeof(mesh) freeWhenDone:NO];  //freeWhenDone:为YES的话，返回Object拥有了bytes需要自己释放
    //注意copy 和 nocopy
    NSData *someIndexData = [NSData dataWithBytes:meshIndices
                                           length:sizeof(meshIndices)];
    return [self initWithVertexAttributeData:someMeshData
                                   indexData:someIndexData]; //通过父类创建出网格
}

- (void)drawEntireMesh{
    /** GL_TRIANGLE_STRIP
     * 当使用网格动画时，通过优化来减少需要复制的数据量通常意义非凡。为GPU提供三角形几何图形数据的最简单方法是指定所有三角形的三个顶点。但是，当绘制共边三角形时可以使用一个叫做三角形带(triangle strip)的优化方法。 一个三角形带结合了两个或都更多个相互连接的三角形。在这个带中的第一个三角形由前三个顶点定义的，接下来的每个三角形会与带中上一个三角形共用两个顶点
     *
     * 共用顶点减少了保存几何图形信息所需要的内存容量，减少了GPU必须处理的顶点的总数量
     *
     * glDrawElements()
     * 参数1：mode
     * 参数2：指定了要使用的索引的数量。对于三角形带来说，索引的数量等于要绘制的三角形的数量加上2
     * 参数3：指定了索引值的类型  必须是GL_UNSIGNED_BYTE(只能引用256个独一无二的索引) 或者 GL_UNSIGNED_SHORT (最多可引用65356个独一无二的索引)
     * 参数4：是一个元素数组缓存的字节偏移量
     */
    glDrawElements(GL_TRIANGLE_STRIP,
                   NUM_MESH_INDICES,
                   GL_UNSIGNED_SHORT,
                   (GLushort *)NULL);
}


- (void)updateMeshWithDefaultPositions{
    SceneMeshUpdateMeshWithDefaultPositions(mesh);//重新恢复到默认的顶点属性数据
    
    [self makeDynamicAndUpdateWithVertices:&mesh[0][0]
                          numberOfVertices:sizeof(mesh)/sizeof(SceneMeshVertex)];
}


/**
 * 通过随着时间改变网格顶点的Y坐标来产生网格动画。碧波荡漾的水波效果是通过在视图控制器的'update'方法中以一个固定的频率调用下面的方法
 *
 */
- (void)updateMeshWithElapsedTime:(NSTimeInterval)anInterval{ //修改顶点位置和重新计算法线
    int currentRow;
    int currentColumn;
    
    for (currentColumn = 0; currentColumn < NUM_MESH_COLUMNS; currentColumn++) {
        const GLfloat phaseOffset = 2.0f * anInterval;
        const GLfloat phase = 4.0 * currentColumn / (float)NUM_MESH_COLUMNS;
        
        const GLfloat yOffset = 2.0 * sinf(M_PI * (phase + phaseOffset));
        
        for (currentRow = 0; currentRow < NUM_MESH_ROWS; currentRow++) {
            mesh[currentColumn][currentRow].position.y = yOffset;
        }
    }
    
    SceneMeshUpdateNormals(mesh);
    
    //动态绘制
    [self makeDynamicAndUpdateWithVertices:&mesh[0][0]
                          numberOfVertices:sizeof(mesh)/sizeof(SceneMeshVertex)];
}

void SceneMeshUpdateMeshWithDefaultPositions(SceneMeshVertex mesh[NUM_MESH_COLUMNS][NUM_MESH_ROWS]) {
    int currentRow;
    int currentColumn;
    
    for (currentColumn = 0; currentColumn < NUM_MESH_COLUMNS; currentColumn++) {
        for (currentRow = 0; currentRow < NUM_MESH_ROWS; currentRow++) {
            mesh[currentColumn][currentRow].position = GLKVector3Make(currentColumn,
                                                                      0.0f,
                                                                      -currentRow);
            GLKVector2 textureCoords = GLKVector2Make((float)currentRow/(NUM_MESH_ROWS - 1),
                                                      (float)currentColumn/(NUM_MESH_COLUMNS - 1));
            mesh[currentColumn][currentRow].texCoords0 = textureCoords;
        }
    }
    SceneMeshUpdateNormals(mesh);
}

//初始化索引 形成一个大的三角形带
void SceneMeshInitIndices(GLushort meshIndics[NUM_MESH_INDICES]){ //具体的是怎么样形成的索引数据??
    int currentRow = 0;
    int currentColumn = 0;
    int currentMeshIndex = 0;
    
    currentMeshIndex = 1;
    for (currentColumn = 0; currentColumn < (NUM_MESH_COLUMNS - 1); currentColumn++) {
        if (0 == (currentColumn % 2)) { //偶数
            currentMeshIndex--;
            for (currentRow = 0; currentRow < NUM_MESH_ROWS; currentRow++) {
                meshIndics[currentMeshIndex++] = currentColumn * NUM_MESH_ROWS + currentRow;
                meshIndics[currentMeshIndex++] = (currentColumn + 1) * NUM_MESH_ROWS + currentRow;
            }
        } else { //奇数
            currentMeshIndex--;
            for (currentRow = NUM_MESH_ROWS - 1; currentRow >= 0; currentRow--) {
                meshIndics[currentMeshIndex++] = currentColumn * NUM_MESH_ROWS + currentRow;
                meshIndics[currentMeshIndex++] = (currentColumn + 1) * NUM_MESH_ROWS + currentRow;
            }
        }
    }
    NSCAssert(currentMeshIndex == NUM_MESH_INDICES, @"Incorrect number of indices intialized");
}

//用四个相领平面的position平均计算平滑法线数据
void SceneMeshUpdateNormals(SceneMeshVertex mesh[NUM_MESH_COLUMNS][NUM_MESH_ROWS]) {
    int currentRow;
    int currentColumn;
    
    for (currentRow = 1; currentRow < (NUM_MESH_ROWS - 1); currentRow ++) {
        for (currentColumn = 1; currentColumn < (NUM_MESH_COLUMNS - 1); currentColumn ++) {
            //得到四个平面
            GLKVector3 position = mesh[currentColumn][currentRow].position;
            GLKVector3 vectorA = GLKVector3Subtract(mesh[currentColumn][currentRow+1].position,
                                                    position);
            
            GLKVector3 vectorB = GLKVector3Subtract(mesh[currentColumn + 1][currentRow].position,
                                                    position);
            
            GLKVector3 vectorC = GLKVector3Subtract(mesh[currentColumn][currentRow - 1].position,
                                                    position);
            
            GLKVector3 vectorD = GLKVector3Subtract(mesh[currentColumn - 1][currentRow].position,
                                                    position);
            
            //计算四个平面的法向量
            GLKVector3 normalBA = GLKVector3CrossProduct(vectorB, vectorA);
            GLKVector3 normalCB = GLKVector3CrossProduct(vectorC, vectorB);
            GLKVector3 normalDC = GLKVector3CrossProduct(vectorD, vectorC);
            GLKVector3 normalAD = GLKVector3CrossProduct(vectorA, vectorD);
            
            //进行平滑(平均值)
            mesh[currentColumn][currentRow].normal = GLKVector3MultiplyScalar(GLKVector3Add(GLKVector3Add(GLKVector3Add(normalBA, normalCB),
                                                                                                          normalDC),
                                                                                            normalAD),
                                                                              0.25);
        }
    }
    
    //计算沿x轴的最大和最小的法线向量
    for (currentRow = 0; currentRow < NUM_MESH_ROWS; currentRow ++) {
        mesh[0][currentRow].normal = mesh[1][currentRow].normal;
        mesh[NUM_MESH_COLUMNS - 1][currentRow].normal = mesh[NUM_MESH_COLUMNS - 2][currentRow].normal;
    }
    
    //计算沿z轴的最大和最小法线向量
    for (currentColumn = 0; currentColumn < NUM_MESH_COLUMNS; currentColumn++) {
        mesh[currentColumn][0].normal = mesh[currentColumn][1].normal;
        mesh[currentColumn][NUM_MESH_ROWS - 1].normal = mesh[currentColumn][NUM_MESH_ROWS - 2].normal ;
    }
    
}

@end
