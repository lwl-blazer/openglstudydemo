#version 330 core

out vec4 FragColor;

in vec3 ourColor;
in vec2 TexCoord;

//供纹理对象使用的内建数据类型叫采样器(Sampler) 它以纹理类型作为后缀比如sampler1D sampler2D sampler3D
uniform sampler2D texture1;
uniform sampler2D texture2;

void main()
{
    /**
     GLSL内建的texture函数来采样纹理的颜色，它第一个参数是纹理采样器，第二个参数是对应的纹理坐标。texture函数会使用之前设置的纹理参数对相应的颜色值进行采样。这个片段着色器的输出就是纹理的（插值）纹理坐标上的(过滤后的)颜色
     */
    //把得到的纹理颜色与顶点颜色混合，来获得更有趣的效果。
    //FragColor = texture(texture1, TexCoord) * vec4(ourColor, 1.0);
 
    
    /**
     * 两个纹理的结合  mix
     * GLSL内建的mix函数需要接受两个值作为参数， 并对它们根据第三个参数进行线性插值。如果第三个是0.0，它会返回第一个输入，如果是1.0，会返回第二个输入。 0.2会返回80%的第一个输入颜色和20%的第二个输入颜色，即返回两个纹理的混合色
     */
    //FragColor = mix(texture(texture1, TexCoord), texture(texture2, TexCoord), 0.2);
    
    //翻转纹理2
    FragColor = mix(texture(texture1, TexCoord), texture(texture2, vec2(1 - TexCoord.x,  TexCoord.y)), 0.5);
}
