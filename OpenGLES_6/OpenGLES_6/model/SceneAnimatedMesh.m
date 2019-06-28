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
#define NUM_MESH_TRIANGLES ((NUM_MESH_ROWS - 1) * \
(NUM_MESH_COLUMNS - 1) * 2)

#define NUM_MESH_INDICES (NUM_MESH_TRIANGLES + 2 + \
(NUM_MESH_COLUMNS - 2))

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
    GLushort meshIndices[NUM_MESH_INDICES];
    SceneMeshInitIndices(meshIndices);
    SceneMeshUpdateMeshWithDefaultPositions(mesh);
    
    NSData *someMeshData = [NSData dataWithBytesNoCopy:mesh length:sizeof(mesh) freeWhenDone:NO];
    NSData *someIndexData = [NSData dataWithBytes:meshIndices
                                           length:sizeof(meshIndices)];
    return [self initWithVertexAttributeData:someMeshData
                                   indexData:someIndexData];;
}

- (void)drawEntireMesh{
    glDrawElements(GL_TRIANGLE_STRIP,
                   NUM_MESH_INDICES,
                   GL_UNSIGNED_SHORT,
                   (GLushort *)NULL);
}


- (void)updateMeshWithDefaultPositions{
    SceneMeshUpdateMeshWithDefaultPositions(mesh);
    
    [self makeDynamicAndUpdateWithVertices:&mesh[0][0]
                          numberOfVertices:sizeof(mesh)/sizeof(SceneMeshVertex)];
}

- (void)updateMeshWithElapsedTime:(NSTimeInterval)anInterval{
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

void SceneMeshInitIndices(GLushort meshIndics[NUM_MESH_INDICES]){
    int currentRow = 0;
    int currentColumn = 0;
    int currentMeshIndex = 0;
    
    currentMeshIndex = 1;
    for (currentColumn = 0; currentColumn < (NUM_MESH_COLUMNS - 1); currentColumn++) {
        if (0 == (currentColumn % 2)) {
            currentMeshIndex--;
            for (currentRow = 0; currentRow < NUM_MESH_ROWS; currentRow++) {
                meshIndics[currentMeshIndex++] = currentColumn * NUM_MESH_ROWS + currentRow;
                meshIndics[currentMeshIndex++] = (currentColumn + 1) * NUM_MESH_ROWS + currentRow;
            }
        } else {
            currentMeshIndex--;
            for (currentRow = NUM_MESH_ROWS - 1; currentRow >= 0; currentRow--) {
                meshIndics[currentMeshIndex++] = currentColumn * NUM_MESH_ROWS + currentRow;
                meshIndics[currentMeshIndex++] = (currentColumn + 1) * NUM_MESH_ROWS + currentRow;
            }
        }
    }
    NSCAssert(currentMeshIndex == NUM_MESH_INDICES, @"Incorrect number of indices intialized");
}

void SceneMeshUpdateNormals(SceneMeshVertex mesh[NUM_MESH_COLUMNS][NUM_MESH_ROWS]) {
    int currentRow;
    int currentColumn;
    
    for (currentRow = 1; currentRow < (NUM_MESH_COLUMNS - 1); currentRow ++) {
        for (currentColumn = 1; currentColumn < (NUM_MESH_COLUMNS - 1); currentColumn ++) {
            GLKVector3 position = mesh[currentColumn][currentRow].position;
            GLKVector3 vectorA = GLKVector3Subtract(mesh[currentColumn][currentRow+1].position,
                                                    position);
            
            GLKVector3 vectorB = GLKVector3Subtract(mesh[currentColumn + 1][currentRow].position,
                                                    position);
            
            GLKVector3 vectorC = GLKVector3Subtract(mesh[currentColumn][currentRow - 1].position,
                                                    position);
            
            GLKVector3 vectorD = GLKVector3Subtract(mesh[currentColumn - 1][currentRow].position,
                                                    position);
            
            GLKVector3 normalBA = GLKVector3CrossProduct(vectorB, vectorA);
            GLKVector3 normalCB = GLKVector3CrossProduct(vectorC, vectorB);
            GLKVector3 normalDC = GLKVector3CrossProduct(vectorD, vectorC);
            GLKVector3 normalAD = GLKVector3CrossProduct(vectorA, vectorD);
            
            mesh[currentColumn][currentRow].normal = GLKVector3MultiplyScalar(GLKVector3Add(GLKVector3Add(GLKVector3Add(normalBA, normalCB),
                                                                                                          normalDC),
                                                                                            normalAD),
                                                                              0.25);
        }
    }
    
    for (currentRow = 0; currentRow < NUM_MESH_ROWS; currentRow ++) {
        mesh[0][currentRow].normal = mesh[1][currentRow].normal;
        mesh[NUM_MESH_COLUMNS - 1][currentRow].normal = mesh[NUM_MESH_COLUMNS - 2][currentRow].normal;
    }
    
    for (currentColumn = 0; currentColumn < NUM_MESH_COLUMNS; currentColumn++) {
        mesh[currentColumn][0].normal = mesh[currentColumn][1].normal;
        mesh[currentColumn][NUM_MESH_ROWS - 1].normal = mesh[currentColumn][NUM_MESH_ROWS - 2].normal ;
    }
    
}

@end
