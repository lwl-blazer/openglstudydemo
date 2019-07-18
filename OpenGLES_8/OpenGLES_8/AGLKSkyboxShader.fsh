
uniform highp mat4 u_mvpMatrix;
uniform samplerCube u_unitCube[1]; //立方体贴图采样哭喊
varying lowp vec3 v_texCoord[1];

void main() {
    
    /** 通过采样器来获取textures的方法，
     * texture属性:例如大小、像素格式、尺寸、滤镜方法、mip-map等级数量、深度信息
     * 在新版的GLSL中使用的是
     * vec4 texture(samplerCube sampler, vec3 coord)
     *
     */
    
    //vec4 textureCube(samplerCube sampler, vec3 coord) / textureCube(samplerCube sampler, vec3 coord, float bias);  使用coord这个坐标去查找当前绑定到采样器的cube map. coord的方向用来表示去查找cube map的哪一个二维平面。
    gl_FragColor = textureCube(u_unitCube[0], v_texCoord[0]);
}
