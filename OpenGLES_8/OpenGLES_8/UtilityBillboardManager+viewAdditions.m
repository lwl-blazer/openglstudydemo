//
//  UtilityBillboardManager+viewAdditions.m
//  OpenGLES_8
//
//  Created by luowailin on 2019/7/22.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "UtilityBillboardManager+viewAdditions.h"
#import "UtilityBillboard.h"
#import <OpenGLES/ES3/glext.h>

typedef struct {
    GLKVector3 position;
    GLKVector3 normal;
    GLKVector2 textureCoords;
}BillboardVertex;


@implementation UtilityBillboardManager (viewAdditions)

//圆柱形公告牌 会面向观察者但是还会与"上"矢量保持平行      球形公告牌 会与平截体的近面平行
- (void)drawWithEyePosition:(GLKVector3)eyePosition lookDirection:(GLKVector3)lookDirection upVector:(GLKVector3)upVector{ //每次变动都重新计算顶点发送给GPU
    
    //单元向量 unit vector
    lookDirection = GLKVector3Normalize(lookDirection);
    //上向量
    GLKVector3 upUnitVector = GLKVector3Make(0.0f,
                                             1.0f,
                                             0.0f);
    GLKVector3 rightVector = GLKVector3CrossProduct(upUnitVector,
                                                    lookDirection); //标准右向量是标准上向量 和标准视线向量的向量积
    
    if (self.shouldRenderSpherical) { //球形公告牌
        upUnitVector = GLKVector3CrossProduct(lookDirection,
                                              rightVector);  //重新计算， 使公告牌平行于平截头体的近面
    }
    
    //取反
    const GLKVector3 normalVector = GLKVector3Negate(lookDirection);
    
    NSMutableData *billboardVertices = [NSMutableData data];
    
    //绘制的时候，根据公告牌中的distanceSquared的排序来处理
    for (UtilityBillboard *billboard in [self.sortedBillboards reverseObjectEnumerator]) {
        if (0 <= billboard.distanceSquared) { //在viewer's的后面不进行顶点计算
            break;
        } else { //
            const GLKVector2 size = billboard.size;
            const GLKVector3 position = billboard.position;
            
            //右向量是标准化的，这意味着它的长度是1.0，公告牌的宽度的一半乘以右向量会产生一个长度是所需的长度同时方向与右向量相同的新矢量 右下顶点是通过这个新矢量到公告牌的底部中心建立   左下顶点位置的距离是相同的，但是方向相反  所以是-0.5
            GLKVector3 leftBottomPosition = GLKVector3Add(GLKVector3MultiplyScalar(rightVector, size.x * -0.5f), position);
            GLKVector3 rightBootomPosition = GLKVector3Add(GLKVector3MultiplyScalar(rightVector, size.x * 0.5f), position);
            
            //从底部顶点位置处沿着上向量的方向向上平移公告牌高度的距离就是顶点顶点的位置
            GLKVector3 leftTopPosition = GLKVector3Add(leftBottomPosition,
                                                       GLKVector3MultiplyScalar(upUnitVector, size.y));
            GLKVector3 rightTopPosition = GLKVector3Add(rightBootomPosition,
                                                        GLKVector3MultiplyScalar(upUnitVector, size.y));
            
            const GLKVector2 maxTextureCoords = billboard.maxTextureCoords;
            const GLKVector2 minTextureCoords = billboard.minTextureCoords;
            
            //两个三角形 组成一个billboard
            BillboardVertex vertices[6];
            vertices[2].position = leftBottomPosition;
            vertices[2].normal = normalVector;
            vertices[2].textureCoords.x = minTextureCoords.x;
            vertices[2].textureCoords.y = maxTextureCoords.y;
            
            vertices[1].position = rightBootomPosition;
            vertices[1].normal = normalVector;
            vertices[1].textureCoords = maxTextureCoords;
            
            vertices[0].position = leftTopPosition;
            vertices[0].normal = normalVector;
            vertices[0].textureCoords = minTextureCoords;
            
            vertices[5].position = leftTopPosition;
            vertices[5].normal = normalVector;
            vertices[5].textureCoords = minTextureCoords;
            
            vertices[4].position = rightBootomPosition;
            vertices[4].normal = normalVector;
            vertices[4].textureCoords = maxTextureCoords;
            
            vertices[3].position = rightTopPosition;
            vertices[3].normal = normalVector;
            vertices[3].textureCoords.x = maxTextureCoords.x;
            vertices[3].textureCoords.y = minTextureCoords.y;
            
            [billboardVertices appendBytes:vertices
                                    length:sizeof(vertices)];
        }
        
        glBindVertexArray(0);
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        
        glEnableVertexAttribArray(GLKVertexAttribPosition);
        glVertexAttribPointer(GLKVertexAttribPosition,
                              3,
                              GL_FLOAT,
                              GL_FALSE,
                              sizeof(BillboardVertex),
                              (GLbyte *)[billboardVertices bytes] + offsetof(BillboardVertex, position));
        
        glEnableVertexAttribArray(GLKVertexAttribNormal);
        glVertexAttribPointer(GLKVertexAttribNormal,
                              3,
                              GL_FLOAT,
                              GL_FALSE,
                              sizeof(BillboardVertex),
                              (GLbyte *)[billboardVertices bytes] + offsetof(BillboardVertex, normal));
        
        glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
        glVertexAttribPointer(GLKVertexAttribTexCoord0,
                              2,
                              GL_FLOAT,
                              GL_FALSE,
                              sizeof(BillboardVertex),
                              (GLbyte *)[billboardVertices bytes] + offsetof(BillboardVertex, textureCoords));
        
        glDepthMask(GL_FALSE);
        glDrawArrays(GL_TRIANGLES,
                     0,
                     (GLsizei)([billboardVertices length]/sizeof(BillboardVertex)));
        glDepthMask(GL_TRUE);
    }
}

@end
