//
//  UtilityTextureInfo.m
//  OpenGLES_7
//
//  Created by luowailin on 2019/7/11.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "UtilityTextureInfo.h"

@interface UtilityTextureInfo ()

@property(nonatomic, strong, readwrite) NSDictionary *plist;

@end

@implementation UtilityTextureInfo

- (void)discardPlist{
    self.plist = nil;
}


/** NSKeyedArchiver专门用来做自定义对象归档
 *
 * encodeWithCoder
 * 什么时候调用:当一个对象要归档的时候就会调用这个方法
 * 作用：告诉Foundation当前对象中哪些属性需要归档
 *
 * initWithCoder
 * 什么时候调用: 只要解析一个文件的时候就会调用，当一个对象要解档的时候就会调用这个方法解档
 * 作用:告诉苹果当前对象中哪些属性需要解档
 *
 *
 * NSKeyedArchiver也可以实现自定义对象的深复制
 */
- (void)encodeWithCoder:(NSCoder *)aCoder{
    NSAssert(0, @"Invalid method");
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self.plist = [aDecoder decodeObjectForKey:@"plist"];
    return self;
}

@end
