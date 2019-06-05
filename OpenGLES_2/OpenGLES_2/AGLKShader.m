//
//  AGLKShader.m
//  OpenGLES_2
//
//  Created by luowailin on 2019/6/5.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "AGLKShader.h"

@implementation AGLKShader

- (instancetype)initWithShader:(NSString *)shaderName
{
    self = [super init];
    if (self) {
        GLuint vertShader, fragShader;
        NSString *vertShaderPathname, *fragShaderPathname;
        
        self.program = glCreateProgram();
        
        vertShaderPathname = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"vsh"];
        if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
            NSLog(@"Failed to compile vertex shader");
        }
        
        fragShaderPathname = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"fsh"];
        if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
            NSLog(@"Failed to compile framge shader");
        }
        
        glAttachShader(self.program, vertShader);
        glAttachShader(self.program, fragShader);
        
        if (![self linkProgram:self.program]) {
            NSLog(@"faile to link program");
            
            if (vertShader) {
                glDeleteShader(vertShader);
                vertShader = 0;
            }
            
            if (fragShader) {
                glDeleteShader(fragShader);
                fragShader = 0;
            }
            
            if (self.program) {
                glDeleteProgram(self.program);
                self.program = 0;
            }
        }
        
        if (vertShader) {
            glDetachShader(self.program, vertShader);
            glDeleteShader(vertShader);
        }
        
        if (fragShader) {
            glDetachShader(self.program, fragShader);
            glDeleteShader(fragShader);
        }
    }
    return self;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file{
    GLint status;
    const GLchar *source;
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#ifdef DEBUG
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n %s", log);
        free(log);
    }
    
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog{
    GLint status;
    glLinkProgram(prog);
    
#ifdef DEBUG
    
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog{
    
    GLint loglength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &loglength);
    
    if (loglength > 0) {
        GLchar *log = (GLchar *)malloc(loglength);
        
        glGetProgramInfoLog(prog, loglength, &loglength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    return YES;
}


#pragma mark -- public metod
- (void)bindAttribute:(GLuint)location name:(NSString *)name{
    glBindAttribLocation(self.program, location, (GLchar *)name.UTF8String);
}

- (int)getUniform:(NSString *)uniformName{
    return glGetUniformLocation(self.program, (GLchar *)uniformName.UTF8String);
}

- (void)setMat4:(NSString *)name value:(float *)value{
    glUniformMatrix4fv(glGetUniformLocation(self.program, name.UTF8String), 1, 0, value);
}

- (void)setMat3:(NSString *)name value:(float *)value{
    glUniformMatrix3fv(glGetUniformLocation(self.program, name.UTF8String), 1, 0, value);
}

- (void)setInt:(NSString *)name value:(GLint)value{
    glUniform1i(glGetUniformLocation(self.program, name.UTF8String), value);
}

- (void)useProgram{
    glUseProgram(self.program);
}

- (void)dealloc{
    if (self.program) {
        glDeleteProgram(self.program);
        self.program = 0;
    }
}

@end
