//
//  UtilityModel.h
//  OpenGLES_7
//
//  Created by luowailin on 2019/7/11.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AGLKAxisAllignedBoundingBox.h"

NS_ASSUME_NONNULL_BEGIN
@class UtilityMesh;
@interface UtilityModel : NSObject{
    NSUInteger indexOfFirstCommand_;
    NSUInteger numberOfCommands_;
}

@property(copy, nonatomic, readonly) NSString *name;
@property(strong, nonatomic, readonly) UtilityMesh *mesh;
@property(assign, nonatomic, readonly) NSUInteger indexOfFirstCommand;
@property(assign, nonatomic, readonly) NSUInteger numberOfCommands;

@property(assign, nonatomic, readonly) AGLKAxisAllignedBoundingBox axisAlignedBoundingBox;
@property(assign, nonatomic, readonly) BOOL doesRequireLighting;

- (instancetype)initWithName:(NSString *)aName
                        mesh:(UtilityMesh *)aMesh
         indexOfFirstCommand:(NSUInteger)aFirstIndex
            numberOfCommands:(NSUInteger)count
      axisAlignedBoundingBox:(AGLKAxisAllignedBoundingBox)aBoundingBox;


- (instancetype)initWithPlistRepresentation:(NSDictionary *)aDictionary
                                       mesh:(UtilityMesh *)aMesh;

@end

extern NSString *const UtilityModelName;
extern NSString *const UtilityModelIndexOfFirstCommand;
extern NSString *const UtilityModelNumberOfCommands;
extern NSString *const UtilityModelAxisAlignedBoundingBox;
extern NSString *const UtilityModelDrawingCommand;

NS_ASSUME_NONNULL_END
