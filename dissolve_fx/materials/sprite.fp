varying highp vec2 var_texcoord0;
varying mediump vec2 var_noise_texcoord;

uniform lowp sampler2D texture_sampler;

uniform mediump vec4 tint;
uniform mediump vec4 dissolve;
uniform mediump vec4 glow_color;

void main()
{

    // Pre-multiply alpha since all runtime textures already are
    lowp vec4 tint_pm = vec4(tint.xyz * tint.w, tint.w);
    vec4 color = texture2D(texture_sampler, var_texcoord0.xy)*tint_pm;

    if(dissolve.w > 0.0) {
        float noise_value = texture2D(texture_sampler, var_noise_texcoord.xy).r * 0.999;
        float is_visible = noise_value - dissolve.w;
        if (is_visible < 0.0) discard;

        float is_glowing = smoothstep(dissolve.z, .01, is_visible);
        vec3 glow = is_glowing * glow_color.rgb;
        color.rgb = color.rgb + glow;
    }
    gl_FragColor = color;
    
}
