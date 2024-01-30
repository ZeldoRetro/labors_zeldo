#if __VERSION__ >= 130
#define COMPAT_VARYING in
#define COMPAT_TEXTURE texture
out vec4 FragColor;
#else
#define COMPAT_VARYING varying
#define FragColor gl_FragColor
#define COMPAT_TEXTURE texture2D
#endif

#ifdef GL_ES
precision mediump float;
#define COMPAT_PRECISION mediump
#else
#define COMPAT_PRECISION
#endif


//inputs from vertex shader
COMPAT_VARYING vec2 sol_vtex_coord;
COMPAT_VARYING vec2 plain_tex_coord;

//uniform values
uniform sampler2D sol_texture;
uniform sampler2D plasma;
uniform float angle;
uniform int sol_time;

vec2 rotate(vec2 v, float a) {
	float s = sin(a);
	float c = cos(a);
	mat2 m = mat2(c, -s, s, c);
	return m * v;
}

void main(void) {
    float time = float(sol_time)*0.005;
    float mask = COMPAT_TEXTURE(sol_texture,sol_vtex_coord).r;
    vec2 pls = vec2(sin(time+sol_vtex_coord.y*8.0)*0.03,0.01*cos(time*0.5+1.0))*mask;
    pls = vec2(0.5)+rotate(pls, angle)*0.5;
    FragColor = vec4(pls,0,1);
    //color = vec4(1,0,0,1);
}
