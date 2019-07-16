//
//  UtilityModel+skinning.m
//  OpenGLES_7
//
//  Created by luowailin on 2019/7/12.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "UtilityModel+skinning.h"
#import "UtilityMesh+skinning.h"
#import "UtilityJoint.h"

@implementation UtilityModel (skinning)

//每个模型都被赋给了一个单独的关节索引
- (void)assignJoint:(NSUInteger)anIndex{
    const NSUInteger lastCommandIndex = self.indexOfFirstCommand + self.numberOfCommands;
    
    for (NSUInteger i = self.indexOfFirstCommand; i < lastCommandIndex; i++) {
        NSDictionary *currentCommand = [self.mesh.commands objectAtIndex:i];
        
        const GLsizei numberOfIndices = (GLsizei)[[currentCommand objectForKey:UtilityMeshCommandNumberOfIndices] unsignedIntegerValue];
        const GLsizei firstIndex = (GLsizei)[[currentCommand objectForKey:UtilityMeshCommandFirstIndex] unsignedIntegerValue];
        
        GLsizei lastIndex = firstIndex + numberOfIndices;
        
        for (GLsizei j = firstIndex; j < lastIndex; j++) {
            UtilityMeshJointInfluence influences = {{anIndex + 1, 0, 0, 0}, {1, 0, 0, 0}};
            [self.mesh setJointInfluence:influences atIndex:j];
        }
    }
}

static GLfloat UtilityVector3DistanceSquared(GLKVector3 positionA, GLKVector3 positionB){
    const GLKVector3 vectorFromAtoB = GLKVector3Subtract(positionB, positionA);
    
    return GLKVector3DotProduct(vectorFromAtoB, vectorFromAtoB);
}

- (UtilityMeshJointInfluence)closestJointsToPosition:(GLKVector3)position
                                              joints:(NSArray *)joints{
    struct jointInfo {
        float jointIndex;
        float distanceSquared;
    };
    
    struct jointInfo joint0 = {0, HUGE_VALF};
    struct jointInfo joint1 = {0, HUGE_VALF};
    struct jointInfo joint2 = {0, HUGE_VALF};
    struct jointInfo joint3 = {0, HUGE_VALF};
    
    const NSUInteger count = [joints count];
    for (NSUInteger i = 0; i < count; i++) {
        UtilityJoint *joint = [joints objectAtIndex:i];
        
        float distanceSquared = UtilityVector3DistanceSquared(position, joint.cumulativeDisplacement);
        
        struct jointInfo currentJoint = {i + 1, distanceSquared};
        
        struct jointInfo closerJoint = (currentJoint.distanceSquared < joint0.distanceSquared) ? currentJoint : joint0;
        
        struct jointInfo furtherJoint = (currentJoint.distanceSquared > joint0.distanceSquared) ? currentJoint : joint0;
        
        joint0 = closerJoint;
        
        closerJoint = (furtherJoint.distanceSquared < joint1.distanceSquared) ? furtherJoint : joint1;
        furtherJoint = (furtherJoint.distanceSquared > joint1.distanceSquared) ? furtherJoint : joint1;
        joint1 = closerJoint;
        
        closerJoint = (furtherJoint.distanceSquared < joint2.distanceSquared) ? furtherJoint : joint2;
        furtherJoint = (furtherJoint.distanceSquared > joint2.distanceSquared) ? furtherJoint : joint2;
        joint2 = furtherJoint;
        
        closerJoint = (furtherJoint.distanceSquared < joint3.distanceSquared) ? furtherJoint : joint3;
        joint3 = closerJoint;
    }
    
    GLKVector4 jointIndices = {joint0.jointIndex,
        joint1.jointIndex,
        joint2.jointIndex,
        joint3.jointIndex};
    GLKVector4 jointWeights = {
        1.0f / MAX(joint0.distanceSquared, 0.001),
        1.0f / MAX(joint1.distanceSquared, 0.001),
        1.0f / MAX(joint2.distanceSquared, 0.001),
        1.0f / MAX(joint3.distanceSquared, 0.001)};
    
    if (jointWeights.x == HUGE_VALF) {
        jointWeights.x = 0;
    }
    
    if (jointWeights.y == HUGE_VALF) {
        jointWeights.y = 0;
    }
    
    if (jointWeights.z == HUGE_VALF) {
        jointWeights.z = 0;
    }
    
    if (jointWeights.w == HUGE_VALF) {
        jointWeights.w = 0;
    }
    jointWeights = GLKVector4Normalize(jointWeights);
    
    UtilityMeshJointInfluence result = {jointIndices, jointWeights};
    return result;
}

- (UtilityMeshJointInfluence)jointBelowPosition:(GLKVector3)position
                                         joints:(NSArray *)joints{
    struct jointInfo {
        float jointIndex;
        float distanceSquared;
    };
    
    struct jointInfo joint0 = {0, 1};
    struct jointInfo joint1 = {0, 0};
    struct jointInfo joint2 = {0, 0};
    struct jointInfo joint3 = {0, 0};
    
    const NSUInteger count = [joints count];
    for (NSUInteger i = 0; i < count; i ++) {
        UtilityJoint *joint = [joints objectAtIndex:i];
        GLKVector3 jointDisplacement = joint.cumulativeDisplacement;
        if (jointDisplacement.y <= position.y) {
            joint0.jointIndex = i + 1;
        }
    }
    
    GLKVector4 jointIndices = {
        joint0.jointIndex,
        joint1.jointIndex,
        joint2.jointIndex,
        joint3.jointIndex};
    
    GLKVector4 jointWeights = {
        joint0.distanceSquared,
        joint1.distanceSquared,
        joint2.distanceSquared,
        joint3.distanceSquared};
    
    jointWeights = GLKVector4Normalize(jointWeights);
    
    UtilityMeshJointInfluence result = {jointIndices, jointWeights};
    return result;
}

- (void)automaticallySkinSmoothWithJoints:(NSArray *)joints{
    const NSUInteger lastCommandIndex = self.indexOfFirstCommand + self.numberOfCommands;
    
    for (NSUInteger i = self.indexOfFirstCommand; i < lastCommandIndex; i++) {
        NSDictionary *currentCommand = [self.mesh.commands objectAtIndex:i];
        
        const GLsizei numberOfIndices = (GLsizei)[[currentCommand objectForKey:UtilityMeshCommandNumberOfIndices] unsignedIntegerValue];
        const GLsizei firstIndex = (GLsizei)[[currentCommand objectForKey:UtilityMeshCommandFirstIndex] unsignedIntegerValue];
        
        GLsizei lastIndex = firstIndex + numberOfIndices;
        for (GLsizei j = firstIndex; j < lastIndex; j++) {
            UtilityMeshVertex currentVertex = [self.mesh vertexAtIndex:j];
            
            UtilityMeshJointInfluence influences = [self closestJointsToPosition:currentVertex.position
                                                                          joints:joints];
            
            [self.mesh setJointInfluence:influences
                                 atIndex:j];
        }
    }
}

- (void)automaticallySkinRigidWithJoints:(NSArray *)joints{
    const NSUInteger lastCommandIndex = self.indexOfFirstCommand + self.numberOfCommands;
    
    for (NSUInteger i = self.indexOfFirstCommand; i < lastCommandIndex; i ++) {
        NSDictionary *currentCommand = [self.mesh.commands objectAtIndex:i];
        
        const GLsizei numberOfIndices = (GLsizei)[[currentCommand objectForKey:UtilityMeshCommandNumberOfIndices] unsignedIntegerValue];
        const GLsizei firstIndex = (GLsizei)[[currentCommand objectForKey:UtilityMeshCommandFirstIndex] unsignedIntegerValue];
        
        GLsizei lastIndex = firstIndex + numberOfIndices;
        for (GLsizei j = firstIndex; j < lastIndex; j ++) {
            UtilityMeshVertex currentVertex = [self.mesh vertexAtIndex:j];
            
            UtilityMeshJointInfluence influences = [self jointBelowPosition:currentVertex.position
                                                                     joints:joints];
            [self.mesh setJointInfluence:influences
                                 atIndex:j];
        }
    }
}
@end
