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

- (void)encodeWithCoder:(NSCoder *)aCoder{
    NSAssert(0, @"Invalid method");
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self.plist = [aDecoder decodeObjectForKey:@"plist"];
    return self;
}

@end
