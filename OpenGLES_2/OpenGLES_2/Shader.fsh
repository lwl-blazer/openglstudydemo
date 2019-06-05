
uniform sampler2D uSampler0;
uniform sampler2D uSampler1;

varying lowp vec4 vColor;
varying lowp vec2 vTextureCoord0;
varying lowp vec2 vTextureCoord1;

void main()
{
    lowp vec4 color0 = texture2D(uSampler0, vTextureCoord0);
    lowp vec4 color1 = texture2D(uSampler1, vTextureCoord1);
    
    gl_FragColor = mix(color0, color1, color1.a) * vColor;
}
