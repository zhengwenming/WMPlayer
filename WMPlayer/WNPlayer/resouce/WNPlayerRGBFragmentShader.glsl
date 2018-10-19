varying highp vec2 v_texcoord;
uniform sampler2D s_texture;

void main() {
    gl_FragColor = texture2D(s_texture, v_texcoord);
}
