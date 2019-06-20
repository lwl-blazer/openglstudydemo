//
//  ViewController3.m
//  OpenGLES_5
//
//  Created by luowailin on 2019/6/20.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "ViewController3.h"
#import "AGLKTextureRotationBaseEffect.h"
#import "AGLKVertexAttribArrayBuffer.h"

@interface ViewController3 ()

@property(nonatomic, strong) AGLKTextureRotationBaseEffect *baseEffect;
@property(nonatomic, strong) AGLKVertexAttribArrayBuffer *vertexBuffer;

@property(nonatomic, assign) float textureScaleFactor;
@property(nonatomic, assign) float textureAngle;
@property(nonatomic, assign) GLKMatrixStackRef textureMatrixStack;



@end

@implementation ViewController3

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)takeTextureAngleFrom:(UISlider *)sender {
    
}

- (IBAction)takeTextureScaleFactorFrom:(UISlider *)sender {
    
}


@end
