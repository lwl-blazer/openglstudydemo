//
//  AGLKPointParticleEffect.m
//  OpenGLES_8
//
//  Created by luowailin on 2019/7/18.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "AGLKPointParticleEffect.h"
#import "AGLKVertexAttribArrayBuffer.h"

typedef struct {
    GLKVector3 emissionPosition;
    GLKVector3 emissionVelocity;
    GLKVector3 emissionForce;
    GLKVector2 size;
    GLKVector2 emissionTimeAndLife;
}AGLKParticleAttributes;


enum {
    AGLKMVPMatrix,
    AGLKSamplers2D,
    AGLKElapsedSeconds,
    AGLKGravity,
    AGLKNumUniforms
};

typedef enum {
    AGLKParticleEmissionPosition = 0,
    AGLKParticleEmissionVelocity,
    AGLKParticleEmissionForce,
    AGLKParticleSize,
    AGLKParticleEmissionTimeAndLife
} AGLKParticleAttrib;

const GLKVector3 AGLKDefaultGravity = {0.0f, -9.80665f, 0.0f};

@interface AGLKPointParticleEffect()
{
    GLuint program;
    GLint uniforms[AGLKNumUniforms];
}

@property(nonatomic, strong) AGLKVertexAttribArrayBuffer *particleAttributeBuffer;

@property(nonatomic, assign) NSUInteger numberOfParticles;
@property(nonatomic, strong) NSMutableData *particleAttributesData;

@property(nonatomic, assign) BOOL particleDataWasUpdated;

@property(nonatomic, strong, readwrite) GLKEffectPropertyTexture *texture2d0;
@property(nonatomic, strong, readwrite) GLKEffectPropertyTransform *transform;

@end


@implementation AGLKPointParticleEffect

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.texture2d0 = [[GLKEffectPropertyTexture alloc] init];
        self.texture2d0.enabled = YES;
        self.texture2d0.name = 0;
        self.texture2d0.target = GLKTextureTarget2D;
        self.texture2d0.envMode = GLKTextureEnvModeReplace;
        
        self.transform = [[GLKEffectPropertyTransform alloc] init];
        self.gravity = AGLKDefaultGravity;
        
        self.elapsedSeconds = 0.0f;
        self.particleAttributesData = [NSMutableData data];
    }
    return self;
}

- (AGLKParticleAttributes)particleAtIndex:(NSUInteger)anIndex{
    NSParameterAssert(anIndex < self.numberOfParticles);
    
    const AGLKParticleAttributes *particlesPtr = (const AGLKParticleAttributes *)[self.particleAttributesData bytes];
    return particlesPtr[anIndex];
}

- (void)setParticle:(AGLKParticleAttributes)aParticle
            atIndex:(NSUInteger)anIndex{
    NSParameterAssert(anIndex < self.numberOfParticles);
    
    AGLKParticleAttributes *particlesPtr = (AGLKParticleAttributes *)[self.particleAttributesData mutableBytes];
    
    particlesPtr[anIndex] = aParticle;
    
    self.particleDataWasUpdated = YES;
}

- (void)addParticleAtPosition:(GLKVector3)aPosition
                     velocity:(GLKVector3)aVelocity
                        force:(GLKVector3)aForce
                         size:(float)size
              lifeSpanSeconds:(NSTimeInterval)aSpan
          fadeDurationSeconds:(NSTimeInterval)aDuration{
    AGLKParticleAttributes newParticle;
    newParticle.emissionPosition = aPosition;
    newParticle.emissionVelocity = aVelocity;
    newParticle.emissionForce = aForce;
    newParticle.size = GLKVector2Make(size, aDuration);
    newParticle.emissionTimeAndLife = GLKVector2Make(self.elapsedSeconds, self.elapsedSeconds + aSpan);
    
    BOOL foundSlot = NO;
    const int count = (int)self.numberOfParticles;
    
    for (int i = 0; i < count && !foundSlot; i++) {
        AGLKParticleAttributes oldParticle = [self particleAtIndex:i];
        
        if (oldParticle.emissionTimeAndLife.y < self.elapsedSeconds) {
            [self setParticle:newParticle atIndex:i];
            foundSlot = YES;
        }
    }
    
    if (!foundSlot) {
        [self.particleAttributesData appendBytes:&newParticle
                                          length:sizeof(newParticle)];
        self.particleDataWasUpdated = YES;
    }
}


- (NSUInteger)numberOfParticles{
    return (NSUInteger)([self.particleAttributesData length] / sizeof(AGLKParticleAttributes));
}

- (void)prepareToDraw{
    
    if (0 == program) {
        [self loadShaders];
    }
    
    if (program != 0) {
        glUseProgram(program);
        
        GLKMatrix4 modelViewProjectionMatrix = GLKMatrix4Multiply(self.transform.projectionMatrix,
                                                                  self.transform.modelviewMatrix);
        glUniformMatrix4fv(uniforms[AGLKMVPMatrix],
                           1,
                           0,
                           modelViewProjectionMatrix.m);
        
        glUniform1i(uniforms[AGLKSamplers2D], 0);
        
        glUniform3fv(uniforms[AGLKGravity], 1, self.gravity.v);
        glUniform1fv(uniforms[AGLKElapsedSeconds], 1, &_elapsedSeconds);
        
        if (self.particleDataWasUpdated) {
            if (nil == self.particleAttributeBuffer && 0 < [self.particleAttributesData length]) {
                self.particleAttributeBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:sizeof(AGLKParticleAttributes)
                                                                                        numberOfVertices:((int)[self.particleAttributesData length]/sizeof(AGLKParticleAttributes))
                                                                                                    data:[self.particleAttributesData bytes] usage:GL_DYNAMIC_DRAW];
            } else{
                [self.particleAttributeBuffer reinitWithAttribStride:sizeof(AGLKParticleAttributes)
                                                    numberOfVertices:((int)[self.particleAttributesData length] / sizeof(AGLKParticleAttributes))
                                                               bytes:[self.particleAttributesData bytes]];
            }
            
            self.particleDataWasUpdated = NO;
        }
        
        [self.particleAttributeBuffer prepareToDrawWithAttrib:AGLKParticleEmissionPosition
                                          numberOfCoordinates:3
                                                 attribOffset:offsetof(AGLKParticleAttributes, emissionPosition)
                                                 shouldEnable:YES];
        
        [self.particleAttributeBuffer prepareToDrawWithAttrib:AGLKParticleEmissionVelocity
                                          numberOfCoordinates:3
                                                 attribOffset:offsetof(AGLKParticleAttributes, emissionVelocity)
                                                 shouldEnable:YES];
        
        [self.particleAttributeBuffer prepareToDrawWithAttrib:AGLKParticleEmissionForce
                                          numberOfCoordinates:3
                                                 attribOffset:offsetof(AGLKParticleAttributes, emissionForce)
                                                 shouldEnable:YES];
        
        [self.particleAttributeBuffer prepareToDrawWithAttrib:AGLKParticleSize
                                          numberOfCoordinates:2
                                                 attribOffset:offsetof(AGLKParticleAttributes, size)
                                                 shouldEnable:YES];
        
        [self.particleAttributeBuffer prepareToDrawWithAttrib:AGLKParticleEmissionTimeAndLife
                                          numberOfCoordinates:2
                                                 attribOffset:offsetof(AGLKParticleAttributes, emissionTimeAndLife)
                                                 shouldEnable:YES];
        
        glActiveTexture(GL_TEXTURE0);
        if (0 != self.texture2d0.name && self.texture2d0.enabled) {
            glBindTexture(GL_TEXTURE_2D, self.texture2d0.name);
        } else {
            glBindTexture(GL_TEXTURE_2D, 0);
        }
    }
}

- (void)draw{
    glDepthMask(GL_FALSE);
    [self.particleAttributeBuffer drawArrayWithMode:GL_POINTS
                                   startVertexIndex:0
                                   numberOfVertices:(GLsizei)self.numberOfParticles];
    glDepthMask(GL_TRUE);
}

- (BOOL)loadShaders{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;

    program = glCreateProgram();
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:
                          @"AGLKPointParticleShader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER
                        file:vertShaderPathname]){
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:
                          @"AGLKPointParticleShader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER
                        file:fragShaderPathname]){
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    glAttachShader(program, vertShader);
    glAttachShader(program, fragShader);
    
    glBindAttribLocation(program, AGLKParticleEmissionPosition,
                         "a_emissionPosition");
    glBindAttribLocation(program, AGLKParticleEmissionVelocity,
                         "a_emissionVelocity");
    glBindAttribLocation(program, AGLKParticleEmissionForce,
                         "a_emissionForce");
    glBindAttribLocation(program, AGLKParticleSize,
                         "a_size");
    glBindAttribLocation(program, AGLKParticleEmissionTimeAndLife,
                         "a_emissionAndDeathTimes");
    
    if (![self linkProgram:program]){
        NSLog(@"Failed to link program: %d", program);
        if (vertShader){
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader){
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (program){
            glDeleteProgram(program);
            program = 0;
        }
        return NO;
    }
    

    uniforms[AGLKMVPMatrix] = glGetUniformLocation(program,
                                                   "u_mvpMatrix");
    uniforms[AGLKSamplers2D] = glGetUniformLocation(program,
                                                    "u_samplers2D");
    uniforms[AGLKGravity] = glGetUniformLocation(program,
                                                 "u_gravity");
    uniforms[AGLKElapsedSeconds] = glGetUniformLocation(program,
                                                        "u_elapsedSeconds");
    
    // Delete vertex and fragment shaders.
    if (vertShader){
        glDetachShader(program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader){
        glDetachShader(program, fragShader);
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
