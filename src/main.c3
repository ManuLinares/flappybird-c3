module flappybird;
import std::io;
import std::math;
import std::math::random;
import raylib5::rl;

alias Vec2 = float[<2>];

const int WINDOW_WIDTH = 800;
const int WINDOW_HEIGHT = 600;
float birdRadius = 20f;

fn void drawBird(Vec2 pos, bool wingUp) {
    // Body
    rl::drawCircleV({pos.x, pos.y}, (float)birdRadius, rl::YELLOW);

    // Beak
    rl::drawTriangle(
        {pos.x + (float)birdRadius, pos.y},
        {pos.x + (float)birdRadius + 10.0f, pos.y - 5.0f},
        {pos.x + (float)birdRadius + 10.0f, pos.y + 5.0f},
        rl::ORANGE
    );

    // Eye
    rl::drawCircleV({pos.x + (float)birdRadius / 3.0f, pos.y - (float)birdRadius / 3.0f}, 5.0f, rl::WHITE);
    rl::drawCircleV({pos.x + (float)birdRadius / 3.0f, pos.y - (float)birdRadius / 3.0f}, 2.0f, rl::BLACK);

    // Wing
    float wingAngle = wingUp ? -15.0f : 15.0f;
    rl::drawTriangle(
        {pos.x - 5.0f, pos.y},
        {pos.x - 25.0f, pos.y + wingAngle},
        {pos.x - 5.0f, pos.y + 10.0f},
        rl::BROWN
    );
}

fn void drawPipe(float x, float gapY, int gapHalf) {
    // Pipe
    rl::drawRectangle((int)x, 0, 60, (int)(gapY - (float)gapHalf), rl::GREEN);
    rl::drawRectangle((int)x, (int)(gapY + (float)gapHalf), 60, WINDOW_HEIGHT - (int)(gapY + (float)gapHalf) - 40, rl::GREEN);

    // Pipe Cap
    rl::drawRectangle((int)x - 5, (int)(gapY - (float)gapHalf) - 20, 70, 20, rl::DARKGREEN);
    rl::drawRectangle((int)x - 5, (int)(gapY + (float)gapHalf), 70, 20, rl::DARKGREEN);
}

fn void drawGroundTrees(float[] treeX) {
    for (int i = 0; i < treeX.len; i++) {
        float baseY = (float)WINDOW_HEIGHT - 40.0f;
        rl::drawRectangle((int)treeX[i] - 5, (int)baseY - 30, 10, 30, rl::BROWN);
        rl::drawCircle((int)treeX[i], (int)baseY - 40, 15.0f, rl::DARKGREEN);
    }
}

fn void drawClouds(Vec2[] clouds) {
    for (int i = 0; i < clouds.len; i++) {
        rl::drawCircleV({clouds[i].x, clouds[i].y}, 20.0f, rl::LIGHTGRAY);
        rl::drawCircleV({clouds[i].x + 20.0f, clouds[i].y + 5.0f}, 18.0f, rl::LIGHTGRAY);
        rl::drawCircleV({clouds[i].x - 20.0f, clouds[i].y + 5.0f}, 18.0f, rl::LIGHTGRAY);
    }
}

fn void main(String[] args) {
    
    Vec2 gravity = {0, 2000};
    Vec2 flapImpulse = {0, -1000};

    rl::setConfigFlags(
        rl::FLAG_VSYNC_HINT |
        rl::FLAG_MSAA_4X_HINT);

    rl::initWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Flappy Bird in C3 - Enhanced");
    rl::setTargetFPS(60);

    Vec2 birdPos = {(float)WINDOW_WIDTH / 4.0f, (float)WINDOW_HEIGHT / 2.0f};
    Vec2 birdVel = {0.0f, 0.0f};
    bool wingUp = true;
    float wingTimer = 0.0f;

    float pipeX = (float)WINDOW_WIDTH;
    float pipeGapY = (float)WINDOW_HEIGHT / 2.0f;
    int gapHalf = 100;

    int score = 0;
    bool passedPipe = false;

    float[] treeX = {150.0f, 350.0f, 550.0f, 750.0f};
    Vec2[] clouds = {
        {100.0f, 100.0f},
        {400.0f, 80.0f},
        {700.0f, 120.0f}
    };

    float startTime;
    float gameTime;
    ZString score_text;

    while (!rl::windowShouldClose()) @stack_mem(64; smem)  {
        float dt = rl::getFrameTime();
        gameTime += dt;

        // Input
        switch {
            case (rl::isKeyPressed(rl::KEY_SPACE) || rl::isKeyPressed(rl::KEY_UP)):
                birdVel += flapImpulse;
                birdVel = math::clamp(birdVel, (Vec2){0, -650}, (Vec2){0,0});
            case (rl::isMouseButtonDown(rl::MouseButton.LEFT)):
                birdVel += flapImpulse / 14;
                birdVel = math::clamp(birdVel, (Vec2){0, -650}, (Vec2){0,0});
            case (rl::isMouseButtonDown(rl::MouseButton.RIGHT) || rl::isKeyPressed(rl::KEY_DOWN)):
                birdVel -= flapImpulse / 14;
                birdVel = math::clamp(birdVel, (Vec2){0, +350}, (Vec2){0,0});
        }

        // Ultra Physics phxv2, so complicated 
        birdVel += gravity * dt;
        birdPos += birdVel * dt;

        // Wing animation toggle
        wingTimer += dt;
        if (wingTimer > 0.15f) {
            wingUp = !wingUp;
            wingTimer = 0.0f;
        }

        // Move Pipe
        pipeX -= 300.0f * dt + (float)(gameTime * 0.3);
        if (pipeX < -60.0f) {
            pipeX = (float)WINDOW_WIDTH;
            pipeGapY = (float)math::random::rand(WINDOW_HEIGHT - 200) + 100.0f;
            passedPipe = false;
        }

        // Calculate Score
        if (!passedPipe && birdPos.x > pipeX + 60.0f) {
            score++;
            passedPipe = true;
        }

        // Cloud movement
        for (int i = 0; i < clouds.len; i++) {
            clouds[i].x -= 100.0f * dt; // slow drift
            if (clouds[i].x < -50.0f) {
                clouds[i].x = (float)WINDOW_WIDTH + 50.0f;
            }
        }

        // Tree movement
        foreach (&tree : treeX) {
            *tree -= 300.0f * dt;
            if (*tree < -10.0f) {
                *tree = (float)WINDOW_WIDTH + 10.0f;
            }
        }

        rl::@drawing()
        {
            rl::clearBackground(rl::SKYBLUE);

            drawClouds(clouds);
            drawGroundTrees(treeX);

            // Ground? sure
            rl::drawRectangle(0, WINDOW_HEIGHT - 40, WINDOW_WIDTH, 40, rl::BROWN);

            drawPipe(pipeX, pipeGapY, gapHalf);
            drawBird(birdPos, wingUp);

            // Score
            score_text = (ZString)string::format(smem, "Score: %d", score);
            rl::drawText(score_text, 10, 10, 30, rl::BLACK);
        };

        // Collision
        // Floor collision (bounce)
        if (birdPos.y + (float)birdRadius > (float)(WINDOW_HEIGHT - 40)) {
            birdPos.y = (float)(WINDOW_HEIGHT - 40) - (float)birdRadius;
            birdVel.y *= -0.6f; // Bounce with some energy loss
        }
        // Pipe collision (game over? resatart)
        if (birdPos.x + (float)birdRadius > pipeX && birdPos.x - (float)birdRadius < pipeX + 60.0f
            && (birdPos.y - (float)birdRadius < pipeGapY - (float)gapHalf
                || birdPos.y + (float)birdRadius > pipeGapY + (float)gapHalf)) {
            // Reset
            birdPos = {(float)WINDOW_WIDTH / 4.0f, (float)WINDOW_HEIGHT / 2.0f};
            birdVel = {0.0f, 0.0f};
            pipeX = (float)WINDOW_WIDTH;
            score = 0;
            passedPipe = false;
            gameTime = 0;
            rl::@drawing()
            {
                rl::clearBackground(rl::RED);
            };
        }
    };

    rl::closeWindow();
}