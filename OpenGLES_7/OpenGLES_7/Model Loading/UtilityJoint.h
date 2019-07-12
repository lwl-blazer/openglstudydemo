//
//  UtilityJoint.h
//  OpenGLES_7
//
//  Created by luowailin on 2019/7/12.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UtilityJoint : NSObject

@property(nonatomic, weak, readonly) UtilityJoint *parent;
@property(nonatomic, strong, readonly) NSArray *children;

@property(nonatomic, assign, readonly) GLKVector3 displacement;
@property(nonatomic, assign, readwrite) GLKMatrix4 matrix;

- (instancetype)initWithDisplacement:(GLKVector3)aDisplacement
                              parent:(UtilityJoint *)aParent;

- (GLKMatrix4)cumulativeTransforms;
- (GLKVector3)cumulativeDisplacement;

@end

NS_ASSUME_NONNULL_END
