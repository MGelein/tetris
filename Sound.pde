/**
The sound manager loads and plays any sounds
that are required.
**/
class SoundManager implements IUpdate{
  //The background music
  SoundFile bgMusic;
  //The music in the menu
  SoundFile menuMusic;
  //A 'confirm' or 'interaction' blip
  SoundFile blip;
  //The file that is played whenever some TShape is dropped;
  SoundFile down;
  //An explosion, might be useful?
  SoundFile explosion1;
  //The second impact sound effect
  SoundFile impact2;
  //The first impact sound effet
  SoundFile impact1;
  //Another explosion, more explosion more better?
  SoundFile explosion2;
  //The volume of the background music
  float bgVol = 0;
  float bgTargetVol = 0;
  float menuVol = 0;
  float menuTargetVol = 1;
  boolean bgPlaying = false;
  boolean menuPlaying = true;
  
  //Instantiating this class starts to load the sounds
  SoundManager(PApplet parent){
    bgMusic = new SoundFile(parent, "bg.wav");
    blip = new SoundFile(parent, "blip.wav");
    explosion1 = new SoundFile(parent, "explosion1.wav");
    explosion2 = new SoundFile(parent, "explosion2.wav");
    impact1 = new SoundFile(parent, "impact1.wav");
    impact2 = new SoundFile(parent, "impact2.wav");
    down = new SoundFile(parent, "drop.wav");
    menuMusic = new SoundFile(parent, "menu.wav");
    //Subscribe myself to update notifications
    updateManager.add(this);
  }
  
  /**
  The soundmanager can be updated to keep track of volume easing
  **/
  void update(){
    //Slowly ease towards the right volume
    float diff = bgTargetVol - bgVol;
    bgVol += diff * 0.01;
    if(bgPlaying) bgMusic.amp(bgVol);
    //Now ease the menu music too
    diff = menuTargetVol - menuVol;
    menuVol += diff * 0.01;
    if(menuPlaying) menuMusic.amp(menuVol);
    
    //If no real volume is left, stop the background music
    if(bgVol < 0.01) {
      bgMusic.stop();
      bgPlaying = false;
    }
    
    if(menuVol < 0.01){
      menuMusic.stop();
      menuPlaying = false;
    }
  }
  
  /**
  Play the sound that indicates that a piece is dropped
  **/
  void playDown(){
    if(!JUICY) return;
    //Play the drop sound
    down.play();
    //And lower the bg volume a little bit
    bgVol = 0.7;
  }
  
  /**
  Play a single explosion sound
  **/
  void playExplosion(){
    if(!JUICY) return;
    //Pick an explosion sound to play
    if(random(1) < 0.5) explosion1.play();
    else explosion2.play();
    //And then duck the volume for a bit
    bgVol = 0.3;
  }
  
  /**
  Plays the blip
  **/
  void playBlip(){
    if(!JUICY) return;
    //Play the blip
    blip.play();
    //Duck the volume a little
    bgVol = 0.7;
  }
  
  /**
  Starts playing the bg music
  **/
  void startBGMusic(){
    bgMusic.loop();
    bgPlaying = true;
    bgTargetVol = 1;
    menuTargetVol = 0;
  }
  
  /**
  Starts the menu music
  **/
  void startMenuMusic(){
    menuMusic.loop();
    menuTargetVol = 1;
    menuPlaying = true;
    bgTargetVol = 0;
  }
}
