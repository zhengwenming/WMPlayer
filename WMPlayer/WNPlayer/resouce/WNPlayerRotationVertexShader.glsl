attribute vec4 position;
attribute vec2 texcoord;
uniform mat4 projection;
uniform mat3 rotation;
varying vec2 v_texcoord;

void main() {
    gl_Position = projection * vec4(rotation * position.xyz, 1.0);
    v_texcoord = texcoord;
}
