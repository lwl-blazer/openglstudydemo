//
//  ViewController.h
//  OpenGLES_1
//
//  Created by luowailin on 2019/5/30.
//  Copyright © 2019 luowailin. All rights reserved.
//  https://github.com/xcoders/OpenGL

#import <GLKit/GLKit.h>

@interface ViewController : GLKViewController
{
    GLuint vertexBufferID;  //顶点数据的缓存ID
}

@property(nonatomic, strong) GLKBaseEffect *baseEffect;

@end

/**
 * GLKBaseEffect  是 GLKit提供的另一个内建类。GLKBaseEffect的存在是为了简化OpenGL ES的很多常用操作。GLKBaseEffect隐藏了iOS设备支持的多个OpenGL ES 版本之间的差异。
 * 在应用中使用GLKBaseEffect能减少需要编写的代码量。
 */
