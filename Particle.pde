//Size of a single particle
final int PARTICLE_SIZE = 4;

class Particle implements IUpdate, IRender {
  //The position of this particle
  PVector pos;
  //The velocity of this particle
  PVector vel;
  //The color of this particle
  color c;
  //The size of the rect
  float size = PARTICLE_SIZE;
  //The half size of the rect
  float hs = size / 2;
  //The amount of frames to delay updating and rendering
  int delay = 0;

  /**
   Creates a new Particle from the provided data
   **/
  Particle(float x, float y, color col, int del) {
    c = col;
    delay = del;
    pos = new PVector(x, y);
    vel = PVector.random2D().setMag(random(10));
    //Register in the update and render manager
    updateManager.add(this);
    renderManager.add(this);
  }

  /**
   Renders the object
   **/
  void render() {
    //Don't render if we;'re still delying
    if (delay > 0) return;
    //Set drawing parameters
    noStroke();
    fill(c);
    //Draws a square centered on this position
    square(pos.x - hs, pos.y - hs, size);
  }

  /**
   Updates the particle, this basically applies physics to the object
   **/
  void update() {
    //Only decrease delay if we're still dealying
    if (delay > 0) delay--;
    else {
      //Add velocity to postion
      pos.add(vel);
      //Limit velocity
      vel.mult(0.95);
      //add a bit of gravity
      vel.add(0, .5);

      //If the particle is offscreen, make it die
      if (pos.y > height) die();
    }
  }

  /**
   Remove any reference we had to this particle
   **/
  void die() {
    updateManager.remove(this);
    renderManager.remove(this);
  }
}

/**
 Create a particle effect from the provided bounding box of the screen
 **/
void createParticleEffect(float xPos, float yPos, int w, int h, color c, int d) {
  //loadpixels was already done in the grid
  for (int x = int(xPos); x < xPos + w; x+= PARTICLE_SIZE) {
    for (int y = int(yPos); y < yPos + h; y+= PARTICLE_SIZE) {
      new Particle(x, y, c, d);
    }
  }
}
