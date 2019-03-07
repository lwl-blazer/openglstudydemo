//
//  Camera.hpp
//  OpenGLTest_3
//
//  Created by luowailin on 2019/3/7.
//  Copyright © 2019 luowailin. All rights reserved.
//

#ifndef Camera_hpp
#define Camera_hpp

#include <stdio.h>
#include <glad/glad.h>
#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>

#include <vector>

enum Camera_Movement {
    FORWARD,
    BACKWARD,
    LEFT,
    RIGHT
};

//默认摄像机坐标数据
const float YAW = -90.0f;
const float PITCH = 0.0f;
const float SPEED = 2.5f;
const float SENSITIVITY = 0.1f;
const float ZOOM = 45.0f;

class Camera {
public:

    //摄像机坐标属性
    glm::vec3 Position;
    glm::vec3 Front;
    glm::vec3 Up;
    glm::vec3 Right;
    glm::vec3 WorldUp;
    
    //欧拉角
    float Yaw;
    float Pitch;
    
    //摄像机选择
    float MovementSpeed;
    float MouseSensitivity;
    float Zoom;
    
    //构造函数  vectors
    Camera(glm::vec3 position = glm::vec3(0.0f, 0.0f, 0.0f), glm::vec3 up = glm::vec3(0.0f, 1.0f, 0.0f), float yaw = YAW, float pitch = PITCH) : Front(glm::vec3(0.0f, 0.0f, -1.0f)), MovementSpeed(SPEED), MouseSensitivity(SENSITIVITY), Zoom(ZOOM){
        Position = position;
        WorldUp = up;
        Yaw = yaw;
        Pitch = pitch;
        updateCameraVectors();
    }
    
    //构造函数  标量数值
    Camera(float posX, float posY, float posZ, float upX, float upY, float upZ, float yaw, float pitch):Front(glm::vec3(0.0f, 0.0f, -1.0f)), MovementSpeed(SPEED), MouseSensitivity(SENSITIVITY), Zoom(ZOOM){
        Position = glm::vec3(posX, posY, posZ);
        WorldUp = glm::vec3(upX, upY, upZ);
        Yaw = yaw;
        Pitch = pitch;
        updateCameraVectors();
    }
    
    //观察空间 lookAt
    glm::mat4 GetViewMatrix();
    
    //按键
    void ProcessKeyboard(Camera_Movement direction, float deltaTime);
    //鼠标移动
    void ProcessMouseMovement(float xoffset, float yoffset, GLboolean constrainPitch = true);
    //鼠标滚轮
    void ProcessMouseScroll(float yoffset);
    
private:
    //计算欧拉角的方向向量
    void updateCameraVectors();
};


#endif /* Camera_hpp */
