
attribute vec3 a_position;
attribute vec3 a_normal;
attribute vec2 a_texCoord0;
attribute vec2 a_texCoord1;
attribute vec4 a_jointMatrixIndices;
attribute vec4 a_jointNormalizedWeights;

#define MAX_TEXTURES (2)
#define MAX_TEX_COORDS (2)

#define MAX_INDEXED_MATRICES (16)

uniform highp mat4 u_modelviewMatrix;
uniform highp mat4 u_mvpMatrix;
uniform highp mat3 u_normalMatrix;
uniform highp mat4 u_tex0Matrix;
uniform highp mat4 u_tex1Matrix;
uniform sampler2D u_unit2d[MAX_TEXTURES];

uniform lowp  float u_tex0Enable;
uniform lowp  float u_tex1Enable;
uniform lowp  vec4 u_globalAmbient;
uniform highp vec3 u_light0Position;
uniform lowp  vec4 u_light0Diffuse;
uniform highp mat4 u_mvpJointMatrices[MAX_INDEXED_MATRICES];
uniform highp mat3 u_normalJointNormalMatrices[MAX_INDEXED_MATRICES];

varying highp vec2 v_texCoord[MAX_TEX_COORDS];
varying lowp  vec4 v_lightColor;

void main(){
    v_texCoord[0] = a_texCoord0;
    v_texCoord[1] = a_texCoord1;
    
    int index0 = int(a_jointMatrixIndices.x);
    int index1 = int(a_jointMatrixIndices.y);
    int index2 = int(a_jointMatrixIndices.z);
    int index3 = int(a_jointMatrixIndices.w);
    
    vec4 unTransformedPosition = vec4(a_position, 1);
    
    gl_Position = (u_mvpJointMatrices[index0] * unTransformedPosition) *
                   a_jointNormalizedWeights.x + (u_mvpJointMatrices[index1] * unTransformedPosition) *
                   a_jointNormalizedWeights.y + (u_mvpJointMatrices[index2] * unTransformedPosition) *
                   a_jointNormalizedWeights.z + (u_mvpJointMatrices[index3] * unTransformedPosition) *
                   a_jointNormalizedWeights.w;
    
    vec3 normal = normalize(
                            (u_normalJointNormalMatrices[index0] * a_normal) *
                            a_jointNormalizedWeights.x + (u_normalJointNormalMatrices[index1] * a_normal) *
                            a_jointNormalizedWeights.y + (u_normalJointNormalMatrices[index2] * a_normal) *
                            a_jointNormalizedWeights.z + (u_normalJointNormalMatrices[index3] * a_normal) * a_jointNormalizedWeights.w);
    
    lowp float nDotL = max(dot(normal, u_light0Position), 0.0);
    v_lightColor = nDotL * u_light0Diffuse;
}
