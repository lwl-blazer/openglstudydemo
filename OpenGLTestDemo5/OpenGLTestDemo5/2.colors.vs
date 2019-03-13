#version 330 core

layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aNormal; //法向量

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

out vec3 Normal;
out vec3 FragPos;   //片段位置向量

void main()
{
    /** 漫反射光照
      我们需要测量这个光线是以什么角度接触到这个片段的。如果光线垂直于物体表面，这束光对物体的影响会最大化(最亮)，为了测量光线和片段的角度。我们使用一个叫做法向量(Normal Vector)的东西， 它是垂直于片段表面的一个向量。
     两个向量之间的角度很容易就能够通过点乘计算出来
     
     计算漫反射光照需要:
     1.法向量   一个垂直于顶点表面的向量
     2.定向的光线    作为光源的位置与片段的位置之间向量差的方向向量。为了计算这个光线，我们需要光的位置向量和片段的位置向量
     
     */
    gl_Position = projection * view * model * vec4(1.0, aPos);
    
    //我们会在世界空间中进行所有的光照计算，所以把顶点位置属性乘以模型矩阵(不是观察和投影矩阵)来把它变换到世界空间坐标
    FragPos = vec3(model * vec4(aPos, 1.0));
    //Normal = aNormal;
    
    //把法向量转换到世界空间坐标中   逆矩阵和转置矩阵 称为法线矩阵
    Normal = mat3(transpose(inverse(model))) * aNormal;
}
