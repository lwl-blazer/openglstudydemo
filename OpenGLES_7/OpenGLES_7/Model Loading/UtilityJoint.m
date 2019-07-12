
//
//  UtilityJoint.m
//  OpenGLES_7
//
//  Created by luowailin on 2019/7/12.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "UtilityJoint.h"

@interface UtilityJoint ()

@property(nonatomic, weak, readwrite) UtilityJoint *parent;
@property(nonatomic, strong, readwrite) NSArray *children;
@property(nonatomic, assign, readwrite) GLKVector3 displacement;

@end

@implementation UtilityJoint

- (instancetype)initWithDisplacement:(GLKVector3)aDisplacement
                              parent:(UtilityJoint *)aParent{
    self = [super init];
    if (self) {
        self.displacement = aDisplacement;
        self.parent = aParent;
        
        self.children = [NSMutableArray array];
        self.matrix = GLKMatrix4Identity;
    }
    return self;
}

- (GLKMatrix4)cumulativeTransforms{
    GLKMatrix4 result = GLKMatrix4Identity;
    
    if (self.parent != nil) { //注意这可能是一个递归调用
        result = [self.parent cumulativeTransforms];
    }
    
    GLKVector3 d = [self cumulativeDisplacement];
    
    result = GLKMatrix4Translate(result, d.x, d.y, d.z);
    result = GLKMatrix4Multiply(result, self.matrix);
    result = GLKMatrix4Translate(result, -d.x, -d.y, -d.z);
    
    return result;
}

- (GLKVector3)cumulativeDisplacement{
    GLKVector3 result = self.displacement;
    
    if (self.parent != nil) {
        result = GLKVector3Add(result, [self.parent cumulativeDisplacement]);
    }
    return result;
}

@end
