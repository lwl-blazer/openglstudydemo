//
//  UtilityModelManager.m
//  OpenGLES_7
//
//  Created by luowailin on 2019/7/11.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "UtilityModelManager.h"
#import "UtilityModel+viewAdditions.h"
#import "UtilityMesh+viewAdditions.h"
#import "UtilityTextureInfo+viewAdditions.h"

@interface UtilityModelManager ()

@property(nonatomic, strong, readwrite) GLKTextureInfo *textureInfo;
@property(nonatomic, strong, readwrite) UtilityMesh *consolidatedMesh;
@property(nonatomic, strong, readwrite) NSDictionary *modelDictionary;

@end

@implementation UtilityModelManager

- (instancetype)init{
    self = [super init];
    if (self) {
    }
    return self;
}

- (instancetype)initWithModelPath:(NSString *)aPath{
    self = [self init];
    if (self) {
        NSError *modelLoadingError = nil;
        
        NSData *data = [NSData dataWithContentsOfFile:aPath
                                              options:0
                                                error:&modelLoadingError];
        
        if (data != nil) {
            [self readFromData:data
                        ofType:[aPath pathExtension]
                         error:&modelLoadingError];
        }
    }
    return self;
}

- (NSDictionary *)modelsFromPlistRepresentation:(NSDictionary *)plist
                                           mesh:(UtilityMesh *)aMesh{
    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    for (NSDictionary *modelDictionary in plist.allValues) {
        UtilityModel *newModel = [[UtilityModel alloc] initWithPlistRepresentation:modelDictionary
                                                                              mesh:aMesh];
        [result setObject:newModel forKey:newModel.name];
    }
    return result;
}

//解析文件数据 提取模型，网格和纹理对象
- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError{
    
    NSDictionary *documentDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    //纹理图片 并设置纹理参数
    self.textureInfo = [GLKTextureInfo textureInfoFromUtilityPlistRepresention:[documentDictionary objectForKey:UtilityModelManagerTextureImageInfo]];
    
    self.consolidatedMesh = [[UtilityMesh alloc] initWithPlistRepresentation:[documentDictionary objectForKey:UtilityModelManagerMesh]];
    
    self.modelDictionary = [self modelsFromPlistRepresentation:[documentDictionary objectForKey:UtilityModelManagerModels]
                                                          mesh:self.consolidatedMesh];
    
    return YES;
}

- (UtilityModel *)modelNamed:(NSString *)aName{
    return [self.modelDictionary objectForKey:aName];
}

- (void)prepareToDraw{
    [self.consolidatedMesh prepareToDraw];
}

- (void)prepareToPick{
    [self.consolidatedMesh prepareToPick];
}

@end

NSString *const UtilityModelManagerTextureImageInfo = @"textureImageInfo";
NSString *const UtilityModelManagerMesh = @"mesh";
NSString *const UtilityModelManagerModels = @"models";
