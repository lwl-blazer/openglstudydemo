#version 330 core
out vec4 FragColor;

uniform vec3 objectColor;
uniform vec3 lightColor;

void main()
{
    /**
     我们在现实生活中看到某一物体的颜色并不是这个物体真正拥有的颜色，而是它所反射的(Reflected)颜色，换句话说，那些不能被物体所吸收(Absorb)的颜色(被拒绝的颜色)就是我们能够感知到的物体的颜色。
     
     把光源的颜色与物体的颜色值相乘，所得到的就是这个物体的所射的颜色(也就是我们所感知的颜色)
     */
    //FragColor = vec4(lightColor * objectColor, 1.0);
    
    
    /** 冯氏光照模型
     环境光照:
       我们使用一个很小的常量(光照)颜色，添加到物体片段的最终颜色中，这样的话即便场景中没有直接的光源也能看起来存在有一些发散的光
     */
    float ambientStrength = 0.1;
    vec3 ambient = ambientStrength * lightColor;
    vec3 result = ambient * objectColor;
    FragColor = vec4(result, 1.0f);
}
