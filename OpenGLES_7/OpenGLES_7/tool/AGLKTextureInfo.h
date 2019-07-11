//
//  AGLKTextureInfo.h
//  OpenGLES_2
//
//  Created by luowailin on 2019/5/31.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import <GLKit/GLKit.h>

NS_ASSUME_NONNULL_BEGIN
//AGLKTextureInfo 纹理缓存的有用信息的简单类，
@interface AGLKTextureInfo : NSObject

@property(nonatomic, assign, readonly) GLuint name;    //纹理缓存标识符
@property(nonatomic, assign, readonly) GLuint target;
@property(nonatomic, assign, readonly) GLuint width;
@property(nonatomic, assign, readonly) GLuint height;

- (instancetype)initWithName:(GLuint)aName
                      target:(GLuint)aTarget
                       width:(size_t)aWidth
                      height:(size_t)aHeight;


@end


//AGLKTextureLoader 的实现展现了Core Graphics 和OpenGL ES的整合，提供了与GLKit的GLKTextureLoader的相似功能
@interface AGLKTextureLoader : NSObject

+ (AGLKTextureInfo *)textureWithCGImage:(CGImageRef)cgImage
                                options:(NSDictionary *)options
                                  error:(NSError **)outError;

@end

NS_ASSUME_NONNULL_END
