//
//  AGLKPointParticleEffect.m
//  OpenGLES_8
//
//  Created by luowailin on 2019/7/18.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "AGLKPointParticleEffect.h"
#import "AGLKVertexAttribArrayBuffer.h"

//粒子的属性:
typedef struct {
    GLKVector3 emissionPosition; //初始位置
    GLKVector3 emissionVelocity; //速度
    GLKVector3 emissionForce;   //力向量
    GLKVector2 size;  //尺寸
    GLKVector2 emissionTimeAndLife;    //时间
}AGLKParticleAttributes;
//每个粒子的力向量都会随着时间改变粒子的速度。模拟的全局重力也会影响每个粒子的速度。最后每个粒子都会随着时间褪色，直到完全透明，并且每个粒子都有一个寿命，超过这个寿命后，这个粒子就不会再绘制了


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

/** 地球引力(地球表面重力加速度) {0, (-9.80665 m/s/s), 0} assuming +Y up coordinate system    m/s/s 每平方秒每米*/
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
        //重新计算MVP
        GLKMatrix4 modelViewProjectionMatrix = GLKMatrix4Multiply(self.transform.projectionMatrix,
                                                                  self.transform.modelviewMatrix);
        glUniformMatrix4fv(uniforms[AGLKMVPMatrix],
                           1,
                           0,
                           modelViewProjectionMatrix.m);
        //一个纹理采样器
        glUniform1i(uniforms[AGLKSamplers2D], 0);
        
        //粒子物理学
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
    /**
     * glDepthMask()  允许或禁止向深度缓冲区写入数据
     * 多边形的绘图顺序极大地影响了最终的混合效果，为了应对不同深度的图形显示我们要开启深度缓冲区
     * 对已开启深度缓冲区的图形来说，如果一个不透明的物理如果离观察点较近，那么它所遮挡的部分就不会进行绘制
     * 对于存在透明度的图形来说要复杂一些，如果一个透明的物体靠近观察点较近。那么它所遮挡的部分也需要绘制的
     * 使用方法如下面的代码步骤：
     */
    glDepthMask(GL_FALSE);  //step 1
    [self.particleAttributeBuffer drawArrayWithMode:GL_POINTS
                                   startVertexIndex:0
                                   numberOfVertices:(GLsizei)self.numberOfParticles];  //step 2 绘制
    glDepthMask(GL_TRUE);  //step 3 
    
    /** 点精灵
     * 球面粒子效果可以使用与视平截体的近面和远面平行的纹理矩形来创建。每次渲染场景时，都是使用视平截体定义3D可见视域的
     *
     * 不过OpenGL ES还包含一个叫做点精灵(point sprites)的功能，这个甚至要比用两个三角形定义矩形渲染起来更高效
     * 当你用glDrawArrays() 或者 glDrawElements()函数指定GL_POINTS模式后，OpenGL ES 2.0就会渲染点精灵。
     *
     * 点精灵会产生以这个点精灵的位置为中心的正方形内的每个像素颜色渲染缓存的片元。点精灵正方形的长和宽等于在像素颜色渲染缓存坐标系中的当前点精灵的尺寸。不幸的是，自定义shading language程序需要控制每个点精灵的尺寸
     */
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

