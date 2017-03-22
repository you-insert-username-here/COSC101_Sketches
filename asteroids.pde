import java.util.*;
int score = 0; //variable holds the score
int start = 0; //variable either 0 or 1, 1 means user has started a newGame
int lives = 3; //variable to hold the number of lives when = 0 game over
int asteroidSize = 60; //variable to store current asteroid size
ArrayList<Asteroid> asteroids = new ArrayList<Asteroid>(); //Create a new ListArray of Asteroid objects
float shipX = 300; //X- co-oridnate of the tip of the ship
float shipY = 300; //Y- co-oridnate of the tip of the ship
float shipAngle = radians(270.0); //Angle that the ship is facing starts facing up.
float sSpeedX = 0.0; //Variable to store ship X movement speed
float sSpeedY = 0.0; //Variable to store ship Y movement speed
float acceleration = 0.03; //Increment of how fast the ship accelerates when keys pressed
float drag = 0.995; //Coefficient of drag applied to the ship (almost 1 i.e space)
boolean[] buttonPressed = new boolean[256]; //Boolean array to store whether a key has been pressed or released

void setup() {
  size(600, 600);  //Initilise screen size
  smooth();
  background(0); //Black
  asteroidCreate(3, 60); //setup initial asteroids
  asteroidCreate(2, 30); //smaller initial asteroids
  asteroidCreate(1, 15); //smallest initial asteroids
}

void draw() {
  background(0);
  if (start == 0) { //Check if the user has started the game
    startMenu(); //Draw the start screen
    for (int i = 0; i < asteroids.size(); i++) { //loop through the list of asteroids
    asteroids.get(i).move(); //Make them move
    } 
  }
  else if(start == 1) { //If user clicks "PLAY GAME" do this
    asteroids.clear(); //Removes the start screen asteroids
    asteroidCreate(3, 60); //Creates the games asteroids
    start++; //Increment start by 1 to ensure no more asteroids are created
    }
  else { 
    ship(); //Displays the triangle ship
    //For loop to move each asteroid in the array of asteroids.
    for (int i = 0; i < asteroids.size(); i++) {
      asteroids.get(i).move(); //Move function to move the asteroids
      shipCollision(); //Check if ship collides with any asteroid
    }     
}
  fill(255); //white
  textSize(32); //Set the score text size
  text("SCORE: " + score, 10, 30); //Display score
  text("SHIPS: " + lives, 470, 30); //Display lives remaining
}

/**
This function checks for ship collission with asteroids.
**/
void shipCollision() { 
  for(int i = 0; i < asteroids.size(); i++) { //Loop through all asteroids to check if the collide with the ship
    float aX = 0; //asteroid x coordinate
    float aY = 0; //asteroid y coordinate
        
    aX = asteroids.get(i).getX(); //get the x-coordinate of each asteroid and store here
    aY = asteroids.get(i).getY(); //get the y-coordinate of each asteroid and store here
    
    //Logical statement to check if the x and y of the ship are close enough to the x and y of the asteroid to make a collission
    if(shipX < aX + asteroids.get(i).getSize() && shipX > aX - asteroids.get(i).getSize() && shipY < aY + asteroids.get(i).getSize() && shipY > aY - asteroids.get(i).getSize()) {
      //reset the ship to starting position
      shipX = 300; 
      shipY = 300; 
      
      if(asteroids.get(i).getSize() == 60) { //if the asteroid that collides is a big one create two medium ones at the asteroids current x/y
        asteroids.add(new Asteroid(aX, aY, random(-2,2), asteroidSize/2));
        asteroids.add(new Asteroid(aX, aY, random(-2,2), asteroidSize/2)); 
        asteroids.remove(i); //remove the asteroid that collided
      }
      else if(asteroids.get(i).getSize() == 30) { //If the asteroid that collides is a medium one create two small ones at asteroids current x/y
        asteroids.add(new Asteroid(aX, aY, random(-2,2), asteroidSize/4)); 
        asteroids.add(new Asteroid(aX, aY, random(-2,2), asteroidSize/4)); 
        asteroids.remove(i); //Remove the medium asteroid
      }
      else if(asteroids.get(i).getSize() == 15) { //If the asteroid is the smallest one remove it all together
        asteroids.remove(i);
      }
      
      lives--; //Reduce the amount of ships remaining by one
    }
  }
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
Function checks for key presses and releases
**/
void keyPressed() {
    buttonPressed[keyCode] = true; //Assign true to the key that has been pressed
}
 
void keyReleased() {
    buttonPressed[keyCode] = false; //Asign false to the key when the key is released
}

/**
Function creates initial asteroids for start screen and game play.
**/
void asteroidCreate(int amountOfAsteroids, int sizeOfAsteroids) {
  int a = amountOfAsteroids;
  int size2 = sizeOfAsteroids;
  //Create the initial asteroids inside an array.   
  for(int i = 0; i < a; i++) { 
  //Each asteroid has a random x and y starting co-ordinate between 0-600 and a random speed between -2,2 (Need to further limit this so asteroids can't start in middle)
  asteroids.add(new Asteroid(int(random(0,600)), int(random(0,600)), random(-2,2), size2));
  }
}
  
/**
Function draws the ship triangle and allows for rotation (May create a ship class if requried)
**/
void ship() {
  sSpeedX *= drag; //Slow the ship based on drag co-efficient
  sSpeedY *= drag; //Slow the ship based on drag co-efficient
  
  shipX += sSpeedX; //Move the ship based on current speed
  shipY += sSpeedY; //Move the ship based on current speed

//This code will move the ship to opposite side if it reaches the boundaries    
  if (shipX > width + 10) 
    shipX = -10;
  else if(shipX < -10) 
    shipX = width + 10;
  if(shipY > height + 20) 
    shipY = -20;
  else if (shipY < - 20) 
    shipY = height + 20;
      
    if (buttonPressed[LEFT]) { //If the left key is pressed do this.
     shipAngle -= radians(3.0); //Rotate ship left 3.0 degrees
    }
    if (buttonPressed[RIGHT]) { //If the right key is pressed do this.
      shipAngle += radians(3.0); //Rotate ship right 3.0 degrees
    }
    if (buttonPressed[UP]) { //If the Up key is pressed do this.
      sSpeedX += cos(shipAngle) * acceleration; //Ship speed is increased based on angle and acceleration increment
      sSpeedY += sin(shipAngle) * acceleration; //Ship speed is increased based on angle and acceleration increment
    }
    if (buttonPressed[DOWN]) { //If the Down key is pressed do this.
      sSpeedX -= cos(shipAngle) * acceleration; //Ship speed is decreased based on angle and acceleration increment
      sSpeedY -= sin(shipAngle) * acceleration; //Ship speed is decreased based on angle and acceleration increment
    }
    
    
  smooth(); 
  fill(255); //white
  pushMatrix(); 
  translate(shipX, shipY); //Translate based of the ships tip x and y coordinate (to allow for rotation)
  rotate(shipAngle); //rotate based on the angle input from left or right arrow key
  //draw the new ship triangle
  triangle (-20, -10, 10, 0, -20, 10);
  popMatrix(); 
}


/**
Asteroid Class creates asteroids objects.
**/
class Asteroid {
  PShape a; //PShape for the design of the asteroids
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
  
/**
This function returns the current x co-ordinate of the asteroid
**/
  float getX() {
    return x;
  }
  
/**
This function returns the current y co-ordinate of the asteroid
**/ 
  float getY() {
    return y;
  }
  
/**
This function returns the current size of the asteroid
**/  
  int getSize() {
    return size;
  }
}
