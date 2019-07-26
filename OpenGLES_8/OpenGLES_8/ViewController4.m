//
//  ViewController4.m
//  OpenGLES_8
//
//  Created by luowailin on 2019/7/22.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "ViewController4.h"
#import "AGLKContext.h"

#import "UtilityBillboardManager+viewAdditions.h"
#import "UtilityBillboard.h"

#import "UtilityModelManager.h"
#import "UtilityModel+viewAdditions.h"

@interface ViewController4 ()

@property(nonatomic, strong) GLKBaseEffect *baseEffect;
@property(nonatomic, strong) UtilityBillboardManager *billboardManager;
@property(nonatomic, assign, readwrite) GLKVector3 eyePosition;
@property(nonatomic, assign) GLKVector3 lookAtPosition;
@property(nonatomic, assign) GLKVector3 upVector;

@property(nonatomic, assign) float angle;
@property(nonatomic, strong) UtilityModelManager *modelManager;
@property(nonatomic, strong) UtilityModel *parkModel;
@property(nonatomic, strong) UtilityModel *cylinderModel;

@end

@implementation ViewController4

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]], @"not a GLKView");
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    view.context = [[AGLKContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    [EAGLContext setCurrentContext:view.context];
    
    NSString *modelsPath = [[NSBundle mainBundle] pathForResource:@"park"
                                                           ofType:@"modelplist"];
    self.modelManager = [[UtilityModelManager alloc] initWithModelPath:modelsPath];
    self.parkModel = [self.modelManager modelNamed:@"park"];
    NSAssert(nil != self.parkModel, @"Failed to load park model");
    
    self.cylinderModel = [self.modelManager modelNamed:@"cylinder"];
    NSAssert(nil != self.cylinderModel, @"Failed to load cylinder model");
    
    
    [self addBillboardTrees];
    
    self.eyePosition = GLKVector3Make(15,
                                      8,
                                      15);
    self.lookAtPosition = GLKVector3Make(0.0,
                                         0.0,
                                         0.0);
    self.upVector = GLKVector3Make(0.0,
                                   1.0,
                                   0.0);
    
    [(AGLKContext *)view.context setClearColor:GLKVector4Make(0.0f,
                                                              0.0f,
                                                              0.0f,
                                                              1.0f)];
    [(AGLKContext *)view.context enable:GL_DEPTH_TEST];
    [(AGLKContext *)view.context enable:GL_BLEND];
    [(AGLKContext *)view.context setBlendSourceFunction:GL_SRC_ALPHA
                                    destinationFunction:GL_ONE_MINUS_SRC_ALPHA];
    [(AGLKContext *)view.context enable:GL_CULL_FACE];
    
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.light0.enabled = GL_TRUE;
    self.baseEffect.light0.ambientColor = GLKVector4Make(0.8f,
                                                         0.8f,
                                                         0.8f,
                                                         1.0f);
    self.baseEffect.light0.diffuseColor = GLKVector4Make(0.9f,
                                                         0.9f,
                                                         0.9f,
                                                         1.0f);
    
    self.baseEffect.texture2d0.name = self.modelManager.textureInfo.name;
    self.baseEffect.texture2d0.target = self.modelManager.textureInfo.target;
}

- (void)preparePointOfViewWithAspectRatio:(GLfloat)aspectRatio{
    
    self.baseEffect.transform.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(85.0),
                                                                           aspectRatio,
                                                                           0.5f,
                                                                           200.0f);
    
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4MakeLookAt(self.eyePosition.x, self.eyePosition.y, self.eyePosition.z,
                                                                     self.lookAtPosition.x, self.lookAtPosition.y, self.lookAtPosition.z,
                                                                     self.upVector.x, self.upVector.y, self.upVector.z);
    
    self.angle += 0.01;
    self.eyePosition = GLKVector3Make(15.0f * sinf(self.angle),
                                      18.0f + 5.0f * sinf(0.3f * self.angle),
                                      15.0f * cosf(self.angle));
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    const GLfloat aspectRatio = (GLfloat)view.drawableWidth / (GLfloat)view.drawableHeight;
    
    [(AGLKContext *)view.context clear:GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT];
    
    [self preparePointOfViewWithAspectRatio:aspectRatio];
    
    self.baseEffect.light0.position = GLKVector4Make(0.4f,
                                                     0.4f,
                                                     0.2f,
                                                     0.0f);
    
    [self.modelManager prepareToDraw];
    [self.parkModel draw];
    
    const GLKMatrix4 savedModelview = self.baseEffect.transform.modelviewMatrix;
    const GLKMatrix4 translationModelview = GLKMatrix4Translate(savedModelview,
                                                                -5.0f,
                                                                0.0f,
                                                                -5.0f);
    
    if (self.billboardManager.shouldRenderSpherical == YES) {
        GLKMatrix4 rotationModelView = translationModelview;
        rotationModelView.m30 = 0.0f;
        rotationModelView.m31 = 0.0f;
        rotationModelView.m32 = 0.0f;
        
        rotationModelView = GLKMatrix4Transpose(rotationModelView);
        
        self.baseEffect.transform.modelviewMatrix = GLKMatrix4Multiply(translationModelview,
                                                                       rotationModelView);
        
        [self.baseEffect prepareToDraw];
        [self.cylinderModel draw];
    } else {
        self.baseEffect.transform.modelviewMatrix = translationModelview;
        [self.baseEffect prepareToDraw];
        [self.cylinderModel draw];
    }
    
    self.baseEffect.transform.modelviewMatrix = savedModelview;
    [self.baseEffect prepareToDraw];
    
    const GLKVector3 lookDirection = GLKVector3Subtract(self.lookAtPosition, self.eyePosition);
    
    [self.billboardManager updateWithEyePosition:self.eyePosition
                                   lookDirection:lookDirection];
    
    [self.billboardManager drawWithEyePosition:self.eyePosition
                                 lookDirection:lookDirection
                                      upVector:self.upVector];
    
    {
        GLenum error = glGetError();
        if(GL_NO_ERROR != error)
        {
            NSLog(@"GL Error: 0x%x", error);
        }
    }
}


- (void)addBillboardTrees{
    if (self.billboardManager == nil) {
        self.billboardManager = [[UtilityBillboardManager alloc] init];
    }
    
    for (int j = -4; j < 4; j++) {
        for (int i = -4; i < 4; i++) {
            const NSUInteger treeIndex = random() % 2;
            const GLfloat minTextureT = treeIndex * 0.25f;
            
            [self.billboardManager addBillboardAtPosition:GLKVector3Make(i * -10.0f - 5.0f,
                                                                         0.0,
                                                                         j * -10.0f - 5.0f)
                                                     size:GLKVector2Make(8.0f, 8.0f)
                                         minTextureCoords:GLKVector2Make(3.0f/8.0f,
                                                                         1.0f - minTextureT)
                                         maxTextureCoords:GLKVector2Make(7.0f/8.0f,
                                                                         1.0f - (minTextureT + 0.25f))];
        }
    }
}

- (IBAction)takeShouldRenderSpherical:(UISwitch *)sender{
    self.billboardManager.shouldRenderSpherical = [sender isOn];
}

- (void)dealloc{
    self.baseEffect = nil;
    self.billboardManager = nil;
    self.parkModel = nil;
    self.cylinderModel = nil;
}

@end
