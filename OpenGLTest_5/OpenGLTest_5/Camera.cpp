//
//  Camera.cpp
//  OpenGLTest_3
//
//  Created by luowailin on 2019/3/7.
//  Copyright © 2019 luowailin. All rights reserved.
//

#include "Camera.hpp"
glm::mat4 Camera::GetViewMatrix(){
    return glm::lookAt(Position, Position + Front, Up);
}

void Camera::ProcessKeyboard(Camera_Movement direction, float deltaTime){
    float velocity = MovementSpeed * deltaTime;
    
    if (direction == FORWARD) {
        Position += Front * velocity;
    }
    if (direction == BACKWARD) {
        Position -= Front * velocity;
    }
    if (direction == LEFT) {
        Position -= Right * velocity;
    }
    if (direction == RIGHT) {
        Position += Right * velocity;
    }
}

void Camera::ProcessMouseMovement(float xoffset, float yoffset, GLboolean constrainPitch){
    xoffset += MouseSensitivity;
    yoffset += MouseSensitivity;
    
    Yaw += xoffset;
    Pitch += yoffset;
    //上下的角度的限制
    if (constrainPitch) {
        if (Pitch > 89.0f) {
            Pitch = 89.0f;
        }
        if (Pitch < -89.0f) {
            Pitch = -89.0f;
        }
    }
    
    updateCameraVectors();
}

void Camera::ProcessMouseScroll(float yoffset){
    //缩放的限制
    if (Zoom >= 1.0f && Zoom <= 45.0f) {
        Zoom -= yoffset;
    }
    
    if (Zoom <= 1.0f) {
        Zoom = 1.0f;
    }
    
    if (Zoom >= 45.0f) {
        Zoom = 45.0f;
    }
}

void Camera::updateCameraVectors(){
    glm::vec3 front;
    front.x = cos(glm::radians(Yaw)) * cos(glm::radians(Pitch));
    front.y = sin(glm::radians(Pitch));
    front.z = sin(glm::radians(Yaw)) * cos(glm::radians(Pitch));
    Front = glm::normalize(front);
    
    Right = glm::normalize(glm::cross(Front, WorldUp));
    Up = glm::normalize(glm::cross(Right, Front));
}
