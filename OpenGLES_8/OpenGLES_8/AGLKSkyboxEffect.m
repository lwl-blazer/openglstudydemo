//
//  AGLKSkyboxEffect.m
//  OpenGLES_8
//
//  Created by luowailin on 2019/7/17.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "AGLKSkyboxEffect.h"
#import <OpenGLES/ES3/glext.h>

const static int AGLKSkyboxNumVertexIndices = 14;
const static int AGLKSkyboxNumCoords = 24;

enum{
    AGLKMVPMatrix,
    AGLKSamplersCube,
    AGLKNumUniforms
};

@interface AGLKSkyboxEffect(){
    GLuint vertexBufferID;
    GLuint indexBufferID;
    GLuint program;
    GLuint vertexArrayID;
    GLint uniforms[AGLKNumUniforms];
}

@property(nonatomic, strong, readwrite) GLKEffectPropertyTexture *textureCubeMap;
@property(nonatomic, strong, readwrite) GLKEffectPropertyTransform *transform;

@end

@implementation AGLKSkyboxEffect

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.textureCubeMap = [[GLKEffectPropertyTexture alloc] init];
        self.textureCubeMap.enabled = YES;
        self.textureCubeMap.name = 0;
        self.textureCubeMap.target = GLKTextureTargetCubeMap;
        self.textureCubeMap.envMode = GLKTextureEnvModeReplace;
        
        self.transform = [[GLKEffectPropertyTransform alloc] init];
        
        self.center = GLKVector3Make(0, 0, 0);
        self.xSize = 1.0f;
        self.ySize = 1.0f;
        self.zSize = 1.0f;
        
        //纹理坐标
        const float vertices[AGLKSkyboxNumCoords] = {
            -0.5, -0.5,  0.5,
             0.5, -0.5,  0.5,
            -0.5,  0.5,  0.5,
             0.5,  0.5,  0.5,
            -0.5, -0.5, -0.5,
             0.5, -0.5, -0.5,
            -0.5,  0.5, -0.5,
             0.5,  0.5, -0.5,
        };
        
        glGenBuffers(1, &vertexBufferID);
        glBindBuffer(GL_ARRAY_BUFFER, vertexBufferID);
        glBufferData(GL_ARRAY_BUFFER,
                     sizeof(vertices),
                     vertices,
                     GL_STATIC_DRAW);
        
        //索引坐标
        const GLubyte indices[AGLKSkyboxNumVertexIndices] = {
            1, 2, 3,
            7, 1, 5,
            4, 7, 6,
            2, 4, 0,
            1, 2
        };
        glGenBuffers(1, &indexBufferID);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBufferID);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER,
                     sizeof(indices),
                     indices,
                     GL_STATIC_DRAW);
    }
    return self;
}

- (void)dealloc{
    if (vertexArrayID != 0) {
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        glDeleteBuffers(1, &vertexArrayID);
        vertexArrayID = 0;
    }
    
    if (indexBufferID != 0) {
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        glDeleteBuffers(1, &vertexBufferID);
    }
    
    if (indexBufferID != 0) {
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
        glDeleteBuffers(1, &indexBufferID);
    }
    
    if (program != 0) {
        glUseProgram(0);
        glDeleteProgram(program);
    }
}

- (void)prepareToDraw{
    if (program == 0) {
        [self loadShaders];
    }
    
    if (program != 0) {
        glUseProgram(program);
        
        GLKMatrix4 skyboxModelView = GLKMatrix4Translate(self.transform.modelviewMatrix,
                                                         self.center.x,
                                                         self.center.y,
                                                         self.center.z);
        
        skyboxModelView = GLKMatrix4Scale(skyboxModelView,
                                          self.xSize,
                                          self.ySize,
                                          self.zSize);
        
        GLKMatrix4 modelViewProjectionMatrix = GLKMatrix4Multiply(self.transform.projectionMatrix,
                                                                  skyboxModelView);
        glUniformMatrix4fv(uniforms[AGLKMVPMatrix],
                           1,
                           0,
                           modelViewProjectionMatrix.m);
        
        glUniform1i(uniforms[AGLKSamplersCube], 0);
        
        if (vertexArrayID == 0) {
            glGenBuffers(1, &vertexArrayID);
            glBindVertexArray(vertexArrayID);  //先绑定VAO  再处理VBO
            
            glEnableVertexAttribArray(GLKVertexAttribPosition);
            glBindBuffer(GL_ARRAY_BUFFER, vertexBufferID);
            glVertexAttribPointer(GLKVertexAttribPosition,
                                  3,
                                  GL_FLOAT,
                                  GL_FALSE,
                                  0,
                                  NULL);
        } else {
            glBindVertexArray(vertexArrayID);
        }
        
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBufferID);
        
        if (self.textureCubeMap.enabled) {
            glBindTexture(GL_TEXTURE_CUBE_MAP,
                          self.textureCubeMap.name);
        } else {
            glBindTexture(GL_TEXTURE_CUBE_MAP, 0);
        }
    }
}

- (void)draw{
    glDrawElements(GL_TRIANGLE_STRIP, AGLKSkyboxNumVertexIndices, GL_UNSIGNED_BYTE, NULL);
}

#pragma mark -  OpenGL ES 2 shader compilation
- (BOOL)loadShaders{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;

    program = glCreateProgram();
    
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:
                          @"AGLKSkyboxShader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER
                        file:vertShaderPathname]){
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:
                          @"AGLKSkyboxShader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER
                        file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    glAttachShader(program, vertShader);
    glAttachShader(program, fragShader);
    glBindAttribLocation(program, GLKVertexAttribPosition,
                         "a_position");
    
    if (![self linkProgram:program]) {
        NSLog(@"Failed to link program: %d", program);
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        
        if (program) {
            glDeleteProgram(program);
            program = 0;
        }
        return NO;
    }
    
    uniforms[AGLKMVPMatrix] = glGetUniformLocation(program,
                                                   "u_mvpMatrix");
    uniforms[AGLKSamplersCube] = glGetUniformLocation(program,
                                                      "u_samplersCube");
    if (vertShader) {
        glDetachShader(program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(program, fragShader);
        glDeleteShader(fragShader);
    }
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader
                 type:(GLenum)type
                 file:(NSString *)file {
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file
                                                  encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
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

- (BOOL)linkProgram:(GLuint)prog {
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

- (BOOL)validateProgram:(GLuint)prog {
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
