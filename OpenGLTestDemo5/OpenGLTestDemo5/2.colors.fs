#version 330 core

out vec4 FragColor;

uniform vec3 objectColor;
uniform vec3 lightColor;

uniform vec3 lightPos;  //光源的位置 
uniform vec3 viewPos; 

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
    //vec3 result = (ambient + diffuse) * objectColor;
    //FragColor = vec4(result, 1.0f);
    
    
    /** 镜面高光
     镜面光照也是根据光的方向向量和物体的法向量来决定的，但是它也依赖于观察方向
     镜面光照是基于光的反射特性, 我们通过反射法向量周围光的方向来计算反射向量，然后我们计算反射向量和视线方向的角度差
     */
    //第一步 镜面强度   给镜面高光一个中等亮度颜色，让它不要产生过度的影响
    float specularStrength = 0.5;
    //第二步 计算视线方向向量
    vec3 viewDir = normalize(viewPos - FragPos);
    //第三步 沿着法线轴的反射向量
    vec3 reflectDir = reflect(-lightDir, norm); //-lightDir 进行了取反 reflect函数要求第一个向量是从光源指向片段位置的向量 但是lightDir刚好相反是从片段指向光源(由先前我们计算lightDir向量时，减法顺序决定的)
    
    //第四步 计算镜面分量
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), 32);  //先计算视线方向与反射方向的点乘（并确保它不是负值），然后取它的32次幂。这个32是高光的反光度(Shininess)。一个物体的反光度越高，反射光的能力越强，散射得越少，高光点就会越小
    
    vec3 specular = specularStrength * spec * lightColor;
    
    vec3 result = (ambient + diffuse + specular) * objectColor;
    FragColor = vec4(result, 1.0f);

}
