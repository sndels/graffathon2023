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
// #define TCPROCKET
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
    musicPath += "illegal_af.wav";
    if (!AudioStream::getInstance().init(musicPath, 175.0, 8))
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
    sceneShaders.emplace_back("Text", rocket, vertPath, RES_DIRECTORY "shader/text_frag.glsl");
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
                                   GL_CLAMP_TO_BORDER, GL_CLAMP_TO_BORDER};


    // Generate framebuffer for main rendering
    std::vector<TextureParams> sceneTexParams({rgba16fParams});

    FrameBuffer scenePingFbo(XRES, YRES, sceneTexParams);
    FrameBuffer scenePongFbo(XRES, YRES, sceneTexParams);
    FrameBuffer compositeFbo(XRES, YRES, {rgba16fParams, rgba32fParams});

    AudioStream::getInstance().play();

    int32_t overrideIndex = -1;

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
            compositeFbo.resize(window.width(), window.height());
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

#ifndef DEMO_MODE
        if (window.drawGUI())
        {
            float const currentTimeS = AudioStream::getInstance().getTimeS();
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
                gui.useSliderTime() ? gui.sliderTime() : globalTime.getSeconds()
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
                gui.useSliderTime() ? gui.sliderTime() : globalTime.getSeconds()
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
                gui.useSliderTime() ? gui.sliderTime() : globalTime.getSeconds()
            );
            sceneShaders[pongIndex].setVec2("uRes", (GLfloat)window.width(), (GLfloat)window.height());
            q.render();
            glBindFramebuffer(GL_DRAW_FRAMEBUFFER, 0);
            scenePongProf.endSample();

            compositeProf.startSample();
            compositeShader.bind(syncRow);
            compositeFbo.bindWrite();
            compositeShader.setFloat(
                "uTime",
                gui.useSliderTime() ? gui.sliderTime() : globalTime.getSeconds()
            );
            compositeShader.setVec2("uRes", (GLfloat)window.width(), (GLfloat)window.height());
            scenePingFbo.bindRead(0, GL_TEXTURE0, compositeShader.getUniformLocation("uScenePingColorDepth"));
            scenePongFbo.bindRead(0, GL_TEXTURE1, compositeShader.getUniformLocation("uScenePongColorDepth"));
            compositeFbo.bindRead(1, GL_TEXTURE2, compositeShader.getUniformLocation("uPrevAux"));
            q.render();
            glBindFramebuffer(GL_DRAW_FRAMEBUFFER, 0);
            compositeProf.endSample();

            quadProf.startSample();
            quadShader.bind(syncRow);
            quadShader.setFloat(
                "uTime",
                gui.useSliderTime() ? gui.sliderTime() : globalTime.getSeconds()
            );
            quadShader.setVec2("uRes", (GLfloat)window.width(), (GLfloat)window.height());
            compositeFbo.bindRead(0, GL_TEXTURE2, quadShader.getUniformLocation("uQuad"));
            q.render();
            quadProf.endSample();
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

    // Save rocket tracks
    sync_save_tracks(rocket);

    // Release resources
    sync_destroy_device(rocket);

    AudioStream::getInstance().destroy();
    gui.destroy();
    window.destroy();
    exit(EXIT_SUCCESS);
}
