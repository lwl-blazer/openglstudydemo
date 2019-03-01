#version 330 core
out vec4 FragColor;

in vec3 ourColor;
in vec2 TexCoord;

uniform float mixValue;

uniform sampler2D texture1;
uniform sampler2D texture2;

void main()
{
    //两个纹理之间线性插值
    FragColor = mix(texture(texture1, TexCoord), texture(texture2, TexCoord), mixValue);
}
