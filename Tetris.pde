//Import the java collections package, to make sorting possible
import java.util.*;
//Import processing sound, since we will need it
import processing.sound.*;

//The size of a tetris block
final static int BLOCK_SIZE = 32;

//The render manager manages what gets rendered
RenderManager renderManager = new RenderManager();
//The update manager manages what gets updated
UpdateManager updateManager = new UpdateManager();
//The manager for all sounds in our game
SoundManager soundManager;
//The ui overlay
UI ui = new UI();
//The grid we're playing on
Grid grid;
//The shape we're currently controlling
TShape activeShape;

//Amount of score to add
final int TETRIS_SCORE = 1000;
//Reward for placing a single brick
final int BLOCK_SCORE = 100;
//The current amount of score, after multiplier
int tetrisScore = TETRIS_SCORE;

//If the left input is down
boolean leftPressed = false;
//If the right input is down
boolean rightPressed = false;
//If the down arrow is down
boolean speedPressed = false;
//If the up arrow pressed
boolean rotatePressed = false;
//If we have just ended the game
boolean gameOver = true;
//If we have just gameovered, this prevents immediate restarts
boolean justGameOvered = false;
//If we have just started the game
boolean firstPlay = true;
//Checks if we just got a tetris, if it is lower than 0, no
int gotTetris = -1;
//The shaker coordinates
PVector shake = new PVector();
//The shakeForce
PVector shakeF = new PVector();
/**This color is flashed if the screen is shaking*/
color flashColor;
//The opactiy of the overlay (black)
float overlayOpacity = 1;
//The amount of opacity of the overlay
float targetOverlayOpacity = 1;

/**
 Make sure the screen size is multiples of the block size
 **/
void settings() {
  //The target screen size, can be made smaller to fit block size
  XY2D target = new XY2D(720, 720);
  target.x -= target.x % BLOCK_SIZE;
  target.y -= target.y % BLOCK_SIZE;  
  //Set the screen size to the corrected size
  size(target.x, target.y); 
  //Start loading the sounds
  soundManager = new SoundManager(this);
}

/**
 Called once during initialization, use this to load assets
 and prepare and initialize classes and methods
 **/
void setup() {
  //Set color mode to HSB for easier rainbows
  colorMode(HSB);
  //Set the first random flash color
  flashColor = color(random(255), 100, 255);
  //Instantiate the grid
  grid = new Grid();
  //If we're not yet playin the bg music, start it now
  if (!soundManager.bgPlaying) soundManager.startMenuMusic();
  //Load the font 
  textFont(createFont("2025.ttf", 32));
}

/**
 Draws to the screen at the target FPS
 **/
void draw() {
  //Draw the black background
  background(0);
  //Update the update manager
  updateManager.update();
  //If there was an actual tetris, shake the screen
  if (gotTetris > 5) {
    //Set the shaking force
    shakeF.x = random(-10, 10);
    shake.add(shakeF);
  }
  //Multiply the shake force, to make it go towards 0 again asap
  shake.mult(0.6);
  translate(shake.x, shake.y);
  //Nullify force if it is very small
  if (abs(shake.x) < 0.01) shake.x = shake.y = 0;

  //Render the render manager
  renderManager.render();
  //If no shape is active, make a new one (if we're not gameOver yet)
  if (activeShape == null && gotTetris < 0 && !gameOver) activeShape = new TShape(grid);
  else gotTetris --;

  //Render white overlay if we are shaking
  if (gotTetris > 5) {
    //10% chance to reset flashColor, makes sure that colors are likely to stay for a bit
    if (random(1) < 0.1) flashColor = color(random(255), 150, 255);
    //And also make a white overlay
    fill(flashColor, ((gotTetris - 5) / 25f) * 80);
    //Draw the rectangle that is the color overlay
    rect(-100, -100, width + 200, height + 200);
  }

  //Reset score if we haven't had a tetris multiplier
  if (gotTetris < 1) {
    tetrisScore = TETRIS_SCORE;
  }

  //Render the UI Overlay
  ui.render();
  
  //If we're gameOver, render dark overlay for now
  if(gameOver){
    fill(0, 180 * overlayOpacity + (firstPlay ? 70 : 0));
    rect(-100, -100, width + 200, height + 200);
    
    //Draw white game over text center screen
    fill(255, 255 * overlayOpacity);
    textSize(64);
    String go = firstPlay ? "Welcome!" : "Game Over!";
    float tw2 = textWidth(go) / 2;
    text(go, (width / 2 - tw2) * (overlayOpacity * 2 - 1), height / 2 - 64);
    textSize(32);
    fill(255, 125, 125, 255 * overlayOpacity);
    String sc = "Score: " + ui.score;
    tw2 = textWidth(sc) / 2;
    text(sc, (width / 2 - tw2) * (overlayOpacity * 2 - 1), height / 2);
    textSize(24);
    fill(125, 125, 255, 255 * overlayOpacity);
    String ak = "Press any key to restart";
    tw2 = textWidth(ak) / 2;
    text(ak, (width / 2 - tw2) * (overlayOpacity * 2 - 1), height / 2 + 48);
    
    //Regulate the fading
    float deltaOpacity = (overlayOpacity - targetOverlayOpacity) * 0.03;
    overlayOpacity -= deltaOpacity;
    //If we're in the last bit of fading, set the thingy
    if(deltaOpacity < 0.01 && deltaOpacity > 0) {
      //Toggle gameoVer state
      gameOver = !gameOver;
      //After first gameOver, always set firstplay to false
      if(!gameOver) firstPlay = false;
      overlayOpacity = targetOverlayOpacity;
      
      //If we are now gameOver, start menu
      if(gameOver){
        soundManager.startMenuMusic();
      }else{
        soundManager.startBGMusic();
      }
    }
  }
}

/**
 This starts the gameover condition
 **/
void doGameOver() {
  //This starts the gameOver condition
  gameOver = true;
  //Reset the grid (pops all populated cells)
  grid.reset();
  //The overlay opacity
  targetOverlayOpacity = 1;
  
  //De-register all keys
  leftPressed = rightPressed = speedPressed = rotatePressed = false;
  
  //And set a flag to ignore keyRepeats untill a release
  justGameOvered = true;
}

/**
 Record key presses
 **/
void keyPressed() {
  //Accept any keyPress during gameOver to restart, only when we have finished fading
  if (gameOver && overlayOpacity == 1) {
    //Set everything ready to play
    targetOverlayOpacity = 0;
    //Remove all score
    ui.addScore(-ui.score);
  } else {
    if (keyCode == 37) leftPressed = true;//left arrow key
    else if (keyCode == 39) rightPressed = true;//right arrow key
    else if (keyCode == 40) speedPressed = true;//space by default
    else if (keyCode == 38) rotatePressed = true;//up arrow key by default
  }
}

/**
 Release all keys
 **/
void keyReleased() {
  //Set all to false
  leftPressed = rightPressed = speedPressed = rotatePressed = false;
  //Also allow restarting now again
  justGameOvered = false;
}

/**
 Tells us that this object can be updated
 **/
interface IUpdate {
  void update();
}
/**
 Tells us that this object can be rendered
 **/
interface IRender {
  //This renders this object
  abstract void render();
}
