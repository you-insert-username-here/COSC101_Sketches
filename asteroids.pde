import java.util.*;
int score = 0; //variable holds the score
int start = 0; //variable either 0 or 1, 1 means user has started a newGame
int lives = 3; //variable to hold the number of lives when = 0 game over
int asteroidSize = 60; //variable to store current asteroid size
ArrayList<Asteroid> asteroids = new ArrayList<Asteroid>(); //Create a new ListArray of Asteroid objects
ArrayList<Asteroid> debris = new ArrayList<Asteroid>();
ArrayList<Cannon> cannons = new ArrayList<Cannon>();
float shipX = 300; //X- co-oridnate of the tip of the ship
float shipY = 300; //Y- co-oridnate of the tip of the ship
float shipAngle = radians(180.0); //Angle that the ship is facing, starts facing up.
float sSpeedX = 0.0; //Variable to store ship X movement speed
float sSpeedY = 0.0; //Variable to store ship Y movement speed
float acceleration = 0.03; //Increment of how fast the ship accelerates when keys pressed
float drag = 0.995; //Coefficient of drag applied to the ship (almost 1 i.e space)
boolean[] buttonPressed = new boolean[256]; //Boolean array to store whether a key has been pressed or released
int frames; //Frame counter for cannon firing rate
int debrisFrames; //Frame counter for debris asteroid annimation
float maxSpeed = 1.0;
int levelCount = 1;

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
  if (asteroids.size() == 0) { //If no asteroids left reset the level.
    reset(); //Reset
    levelCount++;
    lives++;
    start = 1; //Remakes asteroids
  }
  if(start == 1) { //If user clicks "PLAY GAME" do this
    asteroids.clear(); //Removes the start screen asteroids
    cannons.clear();
    switch (levelCount) {
      case 1: asteroidCreate(3, 60); //Creates the games asteroids
              break;
      case 2: asteroidCreate(3, 60); //Creates the games asteroids
              maxSpeed += 0.5;
              break;
      case 3: asteroidCreate(4, 60); //Creates the games asteroids
              break;
      case 4: asteroidCreate(4, 60); //Creates the games asteroids
              maxSpeed += 0.5;
              break;
      case 5: asteroidCreate(5, 60); //Creates the games asteroids
              break;
      case 6: asteroidCreate(5, 60); //Creates the games asteroids
              maxSpeed += 0.5;
              break;
      case 7: asteroidCreate(6, 60); //Creates the games asteroids
              break;
      default: asteroidCreate(6, 60); //Creates the games asteroids
              maxSpeed = 3.0;
              break;
    }
    start++; //Increment start by 1 to ensure no more asteroids are created
  } else if(lives < 1) { //If out of lives Game over.
     //start++; //This may be redundent code leaving here for now.
     gameOver(); //Displays the end screen
  } else if(start == 2) { //This is the main game display
    ship(); //Displays the triangle ship
    shoot();
    //For loop to move each asteroid in the array of asteroids.
    for (int i = 0; i < asteroids.size(); i++) {
      asteroids.get(i).move(); //Move function to move the asteroids
      shipCollision(); //Check if ship collides with any asteroid
      cannonCollision(); //Check if the cannon bullets collides with any asteroid
      //noFill();
      //strokeWeight(5);
      //stroke(255);
      //point(asteroids.get(i).getX(), asteroids.get(i).getY());
      //ellipse(asteroids.get(i).getX(), asteroids.get(i).getY(), 60, 60);
     }
     for(int i = 0; i < cannons.size(); i++) { //Loops through each cannon object
       cannons.get(i).fire(); //Fires the cannon bullets
     }
     if(frameCount < debrisFrames + 30){ //Check to see if debris need to be displayed. Display animation for 30 frames
       for(int d = 0; d < debris.size(); d++){
         debris.get(d).move(); //Make the debris asteroids move
         debris.get(d).display(); //Display the debris aseroids
       }
   } else {
       debris.clear(); //If they don't need to be displayed wipe the arrayList Buffer.
   }
     
  }
  fill(255); //white
  textSize(32); //Set the score text size
  text("SCORE: " + score, 10, 30); //Display score
  text("SHIPS: " + lives, 470, 30); //Display lives remaining 
}

/**
This function checks for cannon bullet collission with asteroids.
**/
void cannonCollision() { 
  float cX = 0; //stores cannon X
  float cY = 0; //stores cannon y
  float aX = 0; //stores asteroid x
  float aY = 0; //stores asteroid y 

for(int j = 0; j < cannons.size(); j++ ){ //for loop, loops through each cannon bullet
  cX = cannons.get(j).getX(); 
  cY = cannons.get(j).getY();
    for(int i = 0; i < asteroids.size(); i++ ){ //for loop, loops through each asteroid
      aX = asteroids.get(i).getX();
      aY = asteroids.get(i).getY();
      if(cX < aX + asteroids.get(i).getSize() && cX > aX - asteroids.get(i).getSize() && cY < aY + asteroids.get(i).getSize() && cY > aY - asteroids.get(i).getSize()) {
         if(asteroids.get(i).getSize() == 60) { //if the asteroid that is shot is a big one create two medium ones at the asteroids current x/y
            debrisFrames = frameCount; //Assign current frame count to debrisFrame for animation control
            for(int p = 0; p < 3; p++) {  //For loop to create three asteroid objects of size 1 that look like asteroid debris
               debris.add(new Asteroid(aX + random(0,60), aY + random(0,60), random(-0.25, 0.25), 1));
            }
            asteroidCreate(2, asteroidSize/2, aX, aY);
            asteroids.remove(i); //remove the Asteroid that collided
            cannons.remove(j); //Remove the Cannon that collided
            score += 10; //Increment the score by 10 for a large asteroid
            break;
          }
         else if(asteroids.get(i).getSize() == 30) { //If the asteroid that is shot is a medium one create two small ones at asteroids current x/y
            debrisFrames = frameCount; //Assign current frame count to debrisFrame for animation control
            for(int p = 0; p < 3; p++) {  //For loop to create three asteroid objects of size 1 that look like asteroid debris
               debris.add(new Asteroid(aX + random(0,30), aY + random(0,30), random(-0.25, 0.25), 1));
            }
            asteroidCreate(2, asteroidSize/4, aX, aY);
            score += 25; //Increment the score by 25 for a medium asteroid
            asteroids.remove(i); //remove the Asteroid that collided
            cannons.remove(j); //Remove the Cannon that collided
            break;
         }
         else if(asteroids.get(i).getSize() == 15) { //If the asteroid that is shot is the smallest one remove it all together
            debrisFrames = frameCount; //Assign current frame count to debrisFrame for animation control
            for(int p = 0; p < 3; p++) {  //For loop to create three asteroid objects of size 1 that look like asteroid debris
               debris.add(new Asteroid(aX + random(0,15), aY + random(0,15), random(-0.25, 0.25), 1));
            }
            score += 50; //Increment the score by 50 for a small asteroid
            asteroids.remove(i); //remove the Asteroid that collided
            cannons.remove(j); //Remove the Cannon that collided
            break;
         }
       }
    }
  }
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
      reset();
      if(asteroids.get(i).getSize() == 60) { //if the asteroid that collides is a big one create two medium ones at the asteroids current x/y
        debrisFrames = frameCount; //Assign current frame count to debrisFrame for animation control
            for(int p = 0; p < 3; p++) {  //For loop to create three asteroid objects of size 1 that look like asteroid debris
               debris.add(new Asteroid(aX + random(0,60), aY + random(0,60), random(-0.25, 0.25), 1));
            }
        asteroidCreate(2, asteroidSize/2, aX, aY);
        asteroids.remove(i); //remove the asteroid that collided
      }
      else if(asteroids.get(i).getSize() == 30) { //If the asteroid that collides is a medium one create two small ones at asteroids current x/y
        debrisFrames = frameCount; //Assign current frame count to debrisFrame for animation control
            for(int p = 0; p < 3; p++) {  //For loop to create three asteroid objects of size 1 that look like asteroid debris
               debris.add(new Asteroid(aX + random(0,30), aY + random(0,30), random(-0.25, 0.25), 1));
            }
        asteroidCreate(2, asteroidSize/4, aX, aY);
        asteroids.remove(i); //Remove the medium asteroid
      }
      else if(asteroids.get(i).getSize() == 15) { //If the asteroid is the smallest one remove it all together
        debrisFrames = frameCount; //Assign current frame count to debrisFrame for animation control
            for(int p = 0; p < 3; p++) {  //For loop to create three asteroid objects of size 1 that look like asteroid debris
               debris.add(new Asteroid(aX + random(0,15), aY + random(0,15), random(-0.25, 0.25), 1));
            }
        asteroids.remove(i); //Remove the small asteroid
      }
      
      lives--; //Reduce the amount of ships remaining by one
    }
  }
}
/**
Function draws the start screen.
**/
void startMenu() {
  fill(255);
  textSize(64);
  text("ASTEROIDS",120,300);
  textSize(32);
  text("PLAY GAME",200,450);
}

/**
Function draws the end screen
**/
void gameOver() {
  textSize(64);
  text("GAME OVER",120,300);
  textSize(32);
  text("RESET",265,450);
  levelCount = 1;
  maxSpeed = 1;
}  

/**
This Function resets starting parameters.
**/
void reset() {
  shipX = 300; 
  shipY = 300;
  cannons.clear();
  sSpeedX = 0.0;
  sSpeedY = 0.0;
  shipAngle = radians(180); //Angle that the ship is facing starts facing up.
  acceleration = 0.03;
  drag = 0.995;
}

/**
Function checks for user mouse Click
**/
void mousePressed() {
  if(mouseX > 100 && mouseX < 500 && mouseY< 500 && mouseY > 400 && start == 0) { //Start Screen
    start = 1;
    
}
  if(mouseX > 100 && mouseX < 500 && mouseY< 500 && mouseY > 400 && lives < 1){ //Game Over Screen
    start = 0;
    score = 0;
    lives = 3;
    reset();
  }
}

/**
Function checks for key presses
**/
void keyPressed() {
    buttonPressed[keyCode] = true; //Assign true to the key that has been pressed
}

/**
Function checks for key releases
**/ 
void keyReleased() {
    buttonPressed[keyCode] = false; //Asign false to the key when the key is released
 
}

/**
Function displays the cannon bullets
**/ 
void shoot() {
  if (buttonPressed[' '] && frameCount - frames > 15) { //If the space key is pressed and it has been more than 15 frames (i.e fire rate) do this
      frames = frameCount; //Stores the current frameCount
      cannons.add(new Cannon(shipX, shipY, shipAngle + radians(90), 1)); //Create new cannon object
      for(int i = 0; i < cannons.size(); i++) { //For loop to display each cannon object
        cannons.get(i).display();
      }
    }
}

/**
 Function creates asteroids for on going game play.
**/
void asteroidCreate(int amountOfAsteroids, int sizeOfAsteroids, float x, float y) { //Could change this to include x/y parameters
  int a = amountOfAsteroids; //How many asteroids to make
  int size2 = sizeOfAsteroids; //The size of the asteroids
  float aX = x;
  float aY = y;
  //Create the initial asteroids inside an array.   
 for (int i = 0; i < a; i++) { 
    //Each asteroid has a random x and y starting co-ordinate between that is between 0 and 600, but 50 away from the ship in x and y, and a random speed between -2,2 
    asteroids.add(new Asteroid(aX, aY, random(-maxSpeed, maxSpeed), size2));
  }
}

/**
 Function creates asteroids for start screen and initial game play.
**/
void asteroidCreate(int amountOfAsteroids, int sizeOfAsteroids) { //Could change this to include x/y parameters
  int a = amountOfAsteroids; //How many asteroids to make
  int size2 = sizeOfAsteroids; //The size of the asteroids
  //Create the initial asteroids inside an array.   
 for (int i = 0; i < a; i++) { 
    //Each asteroid has a random x and y starting co-ordinate between that is between 0 and 600, but 50 away from the ship in x and y, and a random speed between -2,2 
    Random random = new Random();
    int x1 = int(random(0, shipX-80));
    int x2 = int(random(shipX+80, 600));
    int y1 = int(random(0, shipY-80));
    int y2 = int(random(shipY+80, 600));
    int x = random.nextBoolean() ? x1: x2;
    int y = random.nextBoolean() ? y1: y2;
    asteroids.add(new Asteroid(x, y, random(-maxSpeed, maxSpeed), size2));
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
      sSpeedX += cos(shipAngle + radians(90)) * acceleration; //Ship speed is increased based on angle and acceleration increment
      sSpeedY += sin(shipAngle + radians(90)) * acceleration; //Ship speed is increased based on angle and acceleration increment
    }
    if (buttonPressed[DOWN]) { //If the Down key is pressed do this.
      sSpeedX -= cos(shipAngle + radians(90)) * acceleration; //Ship speed is decreased based on angle and acceleration increment
      sSpeedY -= sin(shipAngle + radians(90)) * acceleration; //Ship speed is decreased based on angle and acceleration increment
    }
    
    
  smooth(); 
  fill(255); //white
  strokeWeight(0);
  pushMatrix(); 
  translate(shipX, shipY); //Translate based of the ships tip x and y coordinate (to allow for rotation)
  rotate(shipAngle); //rotate based on the angle input from left or right arrow key
  //draw the new ship triangle
  triangle (0, 5, -5, -10, +5, -10);
  if(buttonPressed[UP]){
    noStroke();
    fill(255, random(0,255),0, random(0,255));
    ellipse(0,-14, random(0,7), random(2,12));
  }
  popMatrix(); 
}


/**
Cannon Class creates cannon objects.
**/
class Cannon {
  float x; //Stores cannon x co-ordinate
  float y; //Stores cannon y co-ordinate
  float speed = 1.85; //Cannon bullet fire speed
  float size = 5; //possible future upgrade
  float angle; //Stores the angle to shoot bullet
  
//Constructor accepts x/y of ship angle of ship and size of cannon  
  Cannon(float cx, float cy, float cAngle, int cSize) { 
    x = cx; //Sets cannon x to shipX
    y = cy; //Sets cannon y to shipY
    //size = cSize; //Sets the cannon Size - not currently used
    angle = cAngle; //Sets the direction to the direction the ship is currently pointing
  }  

/**
Function draws the cannon bullet
**/
  void display() {
    stroke(255);
    strokeWeight(size); //Size of the cannon bullet
    point(x, y); //Draws teh cannon bullet
  }
  
/**
Function moves the cannon bullet in the direction the ship was pointing
**/  
  void fire() { 
      x += (speed * cos(angle) * 5); //Change the x co-ordinate based on speed
      y += (speed * sin(angle) * 5); //Change the y co-ordinate based on speed
      display(); //Calls to display after moving x and y
  }

/**
Function returns the cannon bullets x
**/
  float getX(){
    return x;
  }

/**
Function returns the cannon bullets y
**/
  float getY() {
    return y;
  }
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
  int n = round(random(0,1));
  
  Asteroid(float ax, float ay, float aSpeed, int aSize) {
    x = ax; //stores the x co-ordinate of the asteroid
    y = ay; //stores the y co-ordinate of the asteroid
    speed = aSpeed; //stores the speed of the asteroid, each is different
    size = aSize; //stores the size of the asteroid
    
    rotSpeed = random(-0.75, 0.75);
    
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
    if(n ==0) {
      x += speed; //Change the x co-ordinate based on speed
      y -= speed; //Change the y co-ordinate based on speed
    }
    else if (n == 1) {
      x += speed;
      y += speed;
    }    
    a.rotate(radians(rotSpeed));
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
