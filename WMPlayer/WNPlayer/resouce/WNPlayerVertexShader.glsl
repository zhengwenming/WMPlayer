attribute vec4 position;
attribute vec2 texcoord;
uniform mat4 projection;
varying vec2 v_texcoord;

void main() {
    gl_Position = projection * position;
    v_texcoord = texcoord;
}
