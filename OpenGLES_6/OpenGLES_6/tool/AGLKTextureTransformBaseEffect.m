//
//  AGLKTextureRotationBaseEffect.m
//  OpenGLES_5
//
//  Created by luowailin on 2019/6/20.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "AGLKTextureTransformBaseEffect.h"
#import "AGLKShader.h"

enum{
    AGLKModelviewMatrix,
    AGLKMVPMatrix,
    AGLKNormalMatrix,
    AGLKTex0Matrix,
    AGLKTex1Matrix,
    AGLKSamplers,
    AGLKTex0Enabled,
    AGLKTex1Enabled,
    AGLKGlobalAmbient,
    AGLKLight0Pos,
    AGLKLight0Direction,
    AGLKLight0Diffuse,
    AGLKLight0Cutoff,
    AGLKLight0Exponent,
    AGLKLight1Pos,
    AGLKLight1Direction,
    AGLKLight1Diffuse,
    AGLKLight1Cutoff,
    AGLKLight1Exponent,
    AGLKLight2Pos,
    AGLKLight2Diffuse,
    AGLKNumUniforms
};


@interface AGLKTextureTransformBaseEffect ()
{
    GLuint _program;
    GLint _uniforms[AGLKNumUniforms];
}

@property(nonatomic, assign) GLKVector3 light0EyePosition;
@property(nonatomic, assign) GLKVector3 light0EyeDirection;

@property(nonatomic, assign) GLKVector3 light1EyePosition;
@property(nonatomic, assign) GLKVector3 light1EyeDirection;

@property(nonatomic, assign) GLKVector3 light2EyePosition;

@property(nonatomic, strong) AGLKShader *shader;

@end

@implementation AGLKTextureTransformBaseEffect

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.textureMatrix2d0 = GLKMatrix4Identity;
        self.textureMatrix2d1 = GLKMatrix4Identity;
        
        //关掉父类GLKBaseEffect的一些属性
        self.texture2d0.enabled = GL_FALSE;
        self.texture2d0.enabled = GL_FALSE;
        
        self.material.ambientColor = GLKVector4Make(1.0f,
                                                    1.0f,
                                                    1.0f,
                                                    1.0f);
        
        self.lightModelAmbientColor = GLKVector4Make(1.0f,
                                                     1.0f,
                                                     1.0f,
                                                     1.0f);
        
        self.light0.enabled = GL_FALSE;
        self.light1.enabled = GL_FALSE;
        self.light2.enabled = GL_FALSE;
    }
    return self;
}

- (void)prepareToDrawMultitextures{
    if (_program == 0) {
        [self loadShaders];
    }
    
    if (_program != 0) {
        glUseProgram(_program);
        
        const GLuint samplerIDs[2] = {0, 1};
        
        GLKMatrix4 modelViewProjectMatrix = GLKMatrix4Multiply(self.transform.projectionMatrix,
                                                               self.transform.modelviewMatrix);
        
        //modelViewProjectMatrix 传值
        glUniformMatrix4fv(_uniforms[AGLKModelviewMatrix],
                           1,
                           0,
                           self.transform.modelviewMatrix.m);
        glUniformMatrix4fv(_uniforms[AGLKMVPMatrix],
                           1,
                           0,
                           modelViewProjectMatrix.m);
        
        glUniformMatrix3fv(_uniforms[AGLKNormalMatrix],
                           1,
                           0,
                           self.transform.normalMatrix.m);
        
        glUniformMatrix4fv(_uniforms[AGLKTex0Matrix],
                           1,
                           0,
                           self.textureMatrix2d0.m);
        
        glUniformMatrix4fv(_uniforms[AGLKTex1Matrix],
                           1, 0, self.textureMatrix2d1.m);
        
        glUniform1iv(_uniforms[AGLKSamplers],
                     2,
                     (const GLint *)samplerIDs);
        
        //环境光
        GLKVector4 globalAmbient = GLKVector4Multiply(self.lightModelAmbientColor,
                                                      self.material.ambientColor);
        if (self.light0.enabled) {
            globalAmbient = GLKVector4Add(globalAmbient,
                                          GLKVector4Multiply(self.light0.ambientColor,
                                                             self.material.ambientColor));
        }
        if (self.light1.enabled) {
            globalAmbient = GLKVector4Add(globalAmbient,
                                          GLKVector4Multiply(self.light1.ambientColor,
                                                             self.material.ambientColor));
        }
        if (self.light2.enabled) {
            globalAmbient = GLKVector4Add(globalAmbient,
                                          GLKVector4Multiply(self.light2.ambientColor,
                                                             self.material.ambientColor));
        }
        glUniform4fv(_uniforms[AGLKGlobalAmbient],
                     1,
                     globalAmbient.v);
        
        
        glUniform1f(_uniforms[AGLKTex0Enabled],
                    self.texture2d0.enabled ? 1.0 : 0.0);
        glUniform1f(_uniforms[AGLKTex1Enabled],
                    self.texture2d1.enabled ? 1.0 : 0.0);
        
        //Light0
        if (self.light0.enabled) {
            glUniform3fv(_uniforms[AGLKLight0Pos],
                         1,
                         self.light0EyePosition.v);
            glUniform3fv(_uniforms[AGLKLight0Direction],
                         1,
                         self.light0EyeDirection.v);
            glUniform4fv(_uniforms[AGLKLight0Diffuse],
                         1,
                         GLKVector4Multiply(self.light0.diffuseColor,
                                            self.material.diffuseColor).v);
            
            glUniform1f(_uniforms[AGLKLight0Cutoff],
                        GLKMathDegreesToRadians(self.light0.spotCutoff));
            
            glUniform1f(_uniforms[AGLKLight0Exponent],
                        self.light0.spotExponent);
        } else {
            glUniform4fv(_uniforms[AGLKLight0Diffuse],
                         1,
                         GLKVector4Make(0.0f, 0.0f, 0.0f, 1.0f).v);
        }
        
        //light1
        if (self.light1.enabled) {
            glUniform3fv(_uniforms[AGLKLight1Pos],
                         1,
                         self.light1EyePosition.v);
            
            glUniform3fv(_uniforms[AGLKLight1Direction],
                         1,
                         self.light1EyeDirection.v);
            
            glUniform4fv(_uniforms[AGLKLight1Diffuse],
                         1,
                         GLKVector4Multiply(self.light1.diffuseColor,
                                            self.material.diffuseColor).v);
            
            glUniform1f(_uniforms[AGLKLight1Cutoff],
                        GLKMathDegreesToRadians(self.light1.spotCutoff));
            
            glUniform1f(_uniforms[AGLKLight1Exponent],
                        self.light1.spotExponent);
        } else {
            glUniform4fv(_uniforms[AGLKLight1Diffuse],
                         1,
                         GLKVector4Make(0.0, 0.0, 0.0, 1.0).v);
        }
        
        //Light2
        if (self.light2.enabled) {
            glUniform3fv(_uniforms[AGLKLight2Pos],
                         1,
                         self.light2EyePosition.v);
            
            glUniform4fv(_uniforms[AGLKLight2Diffuse],
                         1,
                         GLKVector4Multiply(self.light2.diffuseColor,
                                            self.material.diffuseColor).v);
        } else {
            glUniform4fv(_uniforms[AGLKLight2Diffuse],
                         1,
                         GLKVector4Make(0.0f, 0.0f, 0.0f, 1.0f).v);
        }
        
        
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
        if (error != GL_NO_ERROR) {
            NSLog(@"GL Error");
        }
#endif
    }
}

- (GLKVector4)light0Position{
    return self.light0.position;
}

- (void)setLight0Position:(GLKVector4)light0Position{
    self.light0.position = light0Position;
    
    light0Position = GLKMatrix4MultiplyVector4(self.light0.transform.modelviewMatrix,
                                               light0Position);
    
    self.light0EyePosition = GLKVector3Make(light0Position.x,
                                            light0Position.y,
                                            light0Position.z);
}

- (GLKVector3)light0SpotDirection{
    return self.light0.spotDirection;
}


- (void)setLight0SpotDirection:(GLKVector3)light0SpotDirection{
    self.light0.spotDirection = light0SpotDirection;
    
    light0SpotDirection = GLKMatrix4MultiplyVector3(self.light0.transform.modelviewMatrix,
                                                    light0SpotDirection);
    
    self.light0EyeDirection = GLKVector3Normalize(GLKVector3Make(light0SpotDirection.x,
                                                                 light0SpotDirection.y,
                                                                 light0SpotDirection.z));
}

- (GLKVector4)light1Position{
    return self.light1.position;
}

- (void)setLight1Position:(GLKVector4)light1Position{
    self.light1.position = light1Position;
    light1Position = GLKMatrix4MultiplyVector4(self.light1.transform.modelviewMatrix,
                                               light1Position);
    
    self.light1EyePosition = GLKVector3Make(light1Position.x,
                                            light1Position.y,
                                            light1Position.z);
}

- (GLKVector3)light1SpotDirection{
    return self.light1.spotDirection;
}

- (void)setLight1SpotDirection:(GLKVector3)light1SpotDirection{
    self.light1.spotDirection = light1SpotDirection;
    
    light1SpotDirection = GLKMatrix4MultiplyVector3(self.light1.transform.modelviewMatrix,
                                                    light1SpotDirection);
    
    self.light1EyeDirection = GLKVector3Normalize(GLKVector3Make(light1SpotDirection.x,
                                                                 light1SpotDirection.y,
                                                                 light1SpotDirection.z));
}

- (GLKVector4)light2Position{
    return self.light2.position;
}

- (void)setLight2Position:(GLKVector4)light2Position{
    self.light2.position = light2Position;
    
    light2Position = GLKMatrix4MultiplyVector4(self.light2.transform.modelviewMatrix,
                                               light2Position);
    
    self.light2EyePosition = GLKVector3Make(light2Position.x,
                                            light2Position.y,
                                            light2Position.z);
}


/*
- (BOOL)loadShaders{
    self.shader = [[AGLKShader alloc] initWithShader:@"AGLKTextureMatrix2PointLightShader"];
    _program = self.shader.program;
    
    [self.shader bindAttribute:GLKVertexAttribPosition name:@"a_position"];
    [self.shader bindAttribute:GLKVertexAttribNormal name:@"a_normal"];
    [self.shader bindAttribute:GLKVertexAttribTexCoord0 name:@"a_texCoord0"];
    [self.shader bindAttribute:GLKVertexAttribTexCoord1 name:@"a_texCoord1"];
 
    [self.shader linkProgram];
    
    _uniforms[AGLKModelviewMatrix] = [self.shader getUniform:@"u_modelviewMatrix"];
    _uniforms[AGLKMVPMatrix] = [self.shader getUniform:@"u_mvpMatrix"];
    _uniforms[AGLKNormalMatrix] = [self.shader getUniform:@"u_normalMatrix"];
    _uniforms[AGLKTex0Matrix] = [self.shader getUniform:@"u_tex0Matrix"];
    _uniforms[AGLKTex1Matrix] = [self.shader getUniform:@"u_tex1Matrix"];
    
    _uniforms[AGLKSamplers] = [self.shader getUniform:@"u_unit2d"];
    _uniforms[AGLKTex0Enabled] = [self.shader getUniform:@"u_tex0Enable"];
    _uniforms[AGLKTex1Enabled] = [self.shader getUniform:@"u_tex1Enable"];
    
    _uniforms[AGLKGlobalAmbient] = [self.shader getUniform:@"u_globalAmbient"];
    
    _uniforms[AGLKLight0Pos] = [self.shader getUniform:@"u_light0EyePos"];
    _uniforms[AGLKLight0Direction] = [self.shader getUniform:@"u_light0NormalEyeDirection"];
    _uniforms[AGLKLight0Diffuse] = [self.shader getUniform:@"u_light0Diffuse"];
    _uniforms[AGLKLight0Cutoff] = [self.shader getUniform:@"u_light0Cutoff"];
    _uniforms[AGLKLight0Exponent] = [self.shader getUniform:@"u_light0Exponent"];
    
    _uniforms[AGLKLight1Pos] = [self.shader getUniform:@"u_light1EyePos"];
    _uniforms[AGLKLight1Direction] = [self.shader getUniform:@"u_light1EyeDirection"];
    _uniforms[AGLKLight1Diffuse] = [self.shader getUniform:@"u_light1Diffuse"];
    _uniforms[AGLKLight1Cutoff] = [self.shader getUniform:@"u_light1Cutoff"];
    _uniforms[AGLKLight1Exponent] = [self.shader getUniform:@"u_light1Exponent"];
    
    _uniforms[AGLKLight2Pos] = [self.shader getUniform:@"u_light2EyePos"];
    _uniforms[AGLKLight2Diffuse] = [self.shader getUniform:@"u_light2Diffuse"];

    [self.shader detachShader];
    
    return YES;
}
*/


- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    _program = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:
                          @"AGLKTextureMatrix2PointLightShader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER
                        file:vertShaderPathname])
    {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:
                          @"AGLKTextureMatrix2PointLightShader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER
                        file:fragShaderPathname])
    {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(_program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(_program, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(_program, GLKVertexAttribPosition,
                         "a_position");
    glBindAttribLocation(_program, GLKVertexAttribNormal,
                         "a_normal");
    glBindAttribLocation(_program, GLKVertexAttribTexCoord0,
                         "a_texCoord0");
    glBindAttribLocation(_program, GLKVertexAttribTexCoord1,
                         "a_texCoord1");
    
    // Link program.
    if (![self linkProgram:_program])
    {
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
    
    // Get uniform locations.
    _uniforms[AGLKModelviewMatrix] = glGetUniformLocation(_program, "u_modelviewMatrix");
    _uniforms[AGLKMVPMatrix] = glGetUniformLocation(_program,
                                                    "u_mvpMatrix");
    _uniforms[AGLKNormalMatrix] = glGetUniformLocation(_program,
                                                       "u_normalMatrix");
    _uniforms[AGLKTex0Matrix] = glGetUniformLocation(_program,
                                                     "u_tex0Matrix");
    _uniforms[AGLKTex1Matrix] = glGetUniformLocation(_program,
                                                     "u_tex1Matrix");
    _uniforms[AGLKSamplers] = glGetUniformLocation(_program,
                                                   "u_unit2d");
    _uniforms[AGLKTex0Enabled] = glGetUniformLocation(_program,
                                                      "u_tex0Enabled");
    _uniforms[AGLKTex1Enabled] = glGetUniformLocation(_program,
                                                      "u_tex1Enabled");
    _uniforms[AGLKGlobalAmbient] = glGetUniformLocation(_program,
                                                        "u_globalAmbient");
    _uniforms[AGLKLight0Pos] = glGetUniformLocation(_program,
                                                    "u_light0EyePos");
    _uniforms[AGLKLight0Direction] = glGetUniformLocation(_program, "u_light0NormalEyeDirection");
    _uniforms[AGLKLight0Diffuse] = glGetUniformLocation(_program,
                                                        "u_light0Diffuse");
    _uniforms[AGLKLight0Cutoff] = glGetUniformLocation(_program,
                                                       "u_light0Cutoff");
    _uniforms[AGLKLight0Exponent] = glGetUniformLocation(_program, "u_light0Exponent");
    _uniforms[AGLKLight1Pos] = glGetUniformLocation(_program,
                                                    "u_light1EyePos");
    _uniforms[AGLKLight1Direction] = glGetUniformLocation(_program, "u_light1NormalEyeDirection");
    _uniforms[AGLKLight1Diffuse] = glGetUniformLocation(_program,
                                                        "u_light1Diffuse");
    _uniforms[AGLKLight1Cutoff] = glGetUniformLocation(_program,
                                                       "u_light1Cutoff");
    _uniforms[AGLKLight1Exponent] = glGetUniformLocation(_program, "u_light1Exponent");
    _uniforms[AGLKLight2Pos] = glGetUniformLocation(_program,
                                                    "u_light2EyePos");
    _uniforms[AGLKLight2Diffuse] = glGetUniformLocation(_program,
                                                        "u_light2Diffuse");
    
    // Delete vertex and fragment shaders.
    if (vertShader)
    {
        glDetachShader(_program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader)
    {
        glDetachShader(_program, fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
}


/////////////////////////////////////////////////////////////////
// Returns YES if the Shading Language program in file
// compiles successfully. Logs an error message and returns NO
// otherwise. Returns newly created Shader ID in shader.
// This method is based on Apple's sample code.
- (BOOL)compileShader:(GLuint *)shader
                 type:(GLenum)type
                 file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file
                                                  encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source)
    {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0)
    {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}


/////////////////////////////////////////////////////////////////
// Returns YES if the receiver's Shading Language programs
// link successfully. Logs an error message and returns NO
// otherwise.
// This method is based on Apple's sample code.
- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}


/////////////////////////////////////////////////////////////////
// Returns YES if the receiver's Shading Language programs
// are valid. Logs an error message and returns NO otherwise.
// This method is based on Apple's sample code.
- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}


@end


@implementation GLKEffectPropertyTexture(AGLKAdditions)

- (void)aglkSetParameter:(GLenum)parameterID value:(GLint)value{
    glBindTexture(self.target,
                  self.name);
    glTexParameteri(self.target,
                    parameterID,
                    value);
}

@end
