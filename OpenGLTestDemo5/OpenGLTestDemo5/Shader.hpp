//
//  Shader.hpp
//  OpenGLTest_2
//
//  Created by luowailin on 2019/2/28.
//  Copyright © 2019 luowailin. All rights reserved.
//

#ifndef Shader_hpp
#define Shader_hpp

#include <stdio.h>
#include <glad/glad.h>

#include <glm/glm.hpp>

#include <string>
#include <fstream>
#include <sstream>
#include <iostream>

class Shader{
public:
    unsigned int ID; //程序ID
    
    Shader(const GLchar *vertexPath, const GLchar *fragmentPath); //构造器 读取并构建着色器
    
    void use(); //使用/激活
    
    //uniform工具函数
    void setBool(const std::string &name, bool value) const;
    void setInt(const std::string &name, int value) const;
    void setFloat(const std::string &name, float value) const;

    void setMat2(const std::string &name, const glm::mat2 &mat) const;
    void setMat3(const std::string &name, const glm::mat3 &mat) const;
    void setMat4(const std::string &name, const glm::mat4 &mat) const;
    void setVec2(const std::string &name, const glm::vec2 &value) const;
    void setVec2(const std::string &name, float x, float y) const;
    void setVec3(const std::string &name, const glm::vec3 &value) const;
    void setVec3(const std::string &name, float x, float y, float z) const;
    void setVec4(const std::string &name, const glm::vec4 &value) const;
    void setVec4(const std::string &name, float x, float y, float z, float w) const;
    
    
private:
    void checkCompileErrors(GLuint shader, std::string type);
};

#endif /* Shader_hpp */
