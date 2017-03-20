int score = 0; //variable holds the score
int start = 0; //variable either 0 or 1, 1 means user has started a newGame
int lives = 3; //variable to hold the number of lives when = 0 game over
int asteroidSize = 64; //variable to store current asteroid size
int asteroidNum = 3; //variable to store the number of asteroids to be drawn
PShape a; //PShape for the design of the asteroids
Asteroid[] myAsteroids = new Asteroid[asteroidNum]; //Create a new array of asteroid objects
float tx1 = 300; //X- co-oridnate of the tip of the ship
float ty1 = 300; //Y- co-oridnate of the tip of the ship
float angle = 0; //Angle that the ship is facing


void setup() {
  size(600, 600);
  smooth();
  background(0); //Black
  asteroidsCreate(); //setup initial asteroids
}

void draw() {
  background(0);
  if (start == 0) { //Check if the user has started the game
    startMenu(); //Draw the start screen
    for (int i = 0; i < asteroidNum; i++) {
    myAsteroids[i].move();
    } 
  }
  else if(start == 1) { //If user clicks "PLAY GAME" do this
    asteroidsCreate(); //Creates the games asteroids
    start++; //Increment stat by 1 to ensure no more asteroids are created
    }
  else { 
    ship(); //Displays the triangle ship
    //For loop to move each asteroid in the array of asteroids.
    for (int i = 0; i < asteroidNum; i++) {
    myAsteroids[i].move(); //Move function to move the asteroids
    }     
  }
  fill(255); //white
  textSize(32); //Set the score text size
  text("SCORE: " + score, 10, 30); //Display score
  text("SHIPS: " + lives, 470, 30); //Display lives remaining
}

/**
Function draws the start screen.
**/
void startMenu() {
  textSize(64);
  text("ASTEROIDS",120,300);
  textSize(32);
  text("PLAY GAME",200,450);
}
    
/**
Function checks for user mouse Click
**/
void mousePressed() {
  if(mouseX > 100 && mouseX < 500 && mouseY< 500 && mouseY > 400 && start == 0) {
    start = 1;
  }
}

/**
Function checks for ke presses
**/
void keyPressed() {
  if (key == CODED) { 
    if(keyCode == LEFT) { //Left key pressed rotate ship left
     angle--;
    }
    if(keyCode == RIGHT) { //Right key pressed rotate ship right
    angle++;
    }
    if(keyCode == UP) { //Still to be written
    }
  }
}  


/**
Function creates initial asteroids for start screen and game play.
**/
void asteroidsCreate() {
  //Create the initial asteroids inside an array.   
  for(int i = 0; i < asteroidNum; i++) { 
  //Each asteroid has a random x and y starting co-ordinate between 0-600 and a random speed between -2,2
  myAsteroids[i] = new Asteroid(int(random(0,600)), int(random(0,600)), random(-2,2), asteroidSize);
  }
  //For loop to display each of the asteroids from the array of asteroids
  for (int i = 0; i < asteroidNum; i++) {
    myAsteroids[i].display();
  }  
}
  
/**
Function draws the ship triangle and allows for rotation (May create a ship class if requried)
**/
void ship() {
  smooth(); 
  fill(255); //white
  pushMatrix(); //Record the current center co-ord
  translate(tx1, ty1); //Translate based of the ships tip x and y coordinate (to allow for rotation)
  rotate(radians(angle)); //rotate based on the angle input from left or right arrow key
  //draw the new ship triangle
  triangle (0, 0,  
  -10, +30, +10, +30);
  popMatrix(); //Return the center co-ord to previous co-ord.
  
}


/**
Asteroid Class creates asteroids objects.
**/
class Asteroid {
  float x; //Stores the asteroids x co-ordinate
  float y; //Stores the asteroids y co-ordinate
  float speed; //sets the speed of the asteroid values between -2,2 are usually good -1,1 is slower
  float rotSpeed = 0; //sets the rotational speed of the asteroids. Not used yet but I want to rotate them the same as the ship
  int size; //stores the size of the asteroid
  
  Asteroid(float ax, float ay, float aSpeed, int aSize)
  {
    x = ax; //stores the x co-ordinate of the asteroid
    y = ay; //stores the y co-ordinate of the asteroid
    speed = aSpeed; //stores the speed of the asteroid, each is different
    size = aSize; //stores the size of the asteroid
    
    //The following lines of code create the shape of the asteroid using a PShape
    a = createShape();
    a.beginShape();
    a.noFill(); //Tranparent
    a.strokeWeight(0.5);
    a.stroke(255); //White outline
    //For loop creates verticies randomly to create asteroid like shape, each time the program loads the asteroid will look different
    for(float i=0; i<TWO_PI; i=i+PI/(random(3, 10))) {
      a.vertex(random(size*0.8, size)*cos(i), random(size*0.8, size)*sin(i));
    }
    a.endShape(CLOSE);
  }

/**
This function moves the asteroid based on its speed
**/
  void move() {
    x += speed; //Change the x co-ordinate based on speed
    y += speed; //Change the y co-ordinate based on speed
    display(); //Calls to display after moving x and y
  }
  
/**
This function reduces the size of the asteroid. (Not currently used but will be handy)
**/  
  void changeSize() {
    if(size > 16) {
    size /= 2;
    }
  }
 
/**
The display() function ensures the asteroid is within the defined boundaries and then draws the asteroid.
**/
  void display()
  {
    fill(0);
//The following if statements ensure the asteroid is within the screen if not it will rejoin the other side.
    if(x < (0 - (size/2))) {
      x = width + (size/2);
    }
    if(x > (width + (size/2))) {
      x = (0 - (size/2));
    }
    if(y < (0 - (size/2))) { 
      y = height + (size/2);
    }
    if(y > (height + (size/2))) {
      y = (0 - (size/2));
    }
    
    shape(a, x, y); //draw the PShape (asteroid)
  }
}