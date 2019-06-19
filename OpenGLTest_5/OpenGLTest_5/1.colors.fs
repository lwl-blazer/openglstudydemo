
#version 330 core
out vec4 FragColor;
in vec3 Normal;
in vec3 FragPos;

uniform vec3 lightPos;
uniform vec3 viewPos;  //观察者位置

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

    //镜面光照(镜面高光):
    //第一步: 传递摄像头对象的位置   viewPos 对过uniform进行传递
    //第二步：计算高光强度
    float specularStrength = 0.5; //定义一个镜面强度变量 给镜面高光一个中等亮度颜色，让它不要产生过度的影响
    vec3 viewDir = normalize(viewPos - FragPos); //视线方向向量
    //reflect函数的第一个向量是从光源指向片段位置的向量    刚好lightDir相反 所以取反
    vec3 reflectDir = reflect(-lightDir, norm); //对应的沿着的反射向量    对lightDir 取反由上面的减法顺序决定，
    //第三步：计算镜面分量
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), 32);   //视线方向与反射方向的点乘(并确保它不负值) 32 取32次幂  这个32是高光的反光度(Shininess)。一个物体的反光度越高，反射光的能力越强，散射得越少，高光点就越小
    vec3 specular = specularStrength * spec * lightColor;
    
    
    vec3 result = (ambient + diffuse + specular) * objectColor;
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

/** 镜面光照
 *
 * 镜面光照也是依据光的方向向量和物体的法向量来决定的，但是它也依赖于观察方向，例如玩家从什么方向看着这个片段的。镜面光照是基于光的反射特性
 *
 * 通过计算反射法向量周围光的方向来计算反射向量。然后我们计算反射向量和视线方向的角度差，如果夹角越小，那么镜面光的影响就会越大。
 *
 * 观察向量是镜面光照附加的一个变量，我们可以使用观察者世界空间位置和片段的位置来计算它。之后，我们计算镜面光强度，用它乘以光源的颜色，再将它加下环境光和漫反射分量。
 
 * 为了得到观察者的世界空间坐标，我们简单地使用摄像机对象的位置代替
 *
 * 注意:大多数人趋向于在观察空间进行光照计算，在观察空间计算的好处是，观察者的位置总是(0,0,0) 所以这样你直接就获得了观察者位置，需要将所有相关向量都有观察矩阵进行变换(包括法线矩阵)
 */
