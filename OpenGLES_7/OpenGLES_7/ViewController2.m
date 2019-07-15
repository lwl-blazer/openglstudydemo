//
//  ViewController2.m
//  OpenGLES_7
//
//  Created by luowailin on 2019/7/12.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "ViewController2.h"
#import "UtilityModelManager.h"
#import "UtilityModel+viewAdditions.h"
#import "UtilityModel+skinning.h"
#import "UtilityModelManager+skinning.h"
#import "UtilityJoint.h"
#import "UtilityArmatureBaseEffect.h"
#import "AGLKContext.h"

@interface ViewController2 ()

@property(nonatomic, strong) UtilityModelManager *modelManager;
@property(nonatomic, strong) UtilityArmatureBaseEffect *baseEffect;

@property(nonatomic, strong) UtilityModel *bone0;
@property(nonatomic, strong) UtilityModel *bone1;
@property(nonatomic, strong) UtilityModel *bone2;

@property(nonatomic, assign) float joint0AngleRadians;
@property(nonatomic, assign) float joint1AngleRadians;
@property(nonatomic, assign) float joint2AngleRadians;

@end

@implementation ViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]], @"view controller's view is not a GLKView");
    
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
    
    NSString *modelsPath = [[NSBundle mainBundle] pathForResource:@"armature"
                                                           ofType:@"modelplist"];
    if (nil != modelsPath) {
        self.modelManager = [[UtilityModelManager alloc] initWithModelPath:modelsPath];
    }
    
    self.bone0 = [self.modelManager modelNamed:@"bone0"];
    NSAssert(self.bone0 != nil, @"Failed to load bone0 faile");
    [self.bone0 assignJoint:0];
    
    self.bone1 = [self.modelManager modelNamed:@"bone1"];
    NSAssert(self.bone1 != nil, @"Failed to load bone1 faile");
    [self.bone1 assignJoint:1];
    
    self.bone2 = [self.modelManager modelNamed:@"bone2"];
    NSAssert(self.bone2 != nil, @"Failed to load bone2 faile");
    [self.bone2 assignJoint:2];
    
    UtilityJoint *bone0Joint = [[UtilityJoint alloc] initWithDisplacement:GLKVector3Make(0, 0, 0)
                                                                parent:nil];
    float bone0Length = self.bone0.axisAlignedBoundingBox.max.y - self.bone0.axisAlignedBoundingBox.min.y;

    UtilityJoint *bone1Joint = [[UtilityJoint alloc] initWithDisplacement:GLKVector3Make(0, bone0Length, 0)
                                                                   parent:bone0Joint];
    float bone1Length = self.bone1.axisAlignedBoundingBox.max.y - self.bone1.axisAlignedBoundingBox.min.y;
    
    UtilityJoint *bone2Joint = [[UtilityJoint alloc] initWithDisplacement:GLKVector3Make(0, bone1Length, 0)
                                                                   parent:bone1Joint];
    self.baseEffect.jointsArray = [NSArray arrayWithObjects:bone0Joint,
                                   bone1Joint,
                                   bone2Joint,
                                   nil];
    
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4MakeLookAt(5.0, 10.0, 15.0,
                                                                     0.0, 2.0, 0.0,
                                                                     0.0, 1.0, 0.0);
    
    [self setJoint0AngleRadians:0];
    [self setJoint0AngleRadians:0];
    [self setJoint0AngleRadians:0];
    
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    [((AGLKContext *)view.context) clear:GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT];
    [((AGLKContext *)view.context) enable:GL_CULL_FACE];
    
    const GLfloat aspectRatio = (GLfloat)view.drawableWidth/(GLfloat)view.drawableHeight;
    
    self.baseEffect.transform.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(30.0f),
                                                                           aspectRatio,
                                                                           4.0f,
                                                                           20.0f);
    
    [self.modelManager prepareToDrawWithJointInfluence];
    [self.baseEffect prepareToDrawArmature];
    
    [self.bone0 draw];
    [self.bone1 draw];
    [self.bone2 draw];
    
#ifdef DEBUG
    {
        GLenum error = glGetError();
        if (GL_NO_ERROR != error) {
            NSLog(@"GL Error: 0x%x", error);
        }
    }
#endif
    
}

- (void)dealloc{
    GLKView *view = (GLKView *)self;
    [AGLKContext setCurrentContext:view.context];
    
    [EAGLContext setCurrentContext:nil];
    
    self.baseEffect = nil;
    self.bone0 = nil;
    self.bone1 = nil;
    self.bone2 = nil;
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

- (IBAction)takeAngle0From:(UISlider *)sender{
    [self setJoint0AngleRadians:sender.value];
}

- (IBAction)takeAngle1From:(UISlider *)sender{
    [self setJoint1AngleRadians:sender.value];
}

- (IBAction)takeAngle2From:(UISlider *)sender{
    [self setJoint2AngleRadians:sender.value];
}


@end
