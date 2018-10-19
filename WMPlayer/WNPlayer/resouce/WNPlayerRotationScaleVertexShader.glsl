attribute vec4 position;
attribute vec2 texcoord;
uniform mat4 projection;
uniform mat3 rotation;
uniform mat3 ratio;
uniform mat3 scale;
uniform mat3 viewratio;
varying vec2 v_texcoord;

void main() {
    gl_Position = projection * vec4(scale * viewratio * rotation * ratio * position.xyz, 1.0);
    v_texcoord = texcoord;
}
