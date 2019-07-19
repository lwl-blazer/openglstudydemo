
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
    gl_PointSize = a_size.x / gl_Position.w;
    
    v_particleOpacity = max(0.0, min(1.0, (a_emissionAndDeathTimes.y - u_elapsedSeconds)/max(a_size.y, 0.00001)));
}


