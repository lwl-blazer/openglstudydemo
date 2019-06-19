
#version 330 core

out vec4 FragColor;

struct Material{ //通过四个要素来定义一个材质颜色
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
    float shininess;
};

struct Light{ //光照属性-光照分量指定一个强度向量
    vec3 position;
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
};

in vec3 FragPos;
in vec3 Normal;

uniform vec3 viewPos;
uniform Material material;
uniform Light light;

void main()
{
    //ambient
    vec3 ambient = light.ambient * material.ambient;
    
    //diffuse
    vec3 norm = normalize(Normal);
    vec3 lightDir = normalize(light.position - FragPos);
    float diff = max(dot(norm, lightDir), 0.0);
    vec3 diffuse = light.diffuse * (diff * material.diffuse);
    
    //specular
    vec3 viewDir = normalize(viewPos - FragPos);
    vec3 reflectDir = reflect(-lightDir, norm);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), material.shininess);
    vec3 specular = light.specular * (spec * material.specular);
    
    vec3 result = ambient + diffuse + specular;
    
    FragColor = vec4(result, 1.0);
}


