//
//  UtilityArmatureBaseEffect.m
//  OpenGLES_7
//
//  Created by luowailin on 2019/7/12.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "UtilityArmatureBaseEffect.h"
#import "UtilityJoint.h"

#define MAX_INDEXED_MATRICES (16)

enum{
    AGLKModelviewMatrix,
    AGLKMVPMatrix,
    AGLKNormalMatrix,
    AGLKTex0Matrix,
    AGLKTex1Matrix,
    AGLKSamplers2D,
    AGLKTex0Enabled,
    AGLKTex1Enabled,
    AGLKGlobalAmbient,
    AGLKLight0EyePosition,
    AGLKLight0Diffuse,
    AGLKMVPJointMatrices,
    AGLKNormalJointNormalMatrices,
    AGLKNumUniforms
};

@interface UtilityArmatureBaseEffect (){
    GLuint _program;
    GLint _uniforms[AGLKNumUniforms];
}

@property(nonatomic, assign) GLKVector3 light0EyePosition;
@property(nonatomic, assign) GLKVector3 light0EyeDirection;
@property(nonatomic, assign) GLKVector3 light1EyePosition;
@property(nonatomic, assign) GLKVector3 light1EyeDirection;
@property(nonatomic, assign) GLKVector3 light2EyePosition;

@property(nonatomic, assign) GLKMatrix4 *mvpArmatureJointMatrices;
@property(nonatomic, assign) GLKMatrix3 *normalArmatureJointNormalMatrices;

@end

@implementation UtilityArmatureBaseEffect

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.textureMatrix2d0 = GLKMatrix4Identity;
        self.textureMatrix2d1 = GLKMatrix4Identity;
        
        self.texture2d0.enabled = GL_FALSE;
        self.texture2d0.enabled = GL_FALSE;
        
        self.mvpArmatureJointMatrices = calloc(sizeof(GLKMatrix4),
                                               MAX_INDEXED_MATRICES);
        self.normalArmatureJointNormalMatrices = calloc(sizeof(GLKMatrix3),
                                                        MAX_INDEXED_MATRICES);
        
        for (int i = 0; i < MAX_INDEXED_MATRICES; i ++) {
            self.mvpArmatureJointMatrices[i] = GLKMatrix4Identity;
            self.normalArmatureJointNormalMatrices[i] = GLKMatrix3Identity;
        }
    }
    return self;
}

//在运行时更新关节属性，通过prepareToDrawArmature发送消息(信息是指Shading Language 程序重新计算GPU当前内存中的顶点和法向量所需要的信息)，
- (void)prepareToDrawArmature{
    GLKMatrix4 modelViewProjectionMatrix = GLKMatrix4Multiply(self.transform.projectionMatrix, self.transform.modelviewMatrix);
    
    self.mvpArmatureJointMatrices[0] = modelViewProjectionMatrix;
    self.normalArmatureJointNormalMatrices[0] = self.transform.normalMatrix;
    
    NSUInteger jointMatrixIndex = 1;
    for (UtilityJoint *joint in self.jointsArray) {
        
        if (jointMatrixIndex < MAX_INDEXED_MATRICES) {
            
            GLKMatrix4 tempMatrix = joint.cumulativeTransforms;
            self.mvpArmatureJointMatrices[jointMatrixIndex] = GLKMatrix4Multiply(modelViewProjectionMatrix,
                                                                                 tempMatrix);
            bool isInvertible;
            GLKMatrix3 jointNormalMatrix = GLKMatrix4GetMatrix3(GLKMatrix4InvertAndTranspose(tempMatrix,
                                                                                             &isInvertible));
            if (isInvertible) {
                jointNormalMatrix = GLKMatrix3Multiply(self.transform.normalMatrix,
                                                       jointNormalMatrix);
            } else {
                jointNormalMatrix = self.transform.normalMatrix;
            }
            self.normalArmatureJointNormalMatrices[jointMatrixIndex] = jointNormalMatrix;
        }
        jointMatrixIndex ++;
    }
    
    if (_program == 0) {
        [self loadShaders];
    }
    
    if (_program != 0) {
        glUseProgram(_program);
        
        const GLuint samplerIDs[2] = {0, 1};
        
        glUniformMatrix4fv(_uniforms[AGLKModelviewMatrix], 1, GL_FALSE, self.transform.modelviewMatrix.m);
        glUniformMatrix4fv(_uniforms[AGLKMVPMatrix], 1, 0, modelViewProjectionMatrix.m);
        glUniformMatrix3fv(_uniforms[AGLKNormalMatrix], 1, GL_FALSE, self.transform.normalMatrix.m);
        
        glUniformMatrix4fv(_uniforms[AGLKTex0Matrix], 1, GL_FALSE, self.textureMatrix2d0.m);
        glUniformMatrix4fv(_uniforms[AGLKTex1Matrix], 1, GL_FALSE, self.textureMatrix2d1.m);
        
        glUniform1iv(_uniforms[AGLKSamplers2D], 2, (const GLint *)samplerIDs);
        
        GLKVector4 globalAmbient = GLKVector4Multiply(self.lightModelAmbientColor,
                                                      self.material.ambientColor);
        if (self.light0.enabled) {
            globalAmbient = GLKVector4Add(globalAmbient, GLKVector4Multiply(self.light0.ambientColor,
                                                                            self.material.ambientColor));
        }
        glUniform4fv(_uniforms[AGLKGlobalAmbient], 1, globalAmbient.v);
        
        
        glUniform1f(_uniforms[AGLKTex0Enabled], self.texture2d0.enabled ? 1.0 : 0.0);
        glUniform1f(_uniforms[AGLKTex1Enabled], self.texture2d1.enabled ? 1.0 : 0.0);
        
        if (self.light0.enabled) {
            GLKVector3 normalizedEyePosition = GLKVector3Normalize(self.light0EyePosition);
            glUniform3fv(_uniforms[AGLKLight0EyePosition], 1, normalizedEyePosition.v);
            glUniform4fv(_uniforms[AGLKLight0Diffuse], 1, GLKVector4Multiply(self.light0.diffuseColor,
                                                                             self.material.diffuseColor).v);
        } else {
            glUniform4fv(_uniforms[AGLKLight0Diffuse], 1, GLKVector4Make(0.0f, 0.0f, 0.0f, 1.0f).v);
        }
        
        glUniformMatrix4fv(_uniforms[AGLKMVPJointMatrices], MAX_INDEXED_MATRICES,
                           GL_FALSE,
                           self.mvpArmatureJointMatrices[0].m);
        glUniformMatrix3fv(_uniforms[AGLKNormalJointNormalMatrices], MAX_INDEXED_MATRICES,
                           GL_FALSE,
                           self.normalArmatureJointNormalMatrices[0].m);
        
        glActiveTexture(GL_TEXTURE0);
        if (self.texture2d0.name != 0 && self.texture2d0.enabled) {
            glBindTexture(GL_TEXTURE_2D, self.texture2d0.name);
        } else {
            glBindTexture(GL_TEXTURE_2D, 0);
        }
        
        glActiveTexture(GL_TEXTURE1);
        if (self.texture2d1.name != 0 && self.texture2d1.enabled) {
            glBindTexture(GL_TEXTURE_2D, self.texture2d1.name);
        } else {
            glBindTexture(GL_TEXTURE_2D, 0);
        }
        
#ifdef DEBUG
        GLenum error = glGetError();
        if (GL_NO_ERROR != error) {
            NSLog(@"GL ERROR: 0x%x", error);
        }
#endif
    }
}

- (GLKVector4)light0Position{
    return self.light0.position;
}

- (void)setLight0Position:(GLKVector4)aPosition{
    self.light0.position = aPosition;
    
    aPosition = GLKMatrix4MultiplyVector4(self.light0.transform.modelviewMatrix, aPosition);
    
    _light0EyePosition = GLKVector3Make(aPosition.x,
                                        aPosition.y,
                                        aPosition.z);
}

- (GLKVector4)light1Position{
    return self.light1.position;
}

- (void)setLight1Position:(GLKVector4)aPosition{
    self.light1.position = aPosition;
    
    aPosition = GLKMatrix4MultiplyVector4(self.light1.transform.modelviewMatrix,
                                          aPosition);
    
    _light1EyePosition = GLKVector3Make(aPosition.x,
                                        aPosition.y,
                                        aPosition.z);
}

- (GLKVector3)light1SpotDirection{
    return self.light1.spotDirection;
}

- (void)setLight1SpotDirection:(GLKVector3)aDirection{
    self.light1.spotDirection = aDirection;
    
    aDirection = GLKMatrix4MultiplyVector3(self.light1.transform.modelviewMatrix,
                                           aDirection);
    
    self.light1EyeDirection = GLKVector3Normalize(GLKVector3Make(aDirection.x,
                                                                 aDirection.y,
                                                                 aDirection.z));
}

- (GLKVector4)light2Position{
    return self.light2.position;
}

- (void)setLight2Position:(GLKVector4)aPosition{
    self.light2.position = aPosition;
    
    aPosition = GLKMatrix4MultiplyVector4(self.light2.transform.modelviewMatrix,
                                          aPosition);
    
    self.light2EyePosition = GLKVector3Make(aPosition.x,
                                            aPosition.y,
                                            aPosition.z);
}

#pragma mark -- shader compilation

- (BOOL)loadShaders{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    _program = glCreateProgram();
    
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:
                          @"UtilityArmaturePointLightShader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER
                        file:vertShaderPathname]){
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:
                          @"UtilityArmaturePointLightShader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER
                        file:fragShaderPathname]){
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    glAttachShader(_program, vertShader);
    glAttachShader(_program, fragShader);
    
    glBindAttribLocation(_program,
                         UtilityArmatureVertexAttribPosition,
                         "a_position");
    glBindAttribLocation(_program,
                         UtilityArmatureVertexAttribNormal,
                         "a_normal");
    glBindAttribLocation(_program,
                         UtilityArmatureVertexAttribTexCoord0,
                         "a_texCoord0");
    glBindAttribLocation(_program,
                         UtilityArmatureVertexAttribTexCoord1,
                         "a_texCoord1");
    glBindAttribLocation(_program,
                         UtilityArmatureVertexAttribJointMatrixIndices,
                         "a_jointMatrixIndices");
    glBindAttribLocation(_program,
                         UtilityArmatureVertexAttribJointNormalizedWeights,
                         "a_jointNormalizedWeights");
    
    if (![self linkProgram:_program]){
        NSLog(@"Failed to link program: %d", _program);
        
        if (vertShader)
        {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader)
        {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program)
        {
            glDeleteProgram(_program);
            _program = 0;
        }
        
        return NO;
    }
    
    _uniforms[AGLKModelviewMatrix] = glGetUniformLocation(_program, "u_modelviewMatrix");
    _uniforms[AGLKMVPMatrix] = glGetUniformLocation(_program,
                                                    "u_mvpMatrix");
    _uniforms[AGLKNormalMatrix] = glGetUniformLocation(_program,
                                                       "u_normalMatrix");
    _uniforms[AGLKTex0Matrix] = glGetUniformLocation(_program,
                                                     "u_tex0Matrix");
    _uniforms[AGLKTex1Matrix] = glGetUniformLocation(_program,
                                                     "u_tex1Matrix");
    _uniforms[AGLKSamplers2D] = glGetUniformLocation(_program,
                                                     "u_samplers2D");
    _uniforms[AGLKTex0Enabled] = glGetUniformLocation(_program,
                                                      "u_tex0Enabled");
    _uniforms[AGLKTex1Enabled] = glGetUniformLocation(_program,
                                                      "u_tex1Enabled");
    _uniforms[AGLKGlobalAmbient] = glGetUniformLocation(_program,
                                                        "u_globalAmbient");
    _uniforms[AGLKLight0EyePosition] = glGetUniformLocation(_program, "u_light0Position");
    _uniforms[AGLKLight0Diffuse] = glGetUniformLocation(_program,
                                                        "u_light0Diffuse");
    _uniforms[AGLKMVPJointMatrices] = glGetUniformLocation(_program,
                                                           "u_mvpJointMatrices");
    _uniforms[AGLKNormalJointNormalMatrices] =
    glGetUniformLocation(_program, "u_normalJointNormalMatrices");
    
    if (vertShader){
        glDetachShader(_program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader){
        glDetachShader(_program, fragShader);
        glDeleteShader(fragShader);
    }
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader
                 type:(GLenum)type
                 file:(NSString *)file{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file
                                                  encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source){
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0){
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0){
        glDeleteShader(*shader);
        return NO;
    }
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0){
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0){
        return NO;
    }
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0){
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0){
        return NO;
    }
    return YES;
}

@end


@implementation GLKEffectPropertyTexture (AGLKAdditions)

- (void)aglkSetParameter:(GLenum)parameterID value:(GLint)value{
    
    glBindTexture(self.target, self.name);
    
    glTexParameteri(self.target, parameterID, value);
}

@end
