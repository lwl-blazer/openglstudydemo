//
//  mesh.hpp
//  OpenGLTestDemo5
//
//  Created by luowailin on 2019/3/14.
//  Copyright © 2019 luowailin. All rights reserved.
//

#ifndef mesh_hpp
#define mesh_hpp

#include <stdio.h>

#include <glad/glad.h>
#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>

#include "Shader.hpp"

#include <string>
#include <fstream>
#include <sstream>

#include <iostream>
#include <vector>

using namespace std;

struct Vertex {
    glm::vec3 Position;
    
    glm::vec3 Normal;
    
    glm::vec2 TexCoords;
    
    glm::vec3 Tangent;
    
    glm::vec3 Bitangent;
};

struct Texture {
    unsigned int id;
    string type;
    string path;
};

class Mesh {
public:
    vector<Vertex> vertices;
    vector<unsigned int> indices;
    vector<Texture> textures;
    
    unsigned int VAO;
    
    Mesh(vector<Vertex>vertices, vector<unsigned int>indices, vector<Texture>textures);
    
    void Draw(Shader shader);
    
private:
    unsigned int VBO, EBO;
    
    void setupMesh();
};

#endif /* mesh_hpp */
