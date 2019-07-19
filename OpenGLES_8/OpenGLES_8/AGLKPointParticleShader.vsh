/**
 * 顶点着色器是使用每个每顶点属性和每个统一变量值来执行物理运算的，这里的统一变量是指用于重力、逝去时间、纹理取样标识符、model-view矩阵与投影矩阵的结合的统一变量值。使用完全基于初始位置(粒子创建后就不再改变)、初始速度、力和逝去时间的经典牛顿物理方程式来重新计算每个粒子的位置并存储在内置的gl_Position变量中。每个粒子的尺寸都存储在另一个内置变量gl_PointSize中
 */
attribute vec3 a_emissionPosition;
attribute vec3 a_emissionVelocity;
attribute vec3 a_emissionForce;
attribute vec2 a_size;
attribute vec2 a_emissionAndDeathTimes;

uniform highp mat4 u_mvpMatrix;
uniform sampler2D u_sampler2D[1];
uniform highp vec3 u_gravity;
uniform highp float u_elapsedSeconds;

varying lowp float v_particleOpacity;

void main()
{
    highp float elapsedTime = u_elapsedSeconds - a_emissionAndDeathTimes.x;
    
    highp vec3 velocity = a_emissionVelocity + ((a_emissionForce + u_gravity) * elapsedTime);
    
    highp vec3 untransformedPosition = a_emissionPosition + 0.5 * (a_emissionVelocity + velocity) * elapsedTime;
    
    gl_Position = u_mvpMatrix * vec4(untransformedPosition, 1.0);
    gl_PointSize = a_size.x / gl_Position.w; //每个顶点的点大小会被除以像素颜色渲染缓存坐标中的粒子位置的w的部分。w大体相当于粒子与平截体近面之间的距离。除以w模拟了粒子退向远处时的基于透视的收缩
    
    //计算每个粒子的半透明度并使用可变变量v_particleOpacity来传递这个值到片元着色器中。
    v_particleOpacity = max(0.0, min(1.0, (a_emissionAndDeathTimes.y - u_elapsedSeconds)/max(a_size.y, 0.00001)));
}


