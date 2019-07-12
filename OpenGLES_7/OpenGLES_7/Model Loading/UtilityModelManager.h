//
//  UtilityModelManager.h
//  OpenGLES_7
//
//  Created by luowailin on 2019/7/11.
//  Copyright © 2019 luowailin. All rights reserved.
//


// 加载模型数据
#import <GLKit/GLKit.h>

NS_ASSUME_NONNULL_BEGIN
@class UtilityMesh, UtilityModel;
@interface UtilityModelManager : NSObject

@property(nonatomic, strong, readonly) GLKTextureInfo *textureInfo;
@property(nonatomic, strong, readonly) UtilityMesh *consolidatedMesh;

- (instancetype)initWithModelPath:(NSString *)aPath;

- (BOOL)readFromData:(NSData *)data
              ofType:(NSString *)typeName
               error:(NSError **)outError;

- (UtilityModel *)modelNamed:(NSString *)aName;
- (void)prepareToDraw;
- (void)prepareToPick;

@end

extern NSString *const UtilityModelManagerTextureImageInfo;
extern NSString *const UtilityModelManagerMesh;
extern NSString *const UtilityModelManagerModels;

NS_ASSUME_NONNULL_END
