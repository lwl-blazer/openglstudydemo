#version 330 core

out vec4 FragColor;

uniform vec3 objectColor;
uniform vec3 lightColor;

uniform vec3 lightPos;  //光源的位置 

in vec3 Normal;   //法线向量
in vec3 FragPos;  //片段位置向量

void main()
{
    //环境光照
    vec3 ambient = 0.1 * lightColor;
    
    /****** 漫反射光照 *****/
    vec3 norm = normalize(Normal);
    
    //第一步:计算光源和片段位置之间的方向向量  光的方向向量是光源位置向量与片段位置向量之间的向量差。 通过让两个向量相减的方式计算向量差。 切记:我们要确保所有相关向量最后都转换为单位向量，所以我们把法线和最后的方向向量进行标准化
    vec3 lightDir = normalize(lightPos - FragPos);
    
    //第二步: 对Normal和LightDir向量进行点乘，计算光源对当前片段实际的漫发射影响
    float diff = max(dot(norm, lightDir), 0.0f);  //如果两个向量之间的角度大于90度，点乘的结果就会变成负数，这样会导致漫反射分量变为负数 max()就是保证不变成负数
    
    //第三步: 用影响(diff) 乘以光的颜色得到漫反射分量，两个向量之间的角度越大，漫反射分量就会越小
    vec3 diffuse = diff * lightColor;
    
    //输出 环境光分量和漫反射分量，我们把它们相加，然后再乘以物体的颜色，来获得片段最后的输出颜色
    vec3 result = (ambient + diffuse) * objectColor;
    FragColor = vec4(result, 1.0f);
}
