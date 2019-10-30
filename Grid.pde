/**
 The Grid is the main play area of tetris, it keeps
 tracks of all the rules and renders the blocks
 **/
class Grid implements IUpdate, IRender {
  //The size of the grid
  private int block_size;
  //The thickness of the border
  private int border;
  //The dimensions of this grid, in pixels
  private PVector dim = new PVector();
  //The size of the grid
  XY2D size;
  //The list of cells that we have in the grid
  Cell[] cells;
  //The offset that we render the grid at
  private PVector offset = new PVector();
  //List of cells to be popped in order
  ArrayList<Cell> popList = new ArrayList<Cell>();

  /**
   Creates the Grid instance
   **/
  Grid() {
    //Add to renderer and updater
    updateManager.add(this);
    renderManager.add(this);
    //Load block size from the constant defined in the first tab
    block_size = BLOCK_SIZE;
    border = (int) BLOCK_SIZE / 10;
    calcGridSize();
    ui.setBounds(offset.x + dim.x);
  }
  
  /**
  Resets the grid into a clear array once again
  **/
  void reset(){
    int i = 0;
    for(Cell c: cells){
      c.pop(i);
      i++;
    }
  }

  /**
   Calculate the grid size relative to the screen size
   **/
  private void calcGridSize() {
    //Calculate an approximate size
    float hw = (width / 9) * 5;//Roughly take up half of the width
    float h = height + 4 * block_size;//Take up the entire height of the screen plus 4 block height
    //Now round these numbers to round block sizes
    hw = hw - (hw % block_size);
    h = h - (h % block_size);
    dim = new PVector(hw, h);

    //Calculate the size of the grid in block numbers
    size = new XY2D(round(hw / block_size), round(h / block_size));
    //Instantiate the list of cells, and each one of them separately
    cells = new Cell[size.x * size.y];
    for (int i = 0; i < cells.length; i++) {
      cells[i] = new Cell(this, i);
    }

    //Finally calculate the offset
    offset = new PVector(block_size * .5, block_size * -4.5);
  }
  
  /**
  Empty the cell without any fancy graphics
  **/
  void init(){
    //Make the cell empty
    for(Cell c: cells){
      c.empty();
    }
  }

  /**
   Turns a index number into a vector
   **/
  XY2D i2v(int i) {
    int x = i % size.x;
    int y = (int) (i - x) / size.x;
    return new XY2D(x, y);
  }

  /**
   Turns a vector into an index number
   **/
  int v2i(XY2D v) {
    return v.y * size.x + v.x;
  }

  /**
   Converts from cell coordinates to global
   **/
  PVector toGlobal(Cell c) {
    return new PVector(bs(c.pos.x) + offset.x, bs(c.pos.y) + offset.y);
  }

  /**
   Renders the grid and anything in it
   **/
  void render() {
    //First translate to the appropriate offset of this grid
    pushMatrix();
    translate(offset.x, offset.y);
    //Now render all cells
    for (Cell c : cells) c.render();
    //Render the outline of the play area
    noFill();
    stroke(255, 120);
    strokeWeight(border);
    rect(0, 0, dim.x, dim.y);
    //Restore the translation of the matrix
    popMatrix();
  }

  /**
   Updates the grid
   **/
  void update() {
    //Update all the cells
    for (Cell c : cells) c.update();

    //Only check for tetris if the shape has rested
    if (activeShape == null && gotTetris < 5) {
      //Check all the grid lines for a tetris
      for (int i = size.y - 1; i >= 0; i--) {
        boolean tetris = true;
        for (int j = 0; j < size.x; j++) {
          if (getCell(j, i).isEmpty()) {
            tetris = false;
            break;
          }
        }
        //If we reach this, we have made a tetris
        if (tetris) {
          //Add a bit of score
          ui.addScore(tetrisScore);
          //And multiply the score
          tetrisScore *= 2;
          //Set the tetris delay to 30 frames
          gotTetris = 30;
          //Play the explosion sound
          soundManager.playExplosion();
          //And pop all blocks on this line
          for (int j = 0; j < size.x; j++) {
            getCell(j, i).pop(j);
          }
          //Move all blocks above this down one
          for (int y = i - 1; y > 0; y--) {
            for (int j = 0; j < size.x; j++) {
              down(getCell(j, y));
            }
          }
          break;
        }
      }
    }
  }

  //Returns multiples of the block size
  float bs(float m) {
    return m * block_size;
  }

  /**
   Moves the contents of the cell down one
   **/
  boolean down(Cell c) {
    //See what a lower cell is
    XY2D bottom = new XY2D(c.pos.x, c.pos.y);
    bottom.add(0, 1);
    //Dont do anything if we are going out of bounds
    if (bottom.y >= size.y) {
      return false;
    }
    //Move the color down one
    Cell neighbor = cells[v2i(bottom)];
    //only move down if the down neighbor is empty
    if (! neighbor.isEmpty()) {
      return false;
    }
    //If all is clear, move over the color
    neighbor.c = c.c;
    //And reset yourself
    c.empty();
    return true;
  }

  /**
   Move to the left, optionally ignore collision
   **/
  boolean left(Cell c) {
    //See what a left cell is
    XY2D bottom = new XY2D(c.pos.x, c.pos.y);
    bottom.add(-1, 0);
    //Dont do anything if we are going out of bounds
    if (bottom.x < 0) {
      return false;
    }
    //Move the color down one
    Cell neighbor = cells[v2i(bottom)];
    //only move down if the down neighbor is empty
    if (! neighbor.isEmpty()) {
      return false;
    }
    //If all is clear, move over the color
    neighbor.c = c.c;
    //And reset yourself
    c.empty();
    return true;
  }

  /**
   Check if we can move to the right, if so, do so :D
   **/
  boolean right(Cell c) {
    //See what a left cell is
    XY2D bottom = new XY2D(c.pos.x, c.pos.y);
    bottom.add(1, 0);
    //Dont do anything if we are going out of bounds
    if (bottom.x >= size.x) {
      return false;
    }
    //Move the color down one
    Cell neighbor = cells[v2i(bottom)];
    //only move down if the down neighbor is empty
    if (! neighbor.isEmpty()) {
      return false;
    }
    //If all is clear, move over the color
    neighbor.c = c.c;
    //And reset yourself
    c.empty();
    return true;
  }

  /**
   Move a cell up without checking bounds and stuff, 
   this is used to undo the down step
   **/
  void up(Cell c) {
    //See what a lower cell is
    XY2D top = new XY2D(c.pos.x, c.pos.y);
    top.add(0, -1);
    Cell neighbor = cells[v2i(top)];
    neighbor.c = c.c;
    c.empty();
  }

  /**
   Returns a cell at the provided position
   **/
  Cell getCell(int x, int y) {
    if (x < 0 || x >= size.x)  return null;
    else if (y < 0 || y>= size.y) return null;
    return cells[v2i(new XY2D(x, y))];
  }
}

/**
 Simple 2D grid (int) indeces
 **/
class XY2D {
  int x = 0;
  int y = 0;
  /**
   Creates a new position at the provided location
   **/
  XY2D(int posX, int posY) {
    x = posX;
    y = posY;
  }

  /**
   (Re)sets the position of this vector
   **/
  void set(int posX, int posY) {
    x = posX;
    y = posY;
  }

  /**
   Add the provided numbrs to the provided vector
   **/
  void add(int dx, int dy) {
    x+= dx;
    y+= dy;
  }

  /**
   Add the provided vector's components to this vector
   **/
  void add(XY2D v) {
    x += v.x;
    y += v.y;
  }
}

/**
 A single cell that can be rendered
 **/
class Cell {
  //The position in the grid
  XY2D pos;
  //The color of this cell
  color c;
  //The parent grid that we belong to
  Grid g;

  /**
   Creates a new cell in the provided grid at the 
   provided position
   **/
  Cell(Grid parent, int index) {
    g = parent;
    pos = g.i2v(index);
    c = color(0);
  }

  /**
   Renders this single cell
   **/
  void render() {
    //Dont render empty cels
    if (isEmpty()) return;
    noStroke();
    //Remember position
    pushMatrix();
    //Do the translate
    translate(pos.x * g.block_size, pos.y * g.block_size);
    drawCell();
    //Pop the matrix
    popMatrix();
  }

  /**
   Called whenever a tetris is made
   **/
  void pop(int delay) {
    //If we are not black
    if(c == -16777216) return;
    createParticleEffect(pos.x * g.block_size + g.offset.x, pos.y * g.block_size + g.offset.y, BLOCK_SIZE, BLOCK_SIZE, c, delay);
    //Then empty this place
    empty();
  }

  /**
   If this cell is empty (color = 0)
   **/
  boolean isEmpty() {
    //Is the color set to black?
    return c == -16777216;
  }

  /**
   Empty this cell
   **/
  void empty() {
    c = color(0);
  }

  /**
   Render yourself
   **/
  void drawCell() {
    //First draw a solid color background
    fill(c);
    square(0, 0, g.bs(1));
    //Now draw a darker triangle
    fill(0, 120);
    triangle(g.bs(1), 0, g.bs(1), g.bs(1), 0, g.bs(1));
    //And the lighter triangle
    fill(255, 120);
    triangle(0, 0, g.bs(1), 0, 0, g.bs(1));
    //Finally overlay the normal color again
    fill(c);
    square(g.border, g.border, g.bs(1) - g.border * 2);

    //Mutate color a little every couple of frames frames
    if (frameCount % 6 == 0 && JUICY) c = color(hue(c) + 6, saturation(c), brightness(c));
  }

  /**
   Updates every cell
   **/
  void update() {
    //Only update a living cell
    if (isEmpty()) return;
  }
}

/**
 A tetris shape
 **/
class TShape implements IUpdate {
  //The locations we're at
  ArrayList<XY2D> cells = new ArrayList<XY2D>();
  //Counts frames
  int frameCounter = 0;
  //How often we drop down
  int fallRate = 10;
  //Reference to the grid
  Grid grid;
  //The shape we have, defined by a single letter
  int shape;

  /**
   Creates a new TShape at the provided position
   **/
  TShape(Grid g) {
    grid = g;
    //Add this to be updated
    updateManager.add(this);
    //MAke the first shape
    int x = (int) random(g.size.x);
    randomShape((int) random(7), x);
    color c = color(random(255), 255, 255);
    for (XY2D pos : cells) {
      g.getCell(pos.x, pos.y).c = c;
    }
  }

  /**
   Set the coordinates to match a specific shape
   **/
  void randomShape(int type, int x) {
    //Properly parse the shape of this tetris piece
    shape = type;
    //Set the cells depending on the shape we have assigned
    switch(type) {
    case 0: // i piece
      cells.add(new XY2D(x, 0));
      cells.add(new XY2D(x, 1));
      cells.add(new XY2D(x, 2));
      cells.add(new XY2D(x, 3));
      break;
    case 1: // o piece
      if (x > grid.size.x - 2) x --;
      cells.add(new XY2D(x, 2));
      cells.add(new XY2D(x, 3));
      cells.add(new XY2D(x + 1, 2));
      cells.add(new XY2D(x + 1, 3));
      break;
    case 2: // l piece
      if (x > grid.size.x - 2) x = grid.size.x - 2;
      else if (x < 1) x = 1;
      cells.add(new XY2D(x - 1, 2));
      cells.add(new XY2D(x - 1, 3));
      cells.add(new XY2D(x, 2));
      cells.add(new XY2D(x + 1, 2));
      break;
    case 3: // t piece
      if (x > grid.size.x - 2) x = grid.size.x - 2;
      else if (x < 1) x = 1;
      cells.add(new XY2D(x + 1, 2));
      cells.add(new XY2D(x, 2));
      cells.add(new XY2D(x - 1, 2));
      cells.add(new XY2D(x, 3));
      break;
    case 4: // j piece
      if (x > grid.size.x - 3) x = grid.size.x - 3;
      else if (x < 1) x = 1;
      cells.add(new XY2D(x - 1, 2));
      cells.add(new XY2D(x - 1, 3));
      cells.add(new XY2D(x, 3));
      cells.add(new XY2D(x + 1, 3));
      break;
    case 5: // s piece
      if (x > grid.size.x - 3) x = grid.size.x - 3;
      else if (x < 1) x = 1;
      cells.add(new XY2D(x + 1, 2));
      cells.add(new XY2D(x, 2));
      cells.add(new XY2D(x, 3));
      cells.add(new XY2D(x - 1, 3));
      break;
    case 6: // z piece
      if (x > grid.size.x - 3) x = grid.size.x - 3;
      else if (x < 1) x = 1;
      cells.add(new XY2D(x - 1, 2));
      cells.add(new XY2D(x, 2));
      cells.add(new XY2D(x, 3));
      cells.add(new XY2D(x + 1, 3));
      break;
    }
  }

  /**
   The update function, moves this block
   **/
  void update() {
    if (frameCounter > fallRate) {
      frameCounter = 0;
      Collections.sort(cells, new Comparator<XY2D>() {
        public int compare(XY2D o1, XY2D o2) {
          return o1.y - o2.y;
        }
      }
      );
      dropDown();
    }
    frameCounter++;

    //If the spacebar is down, move down extra fast
    if (speedPressed) {
      frameCounter += fallRate / 2;
      ui.addScore(1);
    }

    //If the left is down, move to the left
    if (leftPressed) {
      leftPressed = false;
      moveLeft();
    }
    //If the right is down, move to the right
    if (rightPressed) {
      rightPressed = false;
      moveRight();
    }

    //If the up arrow is pressed, rotate
    if (rotatePressed) {
      rotateShape();
      rotatePressed = false;//Set the key to unpressed, to make it only register on a new press
    }
  }

  /**
   Rotates the shape into one of its turned shapes.
   **/
  void rotateShape() {
    //Play the blip if we're rotating
    soundManager.playBlip();
    //If this shape is o, don't try to turn it
    if (shape == 'o') return;
    //Calculate center point
    PVector center = new PVector();
    //Add to the sum
    for (XY2D c : cells) center.add(c.x, c.y);
    //Now divide the sum by the amount of cells
    center.div(cells.size());
    //Next see which cell is closed to this point
    XY2D cp = null;
    float dist = Float.MAX_VALUE;
    for (XY2D p : cells) {
      float d = dist(p.x, p.y, center.x, center.y);
      //We have a new record
      if (d < dist) {
        dist = d;
        //Set the reference to the new best centerpoint
        cp = p;
      }
    }
    //We now have found the center point, if not( don't know how), return
    if (cp == null) return;

    //Let's make a list of the new oriented location
    ArrayList<XY2D> newCells = new ArrayList<XY2D>();
    //Go thourhg all old locations and rotate them
    for (XY2D p : cells) {
      XY2D local = new XY2D(p.x - cp.x, cp.y - p.y);
      XY2D rotated = new XY2D(local.y, local.x);
      XY2D global = new XY2D(rotated.x + cp.x, rotated.y + cp.y);
      //Add this to the newCells
      newCells.add(global);
    }

    //Check each of the new cells if it is feasible to be there
    boolean allOkay = true;
    for (XY2D p : newCells) {
      //Get the cell at this new location
      Cell c = grid.getCell(p.x, p.y);
      //Check if it is a part of us already
      boolean partOfUs = false;
      for (XY2D p2 : cells) if (p2.x == p.x && p.y == p2.y) partOfUs = true;
      //Or if the cell is empty
      Cell neighbor = grid.getCell(p.x, p.y);
      boolean emptySpot = true;
      if (neighbor != null) emptySpot = neighbor.isEmpty();
      else emptySpot = false;
      //If the spot is not empty 
      if (!(emptySpot || partOfUs)) {
        allOkay = false;
        break;
      }
    }

    //If we're okay, do the rotation
    if (allOkay) {
      //Remember color of center point
      color col = grid.getCell(cp.x, cp.y).c;
      //Unset all pieces
      for (XY2D oldCell : cells) {
        grid.getCell(oldCell.x, oldCell.y).empty();
      }
      //Clear the cells list
      cells.clear();
      //Now set all cells in the new cell list
      for (XY2D newCell : newCells) {
        grid.getCell(newCell.x, newCell.y).c = col;
        cells.add(newCell);
      }
    }
  }

  /**
   See if there is room to the left for every block
   **/
  void moveLeft() {
    //Sort by x
    Collections.sort(cells, new Comparator<XY2D>() {
      public int compare(XY2D o1, XY2D o2) {
        return o2.x - o1.x;
      }
    }
    );
    //Go through the cells backwards
    for (int i = cells.size() - 1; i >= 0; i--) {
      XY2D pos = cells.get(i);
      Cell c = grid.getCell(pos.x, pos.y);
      if (!grid.left(c)) {
        //Since we had a collision, move everything that we moved so far back one
        for (int j = i + 1; j < cells.size(); j++) {
          pos = cells.get(j);
          c = grid.getCell(pos.x, pos.y);
          grid.right(c);
        }
        break;
      } else {
        //Else move it down a little
        cells.get(i).add(-1, 0);
      }
    }
  }

  /**
   See if there is room to the left for every block
   **/
  void moveRight() {
    //Sort by x
    Collections.sort(cells, new Comparator<XY2D>() {
      public int compare(XY2D o1, XY2D o2) {
        return o1.x - o2.x;
      }
    }
    );
    //Go through the cells backwards
    for (int i = cells.size() - 1; i >= 0; i--) {
      XY2D pos = cells.get(i);
      Cell c = grid.getCell(pos.x, pos.y);
      if (!grid.right(c)) {
        //Since we had a collision, move everything that we moved so far back one
        for (int j = i + 1; j < cells.size(); j++) {
          pos = cells.get(j);
          c = grid.getCell(pos.x, pos.y);
          grid.left(c);
        }
        break;
      } else {
        //Else move it down a little
        cells.get(i).add(1, 0);
      }
    }
  }

  /**
   Tries to do a dropdown
   **/
  void dropDown() {
    //Go through the cells backwards
    for (int i = cells.size() - 1; i >= 0; i--) {
      XY2D pos = cells.get(i);
      Cell c = grid.getCell(pos.x, pos.y);
      if (!grid.down(c)) {
        //Since we had a collision, move everything that we moved so far back one
        for (int j = i + 1; j < cells.size(); j++) {
          pos = cells.get(j);
          c = grid.getCell(pos.x, pos.y);
          grid.up(c);
        }
        //Now since we had to stop, let's set our reference to null
        activeShape = null;
        ui.addScore(BLOCK_SCORE + shape * 10);
        //Check if we're still partially above the screen, if so, gameover
        boolean gameover = false;
        for(XY2D cpos : cells){
          if(cpos.y <= 4) {
            gameover = true;
            soundManager.impact1.play();
            break;
          }
        }
        //Set gameOver to true
        if(gameover) doGameOver();
        
        //Wait for 2 frames to get any tetris' we had
        gotTetris = 5;
        //Play the down sound
        soundManager.playDown();
        //And stop updating us
        updateManager.remove(this);
        break;
      } else {
        //Else move it down a little
        cells.get(i).add(0, 1);
      }
    }
  }
}
