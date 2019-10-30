/**
This is the UI overlay, shows hints, scores, points etc.
**/
class UI{
  
  //The score of the player so far
  int score = 0;
  //The targetscore, so you can make it animate
  int targetScore = 0;
  //The right side of the tetris part is the left side of the ui
  float left = 0;
  //The width of the ui
  float w = 0;
  //Set the title offset
  float titleoffset = -1;
  //The size of the title font
  int titleSize = 48;
  //The buffer on the left side;
  float leftBuffer = 20;
  
  /**
  Set the left side of the ui point from the right side of the grid
  **/
  void setBounds(float l){
    left = l;
    w = width - left;
    
  }
  
  /**
  Adds the provided score to the mainscore
  **/
  void addScore(int dScore){
    targetScore += dScore;
  }
  
  /**
  Calculate the amount of offset for the title 
  **/
  void calcTitleOffset(){
    //Calc title offset
    textSize(titleSize);
    titleoffset = (w - textWidth("Tetris")) / 2;
  }
  
  /**
  Renders the UI overlay
  **/
  void render(){
    //See if we need to calc the title offset
    if(titleoffset == -1) calcTitleOffset();
    //Render the header
    textSize(titleSize);
    text("Tetris", left + titleoffset, titleSize + 10);
    textSize(24);
    text("Instructions:", left + leftBuffer, 250);
    //Set the fill to white
    fill(255);
    //Render the score
    textSize(20);
    //Calculate the difference between target and score
    float delta = (targetScore - score);
    //Only multiply if we're not done with the last bit of adding the targetScore
    if(delta > 10 && JUICY) delta *= 0.1;
    score += delta;
    text("Score: " + score + " pts", left + leftBuffer, 120);
    //Show the instructions how to play
    showInstructions();
    
    //Make a tiny note of the programmer
    textSize(12);
    fill(125); 
    text("Made by Mees Gelein", left + leftBuffer + 50, height - 20);
  }
  
  /**
  Renders the instuctions of the keys
  **/
  void showInstructions(){
    fill(255);
    textSize(20);
    text("Up : Rotate", left + leftBuffer, 290);
    text("Down : Speed", left + leftBuffer, 320);
    text("Left : Move L", left + leftBuffer, 350);
    text("Right : Move R", left + leftBuffer, 380);
  }
}  
