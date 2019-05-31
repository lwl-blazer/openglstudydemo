//
//  AGLKTextureInfo.m
//  OpenGLES_2
//
//  Created by luowailin on 2019/5/31.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "AGLKTextureInfo.h"

typedef enum {
    AGLK1 = 1,
    AGLK2 = 2,
    AGLK4 = 4,
    AGLK8 = 8,
    AGLK16 = 16,
    AGLK32 = 32,
    AGLK64 = 64,
    AGLK128 = 128,
    AGLK256 = 256,
    AGLK512 = 512,
    AGLK1024 = 1024,
}AGLKPowerOf2;

@interface AGLKTextureInfo ()

@property(nonatomic, assign, readwrite) GLuint name;
@property(nonatomic, assign, readwrite) GLuint target;
@property(nonatomic, assign, readwrite) GLuint width;
@property(nonatomic, assign, readwrite) GLuint height;

@end

@implementation AGLKTextureInfo

- (instancetype)initWithName:(GLuint)aName
                      target:(GLuint)aTarget
                       width:(size_t)aWidth
                      height:(size_t)aHeight
{
    self = [super init];
    if (self) {
        self.name = aName;
        self.target = aTarget;
        self.width = (int)aWidth;
        self.height = (int)aHeight;
    }
    return self;
}


@end


@implementation AGLKTextureLoader


static AGLKPowerOf2 AGLKCalcuatePowerOf2ForDimension(GLuint dismension){
    AGLKPowerOf2 result = AGLK1;
    if (dismension > (GLuint)AGLK512) {
        result = AGLK1024;
    } else if (dismension > (GLuint)AGLK256) {
        result = AGLK512;
    } else if (dismension > (GLuint)AGLK128) {
        result = AGLK256;
    } else if (dismension > (GLuint)AGLK64) {
        result = AGLK128;
    } else if (dismension > (GLuint)AGLK32) {
        result = AGLK64;
    } else if (dismension > (GLuint)AGLK16) {
        result = AGLK32;
    } else if (dismension > (GLuint)AGLK8) {
        result = AGLK16;
    } else if (dismension > (GLuint)AGLK4) {
        result = AGLK8;
    }else if (dismension > (GLuint)AGLK2) {
        result = AGLK4;
    } else if(dismension > (GLuint)AGLK1) {
        result = AGLK2;
    }
    return result;
}

static NSData *AGLKDataWithResizedCGImageBytes(CGImageRef cgImage,
                                               size_t *widthPtr,
                                               size_t *heightPtr){
    NSCParameterAssert(NULL != cgImage);
    NSCParameterAssert(NULL != widthPtr);
    NSCParameterAssert(NULL != heightPtr);
    
    size_t originalWidth = CGImageGetWidth(cgImage);
    size_t originalHeight = CGImageGetWidth(cgImage);
    
    NSCAssert(0 < originalWidth, @"Invalid image width");
    NSCAssert(0 < originalHeight, @"Invalid image Height");
    
    //2的幂
    size_t width = (size_t)AGLKCalcuatePowerOf2ForDimension((int)originalWidth);
    size_t height = (size_t)AGLKCalcuatePowerOf2ForDimension((int)originalHeight);
    
    NSMutableData *imageData = [NSMutableData dataWithLength:height *width *4];
    NSCAssert(imageData != nil, @"Unable to allocate image storage");
    
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef cgContext = CGBitmapContextCreate([imageData mutableBytes],
                                                   width,
                                                   height,
                                                   8,
                                                   4 * width,
                                                   colorSpace,
                                                   kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);
    
    CGContextTranslateCTM(cgContext, 0, height);
    CGContextScaleCTM(cgContext, 1.0, -1.0);
    
    CGContextDrawImage(cgContext,
                       CGRectMake(0, 0, width, height),
                       cgImage);
    CGContextRelease(cgContext);
    
    *widthPtr = width;
    *heightPtr = height;
    
    return imageData;
}


//此函数完成了标准的缓存管理步骤，包括生成、绑定和初始化一个新的纹理缓存
+ (AGLKTextureInfo *)textureWithCGImage:(CGImageRef)cgImage
                                options:(NSDictionary *)options
                                  error:(NSError * _Nullable __autoreleasing *)outError{
    size_t width;
    size_t height;
    NSData *imageData = AGLKDataWithResizedCGImageBytes(cgImage, &width, &height);
    
    GLuint textureBufferID;
    glGenTextures(1, &textureBufferID);
    glBindTexture(GL_TEXTURE_2D, textureBufferID);
    
    //复制图片像素的颜色数据到绑定的纹理缓存中
    glTexImage2D(GL_TEXTURE_2D,
                 0,     //初始细节级别  如果没有使用MIP贴图这个参数必须是0  如果是MIP贴图那这个参数来明确地初始化每个图细节级别，但是要小心，因为从全分辨率到只有一纹素的每个级别都必须被指定，否则GPU将不会接受这个纹理缓存
                 GL_RGBA,    //指定纹理缓存内每个纹素需要保存的信息的数量 对于iOS设备来说  GL_RGB 或 GL_RGBA
                 (int)width,
                 (int)height,
                 0,
                 GL_RGBA,
                 GL_UNSIGNED_BYTE,    //位编码类型   GL_UNSIGNED_BYTE 会提供最佳色彩质量
                 [imageData bytes]);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    
    AGLKTextureInfo *result = [[AGLKTextureInfo alloc] initWithName:textureBufferID
                                                             target:GL_TEXTURE_2D
                                                              width:width
                                                             height:height];
    return result;
}

@end
