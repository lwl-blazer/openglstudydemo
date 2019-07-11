//
//  ViewController.h
//  OpenGLES_7
//
//  Created by luowailin on 2019/7/10.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "SceneCar.h"

@interface ViewController : GLKViewController<SceneCarControllerProtocol>

@property(nonatomic, assign, readonly) AGLKAxisAllignedBoundingBox rinkBoundingBox;
@property(nonatomic, strong, readonly) NSArray *cars;

@end



