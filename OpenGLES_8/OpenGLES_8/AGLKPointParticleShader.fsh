
uniform highp mat4 u_mvpMatrix;
uniform sampler2D u_samplers2D[1];
uniform highp vec3 u_gravity;
uniform highp float u_elapsedSeconds;

varying lowp float v_particleOpacity;

void main()
{
    lowp vec4 textureColor = texture2D(u_samplers2D[0], gl_PointCoord); //求出片元颜色，同时使用了由统一变量u_samplers2D指定的取样器和另一个内置的shading Language魔法位所提供的纹理坐标。
    textureColor.a = textureColor.a * v_particleOpacity;    //实现粒子的半透明
    gl_FragColor = textureColor;
}

/**
 * gl_PointCoord
 * 是一个两元素矢量，每个元素都在0.0到1.0的范围之内，并且对应于当前正在被渲染的点精灵内的片元的{s, t}纹理位置。
 *
 */
