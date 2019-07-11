//
//  UtilityMesh.h
//  OpenGLES_7
//
//  Created by luowailin on 2019/7/10.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef struct {
    GLKVector3 position;
    GLKVector3 normal;
    GLKVector2 texCoords0;
    GLKVector2 texCoords1;
} UtilityMeshVertex;

extern NSString *const UtilityMeshCommandNumberOfIndices;
extern NSString *const UtilityMeshCommandFirstIndex;


@interface UtilityMesh : NSObject
{
    GLuint indexBufferID_;
    GLuint vertexBufferID_;
    GLuint vertexExtraBufferID_;
    GLuint vertexArrayID_;
}

@property(nonatomic, strong, readonly) NSData *vertexData;
@property(nonatomic, strong, readonly) NSData *indexData;

@property(nonatomic, strong, readonly) NSMutableData *extraVertexData;
@property(nonatomic, assign, readonly) NSUInteger numberOfIndices;

@property(nonatomic, strong, readonly) NSArray *commands;
@property(nonatomic, strong, readonly) NSDictionary *plistRepresentation;

@property(nonatomic, copy, readonly) NSString *axisAlignedBoundingBoxString;

@property(nonatomic, assign, readonly) BOOL shouldUseVAOExtension;


- (instancetype)initWithPlistRepresentation:(NSDictionary *)aDictionary;

- (UtilityMeshVertex)vertexAtIndex:(NSUInteger)anIndex;
- (GLushort)indexAtIndex:(NSUInteger)anIndex;

- (NSString *)axisAlignedBoundingBoxStringForCommandsInRange:(NSRange)aRange;

@end

NS_ASSUME_NONNULL_END
