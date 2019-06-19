#version 330 core
layout (location = 0) in vec3 position;
layout (location = 1) in vec3 aNormal;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

out vec3 Normal;
out vec3 FragPos;   //片段的位置

void main()
{
    gl_Position = projection * view * model * vec4(position, 1.0f);
    
    //片段的位置计算：在世界空间中进行所有的光照计算，因此我们需要一个在世界空间中的顶点位置，我们可以通过把顶点位置属性乘以模型矩阵来把它变换到世界空间坐标
    FragPos = vec3(model * vec4(position, 1.0));  //注意：这里是模型矩阵 不是观察和投影矩阵
    
    /**
     * 目前片段着色器里的计算都是在世界空间坐标中进行的，所以我们应该要把法向量也转换为世界空间坐标
     * 但是法向量不是简单的乘以一个模型矩阵就能搞定的，具体的原因请参考:https://learnopengl-cn.github.io/02%20Lighting/02%20Basic%20Lighting/
     
     * 而是通过一个法线矩阵(定义:模型矩阵左上角的逆矩阵(Inverse Matrix)的转置矩阵(Transpose Matrix));
     */
    Normal = mat3(transpose(inverse(model))) * aNormal;
    
    /**
     * 注意事项：即使是对于着色器来说，逆矩阵也是一个开销比较大的运算，因此，只要可能就应该避免在着色器中进行逆矩阵运算，它们必须为你场景中的每个顶点都进行这样的处理。对于一个对效率有要求的应用来说，在绘制之前你最好用CPU计算出法线矩阵，然后通过uniform把值传递给着色器
     */
}
