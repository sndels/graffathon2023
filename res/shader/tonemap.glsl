// sRGB, linear space conversions
float stol(float x) { return (x <= 0.04045 ? x / 12.92 : pow((x + 0.055) / 1.055, 2.4)); }
vec3 stol(vec3 c) { return vec3(stol(c.x), stol(c.y), stol(c.z)); }

// From Krzysztof Narkowicz
// https://knarkowicz.wordpress.com/2016/01/06/aces-filmic-tone-mapping-curve/
vec3 ACESFilm(vec3 x)
{
    float a = 2.51f;
    float b = 0.03f;
    float c = 2.43f;
    float d = 0.59f;
    float e = 0.14f;
    return clamp((x * (a * x + b)) / (x * (c * x + d) + e), 0, 1);
}

vec3 tonemap(vec3 color)
{
    float exposure = 1.0;
    float gamma = 2.2;
    vec3 outColor = ACESFilm(color * exposure);
    return pow(outColor, vec3(1 / gamma));
}

