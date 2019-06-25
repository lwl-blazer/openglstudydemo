
#define MAX_TEXTURES 2
#define MAX_TEX_COORDS 2

uniform highp mat4 u_modelviewMatrix;
uniform highp mat4 u_mvpMatrix;
uniform highp mat3 u_normalMatrix;
uniform highp mat4 u_tex0Matrix;
uniform highp mat4 u_tex1Matrix;
uniform sampler2D u_unit2d[MAX_TEXTURES];

uniform lowp float u_tex0Enabled;
uniform lowp float u_tex1Enabled;

uniform lowp vec4 u_globalAmbient;

//Light0
uniform highp vec3 u_light0EyePos;
uniform lowp vec3 u_light0NormalEyeDirection;
uniform lowp vec4 u_light0Diffuse;
uniform lowp vec4 u_light0Ambient;
uniform highp float u_light0Cutoff;
uniform highp float u_light0Exponent;

//Light1
uniform highp vec3 u_light1EyePos;
uniform lowp vec3 u_light1NormalEyeDirection;
uniform lowp vec4 u_light1Diffuse;
uniform lowp vec4 u_light1Ambient;
uniform highp float u_light1Cutoff;
uniform highp float u_light1Exponent;

uniform highp vec3 u_light2EyePos;
uniform lowp vec4 u_light2Diffuse;


varying highp vec2 v_texCoord[MAX_TEX_COORDS];
varying lowp vec3 v_normal;
varying lowp vec3 v_vertexToLight0;
varying lowp vec4 v_diffuseColor0;

varying lowp vec3 v_vertexToLight1;
varying lowp vec4 v_diffuseColor1;

varying lowp vec4 v_diffuseColor2;

/** 多重纹理处理  混合颜色    --- 取代纹理混合 glEnable(GL_BLEND); glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
 *
 * 这种多重纹理处理就避免了重复和多次绘制，性能比纹理要好，是绘制多个纹理时候的优先选择
 */
void main()
{
    //纹理0
    //Texture0 contribution to color
    lowp vec2 texCoords = v_texCoord[0];    //纹理坐标
    lowp vec4 texCoordsVec4 = vec4(texCoords.s, texCoords.t, 0, 1.0);
    texCoordsVec4 = u_tex0Matrix * texCoordsVec4;
    texCoords = texCoordsVec4.st;
    //纹理采样
    lowp vec4 texColor0 = texture2D(u_unit2d[0], texCoords);
    texColor0 = u_tex0Enabled * texColor0;
    
    
    //Texture1 contribution to color
    texCoords = v_texCoord[1];
    texCoordsVec4 = vec4(texCoords.s, texCoords.t, 0, 1.0);
    texCoordsVec4 = u_tex1Matrix * texCoordsVec4;
    texCoords = texCoordsVec4.st;
    
    lowp vec4 texColor1 = texture2D(u_unit2d[1], texCoords);
    texColor1 = u_tex1Enabled * texColor1;
    
    
    //Combined texture contribution to color
    lowp vec4 combinedTexColor;
    combinedTexColor.rgb = (texColor0.rgb * (1.0 - texColor1.a)) + (texColor1.rgb * texColor1.a);
    combinedTexColor.rgb += (1.0 - max(u_tex0Enabled, u_tex1Enabled)) * vec3(1, 1, 1);
    combinedTexColor.a = max(texColor0.a, texColor1.a);
    
    
    lowp vec3 renormalizedNormal = normalize(v_normal);
    
    //Light0
    highp float nDotL = max(dot(renormalizedNormal, normalize(v_vertexToLight0)), 0.0);
    lowp vec3 vertexDir = -v_vertexToLight0;
    lowp float cosCutoff = cos(u_light0Cutoff);
    lowp float vertexDirDotSpotDir = max(dot(vertexDir, u_light0NormalEyeDirection), 0.0);
    
    highp float spotFactor = 0.0;
    if(vertexDirDotSpotDir >= cosCutoff) {
        spotFactor = pow(vertexDirDotSpotDir, u_light0Exponent);
    }
    
    lowp vec4 diffuseColor = (spotFactor * nDotL * v_diffuseColor0);
    

    //Light1
    nDotL = max(dot(renormalizedNormal, normalize(v_vertexToLight1)), 0.0);
    vertexDir = -v_vertexToLight1;
    cosCutoff = cos(u_light1Cutoff);
    vertexDirDotSpotDir = max(dot(vertexDir, u_light1NormalEyeDirection), 0.0);
    
    spotFactor = 0.0;
    if(vertexDirDotSpotDir >= cosCutoff) {
        spotFactor = pow(vertexDirDotSpotDir, u_light1Exponent);
    }
    diffuseColor += (spotFactor * nDotL * v_diffuseColor1);
    
    //Light2
    diffuseColor += v_diffuseColor2;
    
    //Mix light and texture
   gl_FragColor.rgb = (diffuseColor.rgb + u_globalAmbient.rgb) * combinedTexColor.rgb;
   // gl_FragColor.rgb = u_globalAmbient.rgb * combinedTexColor.rgb;
    gl_FragColor.a = combinedTexColor.a;
}

/**
 *
 * GLSL内建函数 texture()函数来采样纹理的颜色，它第一个参数是纹理采样器，第二个参数是对应的纹理坐标。
 * texture函数会使用之前设置的纹理参数对相应的颜色值进行采样。这个片段着色器的输出就是纹理的(插值)纹理坐标上的(过滤的)的颜色
 */
