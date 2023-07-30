#version 410

#include "uniforms.glsl"
#include "2d_sdf.glsl"

uniform vec3 dColor;
uniform float dChar;

out vec4 fragColor;

void renderChar(uint c, vec2 pp, inout float d, inout float drawingCursor)
{
    if (c == 0)
        d = fOpUnion(d, dCharA(pp - vec2(drawingCursor, 0)));
    else if (c == 1)
        d = fOpUnion(d, dCharB(pp - vec2(drawingCursor, 0)));
    else if (c == 2)
        d = fOpUnion(d, dCharC(pp - vec2(drawingCursor, 0)));
    else if (c == 3)
        d = fOpUnion(d, dCharD(pp - vec2(drawingCursor, 0)));
    else if (c == 4)
        d = fOpUnion(d, dCharE(pp - vec2(drawingCursor, 0)));
    else if (c == 5)
        d = fOpUnion(d, dCharF(pp - vec2(drawingCursor, 0)));
    else if (c == 6)
        d = fOpUnion(d, dCharG(pp - vec2(drawingCursor, 0)));
    else if (c == 7)
        d = fOpUnion(d, dCharH(pp - vec2(drawingCursor, 0)));
    else if (c == 8)
        d = fOpUnion(d, dCharI(pp - vec2(drawingCursor, 0)));
    else if (c == 9)
        d = fOpUnion(d, dCharJ(pp - vec2(drawingCursor, 0)));
    else if (c == 10)
        d = fOpUnion(d, dCharK(pp - vec2(drawingCursor, 0)));
    else if (c == 11)
        d = fOpUnion(d, dCharL(pp - vec2(drawingCursor, 0)));
    else if (c == 12)
        d = fOpUnion(d, dCharM(pp - vec2(drawingCursor, 0)));
    else if (c == 13)
        d = fOpUnion(d, dCharN(pp - vec2(drawingCursor, 0)));
    else if (c == 14)
        d = fOpUnion(d, dCharO(pp - vec2(drawingCursor, 0)));
    else if (c == 15)
        d = fOpUnion(d, dCharP(pp - vec2(drawingCursor, 0)));
    else if (c == 16)
        d = fOpUnion(d, dCharQ(pp - vec2(drawingCursor, 0)));
    else if (c == 17)
        d = fOpUnion(d, dCharR(pp - vec2(drawingCursor, 0)));
    else if (c == 18)
        d = fOpUnion(d, dCharS(pp - vec2(drawingCursor, 0)));
    else if (c == 19)
        d = fOpUnion(d, dCharT(pp - vec2(drawingCursor, 0)));
    else if (c == 20)
        d = fOpUnion(d, dCharU(pp - vec2(drawingCursor, 0)));
    else if (c == 21)
        d = fOpUnion(d, dCharV(pp - vec2(drawingCursor, 0)));
    else if (c == 22)
        d = fOpUnion(d, dCharW(pp - vec2(drawingCursor, 0)));
    else if (c == 23)
        d = fOpUnion(d, dCharX(pp - vec2(drawingCursor, 0)));
    else if (c == 24)
        d = fOpUnion(d, dCharY(pp - vec2(drawingCursor, 0)));
    else if (c == 25)
        d = fOpUnion(d, dCharZ(pp - vec2(drawingCursor, 0)));
    else if (c == 26)
        d = fOpUnion(d, dCharExclamation(pp - vec2(drawingCursor, 0)));
    else if (c == 27)
        d = fOpUnion(d, dCharColon(pp - vec2(drawingCursor, 0)));
    else if (c == 28)
        d = fOpUnion(d, dCharDash(pp - vec2(drawingCursor, 0)));
    else if (c == 29)
        d = fOpUnion(d, dCharUnderscore(pp - vec2(drawingCursor, 0)));
    else if (c == 30)
        d = fOpUnion(d, dCharSpace(pp - vec2(drawingCursor, 0)));
    else
        d = fOpUnion(d, dCharBox(pp - vec2(drawingCursor, 0)));
    drawingCursor += FONT_WIDTH;
}

void main()
{
    // Avoid nags if these aren't used
    if (uTime < -1. || uRes.x < -1.)
        discard;

    vec2 uv = gl_FragCoord.xy / uRes.xy;
    vec3 color = vec3(0);
    float ar = float(uRes.x) / uRes.y;

    vec2 p = (uv * 2. - 1.);
    p.x *= ar;
    p *= 15;
    float r = .5;

    float d = INF;

    // Gridlines
    // if (fract(p.x) < .02 || fract(1. - p.x) < .02)
    //     color = vec3(.1);
    // if (abs(p.x - FONT_WIDTH / 2) < .02 || abs(p.x + FONT_WIDTH/ 2) < .02)
    //     color = vec3(.8, .0, .0);
    // if (abs(p.y - FONT_DESCENDERS) < .02)
    //     color = vec3(.8, .0, .0);
    // if (fract(p.y) < .02 || fract(1. - p.y) < .02)
    //     color = vec3(.1);

    const int CHAR_COUNT_LOADING = 80;
    const int CHARS_LOADING[CHAR_COUNT_LOADING]= int[](11,14,0,3,8,13,6,30,13,14,19,30,11,14,0,3,8,13,6,30,13,14,19,30,11,14,0,3,8,13,6,30,13,14,19,30,11,14,0,3,8,13,6,30,13,14,19,30,11,14,0,3,8,13,6,30,13,14,19,30,11,14,0,3,8,13,6,30,13,14,19,30,11,14,0,3,8,13,6,30);

    const int CHAR_COUNT_CREDITS = 90;
    const int CHARS_CREDITS[CHAR_COUNT_CREDITS]= int[](30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,19,14,30,1,4,30,3,4,2,8,3,4,3,30,28,30,7,24,17,19,18,8,30,11,4,7,3,0,17,8,30,13,17,10,30,18,13,3,4,11,18,30,19,10,11,13,30,28,30,0,18,30,6,17,0,5,5,0,30,1,14,8,18,30);

    const int CHAR_COUNT_GREETS = 216;
    const int CHARS_GREETS[CHAR_COUNT_GREETS]= int[](30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,0,11,19,0,8,17,30,28,30,0,18,3,30,28,30,1,0,3,30,5,4,11,8,23,30,28,30,30,2,14,13,18,15,8,17,0,2,24,30,28,30,3,4,11,8,1,4,17,0,19,4,30,28,30,4,15,14,2,7,30,28,30,7,4,3,4,11,12,0,4,30,28,30,8,18,14,30,28,30,8,21,14,17,24,30,11,0,1,18,30,28,30,10,4,22,11,4,17,18,30,28,30,11,14,6,8,2,14,12,0,30,28,30,12,0,2,0,20,30,4,23,15,14,17,19,18,30,28,30,12,4,7,20,30,28,30,12,4,17,2,20,17,24,30,28,30,15,0,17,18,4,12,14,14,18,4,18,28,30,15,4,8,18,8,10,30,28,30,15,17,8,18,12,1,4,8,13,6,18,30,28,30,18,14,14,3,0,30);

    float greetsStart = 145.;
    float creditsStart = 165.;

    vec2 pp = p;
    // Only consider a moving window from the text. No reason to have non visible
    // characters in the combined SDF, bleeding perf all over the floor
    int windowWidthChars = 20;
    float windowOffset = -30;
    float speed = 10.;
    float cursor = -uTime * speed;
    if (uTime > creditsStart)
    {
        speed = 20.;
        cursor = -(uTime - creditsStart) * speed;
        pp.y += 10;
    }
    else if (uTime > greetsStart)
    {
        speed = 35.;
        cursor = -(uTime - greetsStart) * speed;
        pp.y -= 11;
    }
    // What character is currently leftmost in the visible window
    float charCursor = cursor / FONT_WIDTH;
    int cursorOffset = int(abs(floor(charCursor)));
    // The floating cursor needs to snap the next character when one goes out of the window
    float drawingCursor = fract(charCursor) * FONT_WIDTH;
    drawingCursor += windowOffset;
    if (uTime < greetsStart)
    {
        for (int i = cursorOffset; i < min(cursorOffset + windowWidthChars, CHAR_COUNT_LOADING); ++i)
            renderChar(CHARS_LOADING[i], pp, d, drawingCursor);
    }
    else if (uTime < creditsStart)
    {
        for (int i = cursorOffset; i < min(cursorOffset + windowWidthChars, CHAR_COUNT_GREETS); ++i)
            renderChar(CHARS_GREETS[i], pp, d, drawingCursor);
    }
    else
    {
        for (int i = cursorOffset; i < min(cursorOffset + windowWidthChars, CHAR_COUNT_CREDITS); ++i)
            renderChar(CHARS_CREDITS[i], pp, d, drawingCursor);
    }

    if (uTime < greetsStart)
        fragColor = vec4(vec3(saturate(1. - (d * 20.))), 1);
    else
        // 0 to alpha for composite
        fragColor = vec4(saturate(1. - (d * 20.)));
}
