//
//  AGLKAxisAllignedBoundingBox.h
//  OpenGLES_7
//
//  Created by luowailin on 2019/7/10.
//  Copyright © 2019 luowailin. All rights reserved.
//

#ifndef AGLKAxisAllignedBoundingBox_h
#define AGLKAxisAllignedBoundingBox_h

#import <GLKit/GLKit.h>

typedef struct{
    GLKVector3 min;
    GLKVector3 max;
}AGLKAxisAllignedBoundingBox;  //模型的最大最小边界

#endif /* AGLKAxisAllignedBoundingBox_h */
