//
//  ViewController3.m
//  OpenGLES_7
//
//  Created by luowailin on 2019/7/16.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "ViewController3.h"
#import "UtilityModelManager+skinning.h"
#import "UtilityModel+viewAdditions.h"
#import "UtilityModel+skinning.h"
#import "UtilityJoint.h"
#import "UtilityArmatureBaseEffect.h"
#import "AGLKContext.h"

@interface ViewController3 ()

@property(nonatomic, strong) UtilityModelManager *modelManager;
@property(nonatomic, strong) UtilityArmatureBaseEffect *baseEffect;

@property(nonatomic, strong) UtilityModel *bone0;
@property(nonatomic, strong) UtilityModel *bone1;
@property(nonatomic, strong) UtilityModel *bone2;
@property(nonatomic, strong) UtilityModel *tube;

@property(nonatomic, assign) float joint0AngleRadians;
@property(nonatomic, assign) float joint1AngleRadians;
@property(nonatomic, assign) float joint2AngleRadians;

@end

@implementation ViewController3

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]], @"View Controller is not a GLKView");
    
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    view.context = [[AGLKContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    
    [AGLKContext setCurrentContext:view.context];
    [((AGLKContext *)view.context) enable:GL_DEPTH_TEST];
    
    self.baseEffect = [[UtilityArmatureBaseEffect alloc] init];
    
    self.baseEffect.light0.enabled = GL_TRUE;
    self.baseEffect.light0.ambientColor = GLKVector4Make(0.7f,
                                                         0.7f,
                                                         0.7f,
                                                         1.0f);
    self.baseEffect.light0.diffuseColor = GLKVector4Make(1.0f,
                                                         1.0f,
                                                         1.0f,
                                                         1.0f);
    self.baseEffect.light0Position = GLKVector4Make(1.0f,
                                                    0.8f,
                                                    0.4f,
                                                    0.0f);
    
    ((AGLKContext *)view.context).clearColor = GLKVector4Make(0.0f,
                                                              0.0f,
                                                              0.0f,
                                                              1.0f);
    
    NSString *modelsPath = [[NSBundle mainBundle] pathForResource:@"armatureSkin"
                                                           ofType:@"modelplist"];
    if (nil != modelsPath) {
        self.modelManager = [[UtilityModelManager alloc] initWithModelPath:modelsPath];
    }
    
    self.bone0 = [self.modelManager modelNamed:@"bone0"];
    NSAssert(nil != self.bone0, @"Failed to bone0 model");
    
    self.bone1 = [self.modelManager modelNamed:@"bone1"];
    NSAssert(nil != self.bone0, @"Failed to bone1 model");
    
    self.bone2 = [self.modelManager modelNamed:@"bone2"];
    NSAssert(nil != self.bone0, @"Failed to bone2 model");
    
    self.tube = [self.modelManager modelNamed:@"tube"];
    NSAssert(nil != self.tube, @"Failed to tube model");
    
    UtilityJoint *bone0Joint = [[UtilityJoint alloc] initWithDisplacement:GLKVector3Make(0, 0, 0)
                                                                   parent:nil];
    float bone0Length = self.bone0.axisAlignedBoundingBox.max.y - self.bone0.axisAlignedBoundingBox.min.y;
    
    UtilityJoint *bone1Joint = [[UtilityJoint alloc] initWithDisplacement:GLKVector3Make(0,
                                                                                         bone0Length, 0)
                                                                   parent:bone0Joint];
    float bone1Length = self.bone1.axisAlignedBoundingBox.max.y - self.bone1.axisAlignedBoundingBox.min.y;
    
    UtilityJoint *bone2Joint = [[UtilityJoint alloc] initWithDisplacement:GLKVector3Make(0,
                                                                                         bone1Length,
                                                                                         0)
                                                                   parent:bone1Joint];
    
    self.baseEffect.jointsArray = [NSArray arrayWithObjects:bone0Joint,
                                   bone1Joint, bone2Joint, nil];
    
    [self.tube automaticallySkinRigidWithJoints:self.baseEffect.jointsArray];
    
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4MakeLookAt(5.0f, 10.0f, 15.0f,
                                                                     0.0, 2.0, 0.0,
                                                                     0.0, 1.0, 0.0);
    
    [self setJoint0AngleRadians:0];
    [self setJoint1AngleRadians:0];
    [self setJoint2AngleRadians:0];
}


- (void)setJoint0AngleRadians:(float)joint0AngleRadians{
    _joint0AngleRadians = joint0AngleRadians;
    
    GLKMatrix4 rotateZMatrix = GLKMatrix4MakeRotation(joint0AngleRadians * M_PI * 0.5,
                                                      0,
                                                      0,
                                                      1);
    
    [(UtilityJoint *)[self.baseEffect.jointsArray objectAtIndex:0] setMatrix:rotateZMatrix];
}

- (void)setJoint1AngleRadians:(float)joint1AngleRadians{
    _joint1AngleRadians = joint1AngleRadians;
    
    GLKMatrix4 rotateZMatrix = GLKMatrix4MakeRotation(joint1AngleRadians * M_PI * 0.5,
                                                      0,
                                                      0,
                                                      1);
    [(UtilityJoint *)[self.baseEffect.jointsArray objectAtIndex:1] setMatrix:rotateZMatrix];
}

- (void)setJoint2AngleRadians:(float)joint2AngleRadians{
    _joint2AngleRadians = joint2AngleRadians;
    
    GLKMatrix4 rotateZMatrix = GLKMatrix4MakeRotation(joint2AngleRadians * M_PI * 0.5,
                                                      0,
                                                      0,
                                                      1);
    
    [(UtilityJoint *)[self.baseEffect.jointsArray objectAtIndex:2] setMatrix:rotateZMatrix];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    [((AGLKContext *)view.context) clear:GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT];
    [((AGLKContext *)view.context) enable:GL_CULL_FACE];
    
    const GLfloat aspectRatio = (GLfloat)view.drawableWidth / (GLfloat)view.drawableHeight;
    
    self.baseEffect.transform.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(35.0f),
                                                                           aspectRatio,
                                                                           4.0f,
                                                                           20.0f);
    
    [self.modelManager prepareToDrawWithJointInfluence];
    [self.baseEffect prepareToDrawArmature];
    
    [self.tube draw];
#ifdef DEBUG
    {  // Report any errors
        GLenum error = glGetError();
        if(GL_NO_ERROR != error)
        {
            NSLog(@"GL Error: 0x%x", error);
        }
    }
#endif
}

- (IBAction)takeAngle0From:(UISlider *)sender{
    [self setJoint0AngleRadians:sender.value];
}

- (IBAction)takeAngle1From:(UISlider *)sender{
    [self setJoint1AngleRadians:sender.value];
}

- (IBAction)takeAngle2From:(UISlider *)sender{
    [self setJoint2AngleRadians:sender.value];
}

- (IBAction)takeRigidSkinFrom:(UISwitch *)sender{
    if ([sender isOn]) {
        [self.tube automaticallySkinRigidWithJoints:self.baseEffect.jointsArray];
    } else {
        [self.tube automaticallySkinSmoothWithJoints:self.baseEffect.jointsArray];
    }
}

- (void)dealloc{
    GLKView *view = (GLKView *)self.view;
    [AGLKContext setCurrentContext:view.context];
    
    [EAGLContext setCurrentContext:nil];
    
    self.baseEffect = nil;
    self.bone0 = nil;
    self.bone1 = nil;
    self.bone2 = nil;
    self.tube = nil;
}

@end
