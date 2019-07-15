
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
uniform lowp  vec3 u_light0Diffuse;
uniform highp mat4 u_mvpJointMatricess[MAX_INDEXED_MATRICES];
uniform highp mat4 u_normalJointNormalMatrices[MAX_INDEXED_MATRICES];

varying highp vec2 v_texCoord[MAX_TEX_COORDS];
varying highp vec4 v_lightColor;

void main() {
    //texture0
    lowp vec2 texCoords = v_texCoord[0];
    lowp vec4 texCoordVec4 = vec4(texCoords.s, texCoords.t, 0, 1.0);
    
    texCoordVec4 = u_tex0Matrix * texCoordVec4;
    texCoords = texCoordVec4.st;
    
    lowp vec4 texColor0 = texture2D(u_unit2d[0], texCoords);
    texColor0 = u_tex0Enable * texColor0;
    
    //texture1
    texCoords = v_texCoord[1];
    texCoordVec4 = vec4(texCoords.s, texCoords.t, 0, 1.0);
    texCoordVec4 = u_tex1Matrix * texCoordVec4;
    texCoords = texCoordVec4.st;
    lowp vec4 texColor1 = texture2D(u_unit2d[1], texCoords);
    texColor1 = u_tex1Enable * texColor1;
    
    lowp vec4 combinedTexColor;
    combinedTexColor.rgb = (texColor0.rgb * (1.0 - texColor1.a)) + (texColor1.rgb * texColor1.a);
    combinedTexColor.rgb += (1.0 - max(u_tex0Enable, u_tex1Enable)) * vec3(1.0, 1.0, 1.0);
    combinedTexColor.a = max(texColor0.a, texColor1.a);
    
    gl_FragColor.rgb = (v_lightColor.rgb + u_globalAmbient.rgb) * combinedTexColor.rgb;
    gl_FragColor.a = combinedTexColor.a;
}
