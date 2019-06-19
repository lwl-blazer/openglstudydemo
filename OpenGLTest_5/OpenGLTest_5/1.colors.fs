
#version 330 core
out vec4 FragColor;
in vec3 Normal;
in vec3 FragPos;

uniform vec3 lightPos;

uniform vec3 objectColor;
uniform vec3 lightColor;

void main()
{
    //环境光照  就是全局照明的算法
    float ambientStrength = 0.1;
    vec3 ambient = ambientStrength * lightColor;
    
    
    //漫反射光照:
    vec3 norm = normalize(Normal); //标准化或者说是变成单位向量
    //第一步：计算光源和片段位置之间的方向向量  光的方向向量是光源位置向量与片段位置向量之间的向量差
    vec3 lightDir = normalize(lightPos - FragPos);
    //第二步:我们对norm 和lightDir 向量进行点乘，计算光源对当前片段实际的漫发射影响。结果值再乘以光的颜色，得到漫反射分量。  两个向量之间的角度越大，漫反射分量就会越小
    float diff = max(dot(norm, lightDir), 0.0);
    vec3 diffuse = diff * lightColor;

    
    
    vec3 result = (ambient + diffuse) * objectColor;
    FragColor = vec4(result, 1.0);   //lightColor *objectColor 是颜色被吸收然后反射的概念
}

/** 冯氏光照模型
 * 1.环境光照(Ambient Lighting)
 * 2.漫反射光照 (Diffuse Lighting)
 * 3.镜面光照 (Specular Lighting)
 */

/** 漫反射光照
 * 漫反射光照使物体上与光线方向越接近的片段能从光源处获得更多的亮度。
 *
 * 我们需要测量这个光线是以什么角度接触到这个片段的。 如果光线垂直于物体表面，这束光对物体的影响会最大化。为了测量和片段的角度，使用一个叫法向量(Normal Vector)的东西
 
 * 法向量: 通过点乘计算出来
 * 单位向量:长度为1的向量， 为了得到两个向量夹角的余弦值，我们必须单位向量(就是确保所有的向量都是标准化)，否则点乘返回的就不仅仅是余弦值了
 * 计算漫反射光照需要什么：
     法向量:一个垂直于顶点表面的向量
     定向的光线:作为光源的位置与片段的位置之间向量差的方向向量。为了计算这个光线，我们需要光的位置向量和片段的位置向量
 */
