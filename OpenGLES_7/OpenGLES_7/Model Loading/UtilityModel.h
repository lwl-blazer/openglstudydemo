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

//用来确定适用于每个模型的网格绘图命令的范围的属性
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


/**
 * 从概念上说，模型是由一个或者多个网格组成的，模型可能会使用不同的坐标系转换和材质属性来绘制每个网格组件。
 * 例如：一个人物模型的头部转动，但是肩部不转。那么头部和肩部应该是同一个模型内的两个不同的网格
 *
 * 但使用OpenGLES进行绘图最有效的方式是使用驻存在GPU控制的内存中的一个不变的大网格。一个比较好的拆中方法是，通过指定模型使用部分所对应的顶点索引范围，来为每个模型绘制一个单独的大网格中的不同子集
 
 * 这正是UtilityModel和UtilityMesh类在这个代码中的交互方式。所有的UtilityModel实例共享同一个UtilityMesh实例。模型会引用由网格保存的一个绘图命令数组。不同的命令使用不同的OpenGL ES 模型绘制不同的网格子集
 *
 */
