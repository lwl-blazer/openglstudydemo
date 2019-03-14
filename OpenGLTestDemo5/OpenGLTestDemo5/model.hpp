//
//  model.hpp
//  OpenGLTestDemo5
//
//  Created by luowailin on 2019/3/14.
//  Copyright © 2019 luowailin. All rights reserved.
//

#ifndef model_hpp
#define model_hpp

#include <stdio.h>
#include <glad/glad.h>
#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>

#include <assimp/Importer.hpp>
#include <assimp/scene.h>
#include <assimp/postprocess.h>

#include "stb_image.h"
#include "Shader.hpp"
#include "mesh.hpp"

#include <string>
#include <fstream>
#include <sstream>
#include <iostream>
#include <map>
#include <vector>

using namespace std;

class Model{
public:
    vector<Texture> texture_loaded;
    vector<Mesh> meshes;
    string directory;
    bool gammaCorrection;
    
    Model(string const &path, bool gamma = false):gammaCorrection(gamma){
        loadModel(path);
    }
    
    void Draw(Shader shader);
    
private:
    void loadModel(string const &path);
    void processNode(aiNode *node, const aiScene *scene);
    Mesh processMesh(aiMesh *mesh, const aiScene *scene);
    vector<Texture>loadMaterialTextures(aiMaterial *mat, aiTextureType type, string typeName);
    unsigned int TextureFromFile(const char *path, const string &directory, bool gamma);
    
    
};



#endif /* model_hpp */
