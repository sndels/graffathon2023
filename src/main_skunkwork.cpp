#include <cmath>
#include <algorithm>
#include <GL/gl3w.h>
#include <filesystem>
#include <sync.h>
#include <track.h>

#include "audioStream.hpp"
#include "gpuProfiler.hpp"
#include "gui.hpp"
#include <cstdio>
#include "quad.hpp"
#include "shader.hpp"
#include "frameBuffer.hpp"
#include "timer.hpp"
#include "window.hpp"

// Comment out to compile in demo-mode, so close when music stops etc.
// #define DEMO_MODE
#ifndef DEMO_MODE
// Comment out to load sync from files
//  #define TCPROCKET
#endif // !DEMO_MODE

#ifdef TCPROCKET
//Set up audio callbacks for rocket
static struct sync_cb audioSync = {
    AudioStream::pauseStream,
    AudioStream::setStreamRow,
    AudioStream::isStreamPlaying
};
#endif // TCPROCKET

#define XRES 1920
#define YRES 1080

int main(int argc, char *argv[])
{
    int displayIndex = 0;
    if (argc == 2)
    {
        if (strncmp(argv[1], "1", 1) == 0)
            displayIndex = 1;
        else if (strncmp(argv[1], "2", 1) == 0)
            displayIndex = 2;
        else
        {
            fprintf(stderr, "Unexpected CLI argument, only '1', '2' is supported for selecting second or third connected display \n");
            exit(EXIT_FAILURE);
        }
    }
    Window window;
    if (!window.init(XRES, YRES, "skunkwork", displayIndex))
        return -1;

#ifdef DEMO_MODE
    SDL_SetWindowFullscreen(window.ptr(), SDL_WINDOW_FULLSCREEN);
    SDL_ShowCursor(false);
#endif // DEMO_MODE

    // Setup imgui
    GUI gui;
    gui.init(window.ptr(), window.ctx());

    Quad q;

    // Set up audio
    std::string musicPath(RES_DIRECTORY);
    musicPath += "gthon_aineet.wav";
    if (!AudioStream::getInstance().init(musicPath, 145.0, 8))
    {
        gui.destroy();
        window.destroy();
        exit(EXIT_FAILURE);
    }

    // Set up rocket
    sync_device *rocket = sync_create_device(
        std::filesystem::relative(
            std::filesystem::path{RES_DIRECTORY "rocket/sync"},
            std::filesystem::current_path()).lexically_normal().generic_string().c_str());
    if (!rocket) {
        printf("[rocket] Failed to create device\n");
        exit(EXIT_FAILURE);
    }

    // Set up scene
    std::string vertPath{RES_DIRECTORY "shader/basic_vert.glsl"};
    std::vector<Shader> sceneShaders;
    sceneShaders.emplace_back("Basic", rocket, vertPath, RES_DIRECTORY "shader/basic_frag.glsl");
    sceneShaders.emplace_back("RayMarch", rocket, vertPath, RES_DIRECTORY "shader/ray_marching_frag.glsl");
    sceneShaders.emplace_back("Pedestal", rocket, vertPath, RES_DIRECTORY "shader/pedestal.glsl");
    sceneShaders.emplace_back("FractalTemple", rocket, vertPath, RES_DIRECTORY "shader/fractal_temple.glsl");
    sceneShaders.emplace_back("Ayy", rocket, vertPath, RES_DIRECTORY "shader/ayy_lmao_marching.glsl");
    sceneShaders.emplace_back("Ayy2", rocket, vertPath, RES_DIRECTORY "shader/ayy_lmao_marching2.glsl");
    sceneShaders.emplace_back("Ayy3", rocket, vertPath, RES_DIRECTORY "shader/ayy_lmao_marching3.glsl");
    sceneShaders.emplace_back("Ayy4", rocket, vertPath, RES_DIRECTORY "shader/ayy_lmao_marching4.glsl");
    sceneShaders.emplace_back("Ayy5", rocket, vertPath, RES_DIRECTORY "shader/ayy_lmao_marching5.glsl");
    sceneShaders.emplace_back("Ayy6", rocket, vertPath, RES_DIRECTORY "shader/ayy_lmao_marching6.glsl");
    sceneShaders.emplace_back("Ayy6", rocket, vertPath, RES_DIRECTORY "shader/ayy_lmao_marching6a.glsl");
    sceneShaders.emplace_back("Ayy7", rocket, vertPath, RES_DIRECTORY "shader/ayy_lmao_marching7.glsl");
    sceneShaders.emplace_back("Ayy8", rocket, vertPath, RES_DIRECTORY "shader/ayy_lmao_marching8.glsl");
    sceneShaders.emplace_back("Ayy9", rocket, vertPath, RES_DIRECTORY "shader/ayy_lmao_marching9.glsl");
    sceneShaders.emplace_back("Ayy10", rocket, vertPath, RES_DIRECTORY "shader/ayy_lmao_marching10.glsl");
    sceneShaders.emplace_back("Ayy11", rocket, vertPath, RES_DIRECTORY "shader/ayy_lmao_marching11.glsl");
    sceneShaders.emplace_back("Ayy12", rocket, vertPath, RES_DIRECTORY "shader/ayy_lmao_marching12.glsl");
    sceneShaders.emplace_back("Ayy13", rocket, vertPath, RES_DIRECTORY "shader/ayy_lmao_marching13.glsl");
    sceneShaders.emplace_back("Ayy14", rocket, vertPath, RES_DIRECTORY "shader/ayy_lmao_marching14.glsl");
    sceneShaders.emplace_back("Ayy15", rocket, vertPath, RES_DIRECTORY "shader/ayy_lmao_marching15.glsl");
    sceneShaders.emplace_back("Ayy16", rocket, vertPath, RES_DIRECTORY "shader/ayy_lmao_marching16.glsl");
    sceneShaders.emplace_back("Ayy17", rocket, vertPath, RES_DIRECTORY "shader/ayy_lmao_marching17.glsl");
    sceneShaders.emplace_back("Ayy18", rocket, vertPath, RES_DIRECTORY "shader/ayy_lmao_marching18.glsl");
    sceneShaders.emplace_back("Ayy19", rocket, vertPath, RES_DIRECTORY "shader/ayy_lmao_marching19.glsl");
    sceneShaders.emplace_back("Ayy", rocket, vertPath, RES_DIRECTORY "shader/ayy_lmao_marching.glsl");


    sceneShaders.emplace_back("Text", rocket, vertPath, RES_DIRECTORY "shader/text_frag.glsl");
    sceneShaders.emplace_back("2DishSpaceTwister", rocket, vertPath, RES_DIRECTORY "shader/2dish_space_twister_frag.glsl");
    sceneShaders.emplace_back("IcoDodecaSpikeBlend", rocket, vertPath, RES_DIRECTORY "shader/ico_dodeca_spike_blend_frag.glsl");
    sceneShaders.emplace_back("IcoDodecaSpikeBlend2", rocket, vertPath, RES_DIRECTORY "shader/ico_dodeca_spike_blend2_frag.glsl");
    sceneShaders.emplace_back("LooneyTunnelTwoDee", rocket, vertPath, RES_DIRECTORY "shader/kukkatunneli.glsl");
    Shader compositeShader("Composite", rocket, vertPath, RES_DIRECTORY "shader/composite_frag.glsl");
    Shader quadShader("Quad", rocket, vertPath, RES_DIRECTORY "shader/render_quad_frag.glsl");

#ifdef TCPROCKET
    // Try connecting to rocket-server
    int rocketConnected = sync_connect(rocket, "localhost", SYNC_DEFAULT_PORT) == 0;
    if (!rocketConnected) {
        printf("[rocket] Failed to connect to server\n");
        exit(EXIT_FAILURE);
    }
#endif // TCPROCKET

    // Init rocket tracks here
    const sync_track* pingScene = sync_get_track(rocket, "pingScene");
    const sync_track* pongScene = sync_get_track(rocket, "pongScene");

    Timer reloadTime;
    Timer globalTime;
    GpuProfiler scenePingProf(5);
    GpuProfiler scenePongProf(5);
    GpuProfiler compositeProf(5);
    GpuProfiler quadProf(5);
    std::vector<std::pair<std::string, const GpuProfiler*>> profilers = {
            {"ScenePing", &scenePingProf},
            {"ScenePong", &scenePongProf},
            {"Composite", &compositeProf},
            {"Quad", &quadProf}
    };

    TextureParams rgba16fParams = {GL_RGBA16F, GL_RGBA, GL_FLOAT,
                                   GL_LINEAR, GL_LINEAR,
                                   GL_CLAMP_TO_BORDER, GL_CLAMP_TO_BORDER};
    TextureParams rgba32fParams = {GL_RGBA32F, GL_RGBA, GL_FLOAT,
                                   GL_LINEAR, GL_LINEAR,
                                   GL_CLAMP_TO_EDGE, GL_CLAMP_TO_EDGE};


    // Generate framebuffer for main rendering
    std::vector<TextureParams> sceneTexParams({rgba16fParams});

    FrameBuffer scenePingFbo(XRES, YRES, sceneTexParams);
    FrameBuffer scenePongFbo(XRES, YRES, sceneTexParams);
    FrameBuffer compositePingFbo(XRES, YRES, {rgba16fParams, rgba32fParams, rgba32fParams, rgba32fParams, rgba32fParams});
    FrameBuffer compositePongFbo(XRES, YRES, {rgba16fParams, rgba32fParams, rgba32fParams, rgba32fParams, rgba32fParams});

    AudioStream::getInstance().play();

    int32_t overrideIndex = -1;

    bool compositePong = false;
    // Run the main loop
    while (window.open()) {
        bool const resized = window.startFrame();

#ifndef DEMO_MODE
        if (window.playPausePressed())
        {
            if (AudioStream::getInstance().isPlaying())
                AudioStream::getInstance().pause();
            else
                AudioStream::getInstance().play();
        }
#endif // !DEMO_MODE

        if (resized) {
            scenePingFbo.resize(window.width(), window.height());
            scenePongFbo.resize(window.width(), window.height());
            compositePingFbo.resize(window.width(), window.height());
            compositePongFbo.resize(window.width(), window.height());
        }

        // Sync
        double syncRow = AudioStream::getInstance().getRow();

#ifdef TCPROCKET
        // Try re-connecting to rocket-server if update fails
        // Drops all the frames, if trying to connect on windows
        if (sync_update(rocket, (int)floor(syncRow), &audioSync, AudioStream::getInstance().getMusic()))
            sync_connect(rocket, "localhost", SYNC_DEFAULT_PORT);
#endif // TCPROCKET

        int32_t pingIndex = std::clamp(
            (int32_t)(float)sync_get_val(pingScene, syncRow), 0, (int32_t)sceneShaders.size() - 1);
        int32_t pongIndex = std::clamp(
            (int32_t)(float)sync_get_val(pongScene, syncRow), 0, (int32_t)sceneShaders.size() - 1);

        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        float const currentTimeS = AudioStream::getInstance().getTimeS();
#ifndef DEMO_MODE
        if (window.drawGUI())
        {
            float uiTimeS = currentTimeS;

            std::vector<Shader*> shaders{&compositeShader};
            for (Shader& s : sceneShaders)
                shaders.push_back(&s);

            gui.startFrame(window.height(), overrideIndex, uiTimeS, shaders, profilers);
            overrideIndex = std::clamp(
                overrideIndex, -1, (int32_t)sceneShaders.size() - 1);

            if (uiTimeS != currentTimeS)
                AudioStream::getInstance().setTimeS(uiTimeS);
        }

        // Try reloading the shader every 0.5s
        if (reloadTime.getSeconds() > 0.5f) {
            compositeShader.reload();
            for (Shader& s : sceneShaders)
                s.reload();
            reloadTime.reset();
        }

        //TODO: No need to reset before switch back
        if (gui.useSliderTime())
            globalTime.reset();

        if (overrideIndex >= 0)
        {
            scenePingProf.startSample();
            sceneShaders[overrideIndex].bind(syncRow);
            sceneShaders[overrideIndex].setFloat(
                "uTime",
#ifdef DEMO_MODE
                currentTimeS
#else // DEMO_NODE
                gui.useSliderTime() ? gui.sliderTime() : globalTime.getSeconds()
#endif // DEMO_MODE
            );
            sceneShaders[overrideIndex].setVec2(
                "uRes", (GLfloat)window.width(), (GLfloat)window.height());
            q.render();
            scenePingProf.endSample();
        }
        else
#endif //! DEMO_MODE
        {
            scenePingProf.startSample();
            sceneShaders[pingIndex].bind(syncRow);
            scenePingFbo.bindWrite();
            sceneShaders[pingIndex].setFloat(
                "uTime",
#ifdef DEMO_MODE
                currentTimeS
#else // DEMO_NODE
                gui.useSliderTime() ? gui.sliderTime() : globalTime.getSeconds()
#endif // DEMO_MODE
            );
            sceneShaders[pingIndex].setVec2("uRes", (GLfloat)window.width(), (GLfloat)window.height());
            q.render();
            glBindFramebuffer(GL_DRAW_FRAMEBUFFER, 0);
            scenePingProf.endSample();

            scenePongProf.startSample();
            sceneShaders[pongIndex].bind(syncRow);
            scenePongFbo.bindWrite();
            sceneShaders[pongIndex].setFloat(
                "uTime",
#ifdef DEMO_MODE
                currentTimeS
#else // DEMO_NODE
                gui.useSliderTime() ? gui.sliderTime() : globalTime.getSeconds()
#endif // DEMO_MODE
            );
            sceneShaders[pongIndex].setVec2("uRes", (GLfloat)window.width(), (GLfloat)window.height());
            q.render();
            glBindFramebuffer(GL_DRAW_FRAMEBUFFER, 0);
            scenePongProf.endSample();

            compositeProf.startSample();
            compositeShader.bind(syncRow);
            if (!compositePong) {
                compositePongFbo.bindWrite();
            }
            else {
                compositePingFbo.bindWrite();
            }
            compositeShader.setFloat(
                "uTime",
#ifdef DEMO_MODE
                currentTimeS
#else // DEMO_NODE
                gui.useSliderTime() ? gui.sliderTime() : globalTime.getSeconds()
#endif // DEMO_MODE
            );
            compositeShader.setVec2("uRes", (GLfloat)window.width(), (GLfloat)window.height());
            scenePingFbo.bindRead(0, GL_TEXTURE0, compositeShader.getUniformLocation("uScenePingColorDepth"));
            scenePongFbo.bindRead(0, GL_TEXTURE1, compositeShader.getUniformLocation("uScenePongColorDepth"));

            if (compositePong) {
                compositePongFbo.bindRead(1, GL_TEXTURE2, compositeShader.getUniformLocation("uPrevPing"));
                compositePongFbo.bindRead(2, GL_TEXTURE3, compositeShader.getUniformLocation("uPrevPong"));
                compositePongFbo.bindRead(3, GL_TEXTURE4, compositeShader.getUniformLocation("uFlow"));
                compositePongFbo.bindRead(4, GL_TEXTURE5, compositeShader.getUniformLocation("uColorFeedback"));
            }
            else {
                compositePingFbo.bindRead(1, GL_TEXTURE2, compositeShader.getUniformLocation("uPrevPing"));
                compositePingFbo.bindRead(2, GL_TEXTURE3, compositeShader.getUniformLocation("uPrevPong"));
                compositePingFbo.bindRead(3, GL_TEXTURE4, compositeShader.getUniformLocation("uFlow"));
                compositePingFbo.bindRead(4, GL_TEXTURE5, compositeShader.getUniformLocation("uColorFeedback"));
            }
            q.render();
            glBindFramebuffer(GL_DRAW_FRAMEBUFFER, 0);
            compositeProf.endSample();

            quadProf.startSample();
            quadShader.bind(syncRow);
            quadShader.setFloat(
                "uTime",
#ifdef DEMO_MODE
                currentTimeS
#else // DEMO_NODE
                gui.useSliderTime() ? gui.sliderTime() : globalTime.getSeconds()
#endif // DEMO_MODE
            );
            quadShader.setVec2("uRes", (GLfloat)window.width(), (GLfloat)window.height());

            if (compositePong) {
                compositePongFbo.bindRead(0, GL_TEXTURE6, quadShader.getUniformLocation("uQuad"));
            }
            else {
                compositePingFbo.bindRead(0, GL_TEXTURE6, quadShader.getUniformLocation("uQuad"));
            }
            q.render();
            quadProf.endSample();

            compositePong = !compositePong;
        }

#ifndef DEMO_MODE
        if (window.drawGUI())
            gui.endFrame();
#endif // DEMO_MODE

        window.endFrame();

#ifdef DEMO_MODE
        if (!AudioStream::getInstance().isPlaying())
            window.setClose();
#endif // DEMO_MODE
    }

#ifdef TCPROCKET
    // Save rocket tracks
    sync_save_tracks(rocket);
#endif // TCPROCKET

    // Release resources
    sync_destroy_device(rocket);

    AudioStream::getInstance().destroy();
    gui.destroy();
    window.destroy();
    exit(EXIT_SUCCESS);
}
