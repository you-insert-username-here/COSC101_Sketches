import java.util.*;
import java.io.*;
import ddf.minim.*;
AudioPlayer bgMusic, shipLaser, shipExplosion, alienExplosion, alienFire, alienAppear, shipThrust3, asteroidExplode;
Minim minim;
int time; //Variable to hold point in time in ms
int tempInvincibility = 3000; //Variable to hold invincibility time in ms after collision
boolean isInvincible; //Variable to hold invincibilty status
int score = 0; //variable holds the score
int start = 0; //variable either 0 or 1, 1 means user has started a newGame
int lives = 3; //variable to hold the number of lives when = 0 game over
int asteroidSize = 60; //variable to store current asteroid size
ArrayList<Asteroid> asteroids = new ArrayList<Asteroid>(); //Create a new ListArray of Asteroid objects
ArrayList<Asteroid> debris = new ArrayList<Asteroid>();
ArrayList<Cannon> cannons = new ArrayList<Cannon>();
ArrayList<Cannon> alienCannon = new ArrayList<Cannon>();
ArrayList<Alien> aliens = new ArrayList<Alien>();
float shipX; //X- co-oridnate of the tip of the ship
float shipY; //Y- co-oridnate of the tip of the ship
float shipAngle = radians(180.0); //Angle that the ship is facing, starts facing up.
float sSpeedX = 0.0; //Variable to store ship X movement speed
float sSpeedY = 0.0; //Variable to store ship Y movement speed
float acceleration = 0.03; //Increment of how fast the ship accelerates when keys pressed
float drag = 0.995; //Coefficient of drag applied to the ship (almost 1 i.e space)
boolean[] buttonPressed = new boolean[256]; //Boolean array to store whether a key has been pressed or released
int frames; //Frame counter for cannon firing rate
int debrisFrames; //Frame counter for debris asteroid annimation
int shipFrames; //Frame counter for ship debris annimation
int alienFrames; //Frame counter for alien space ship
float maxSpeed = 1.0; //Asteroid speed varibale
int levelCount = 1; //Stores the level count
ShipDebris sDebris; //Strores the ship debris object
String highScores[]; //Stores the high scores & names strings from file
final String fileName = "HighScores.txt"; //Creates a final variable to store the HighScores in
PrintWriter f; //Creates a print writer to output to file for high scores
int highScore = 0; //Variable stores wether a high Score has been achieved
String playerName = ""; //Variable stores the players name
int pauseInt = 0; //Variable to determine if game is paused
int howQuick = 1000; //Variable to determine how quick the enemy alien ship spawns for each level

void setup() {
  minim = new Minim(this);
  dataPath("blazeWitch.wav");
  bgMusic = minim.loadFile("witch.mp3");
  shipLaser = minim.loadFile("shipLaser.wav");
  shipExplosion = minim.loadFile("shipExplosion.wav");
  alienExplosion = minim.loadFile("alienExplosion.wav");
  alienFire = minim.loadFile("alienFire.wav");
  alienAppear = minim.loadFile("alienAppear.wav");
  shipThrust3 = minim.loadFile("shipThrust3.wav");
  asteroidExplode = minim.loadFile("asteroidExplode.wav");
  
  bgMusic.loop();
  size(900, 900);  //Initilise screen size (adjustable based on the size of the game you want to play
  isInvincible = false; //Initialise isInvincible to be false at setup
  time = 0; //Initialise time to zero at setup
  shipX = width/2; //Ship always starts in the middle no matter the screen size
  shipY = height/2; //Ship always starts in the middle no matter the screen size
  smooth();
  background(0); //Black
  File file = new File(dataPath(fileName)); //Create a new file object with the file path
  boolean exists = file.exists(); //boolean object to check if the high scores file exists
  if (exists) { //if the high scores file already exists load the high scores
    highScores = loadStrings(fileName); //Loads the highscores from text file "HighScores.txt" in the sketch data path
  } else { //I the High Scores text file doesn't exist create a high scores file with default values below
    f = createWriter(dataPath(fileName)); //Initilise a createWriter to write to the text file
    //Default high score values
    f.println("Player 1: "); 
    f.println("0");
    f.println("Player 2: ");
    f.println("0");
    f.println("Player 3: ");
    f.println("0");
    f.flush();
    f.close();
    highScores = loadStrings(fileName); //Load the default values into the highScores array
  }
  asteroidCreate(3, 60); //setup initial asteroids
  asteroidCreate(2, 30); //smaller initial asteroids
  asteroidCreate(1, 15); //smallest initial asteroids
}

void draw() {
  background(0); //Black
  if (lives < 1) { //If out of lives Game over.
    gameOver(); //Displays the end screen
  }
  if (asteroids.size() == 0) { //If no asteroids left reset the level.
    reset(); //Reset the starting parameters
    levelCount++; //Increment the level count by one after asteroids on screen reaches 0
    lives++; //Increment the players lives by one after asteroids on screen reaches 0
    start = 2; //Remakes asteroids
  }
  switch(start) { //Switch statement to change between menu screens
  case 0:   
    startMenu(); //Draw the start screen
    for (int i = 0; i < asteroids.size(); i++) { //loop through the list of asteroids
      asteroids.get(i).move(); //Make them move
    } 
    break;
  case 1: 
    playerNameMenu(); //Menu for player to enter their name
    break;
  case 2:   
    asteroids.clear(); //Removes the start screen asteroids
    cannons.clear(); //Removes all cannon bullets from screen
    //Switch statement to increase level difficulty up to max level 8, which has 6 starting asteroids with a max speed possible of 3.0
    switch (levelCount) { 
    case 1: 
      asteroidCreate(3, 60); //Creates the games asteroids
      howQuick = 1000;
      break;
    case 2: 
      asteroidCreate(3, 60); //Creates the games asteroids
      maxSpeed += 0.5; //Increases asteroids speed
      howQuick -= 100;
      break;
    case 3: 
      asteroidCreate(4, 60); //Creates the games asteroids
      howQuick -= 100;
      break;
    case 4: 
      asteroidCreate(4, 60); //Creates the games asteroids
      maxSpeed += 0.5; //Increases asteroids speed
      howQuick -= 100;
      break;
    case 5: 
      asteroidCreate(5, 60); //Creates the games asteroids
      break;
    case 6: 
      asteroidCreate(5, 60); //Creates the games asteroids
      maxSpeed += 0.5; //Increases asteroids speed
      howQuick -= 100;
      break;
    case 7: 
      asteroidCreate(6, 60); //Creates the games asteroids
      howQuick -= 100;
      break;
    default: 
      asteroidCreate(6, 60); //Creates the games asteroids
      maxSpeed = 3.0; //Increases asteroids speed
      howQuick -= 100;
      break;
    }
    start++; //Increment start by 1 to ensure no more asteroids are created 
    alienFrames = frameCount;
  case 3:  
    if (lives > 0) {
      ship(); //Displays the triangle ship
      shoot(); //Shoot the cannon bullets
      //For loop to move each asteroid in the array of asteroids.
      for (int i = 0; i < asteroids.size(); i++) {
        asteroids.get(i).move(); //Move function to move the asteroids
        shipCollision(); //Check if ship collides with any asteroid
        cannonCollision(); //Check if the cannon bullets collides with any asteroid
      }
      for (int i = 0; i < cannons.size(); i++) { //Loops through each cannon object
        cannons.get(i).fire(); //Fires the cannon bullets
      }
      if (frameCount < debrisFrames + 30) { //Check to see if debris need to be displayed. Display animation for 30 frames
        for (int d = 0; d < debris.size(); d++) {
          debris.get(d).move(); //Make the debris asteroids move
          debris.get(d).display(); //Display the debris aseroids
        }
      } else {
        debris.clear(); //If they don't need to be displayed wipe the arrayList Buffer.
      }
      if (frameCount < shipFrames + 40) { //Display the ship debris for 40 frames after a ship crash
        sDebris.display();
      }
      if ((frameCount + alienFrames) % 2000 == 0 && frameCount > alienFrames + howQuick) { //Create the alien space ship
        aliens.add(new Alien(width+10, height/2 - 150, radians(270)));
        alienAppear.rewind();
        alienAppear.play();
      }
      if (aliens.size() > 0) { //If there is an alien ship
        if (aliens.get(0).getX() < 0) { //If that alien ship has passed the left side of screen
          aliens.clear(); //Delete the alien ship
        }
      }
      if (aliens.size() > 0) { //If ther is an alien ship
        aliens.get(0).move(); //Make it move
        aliens.get(0).display(); //Display it 
        aliens.get(0).direction(); //Alter the direction
      }
      if (alienCannon.size() > 0) { //If there is alien cannon bullets
        for (int i=0; i < alienCannon.size(); i++) { //Call each bullet in turn
          alienCannon.get(i).display(); //Display each bullet
          alienCannon.get(i).fire(); //Make each bullet move
          //If the bullet is outside screen proportions remove it
          if (alienCannon.get(i).getX() > width || alienCannon.get(i).getX() < 0 || alienCannon.get(i).getY() > height || alienCannon.get(i).getY() < 0) {
            alienCannon.remove(i);
          }
        }
      }
      break;
    }
  case 4: 
    pause();
    break;
  }

  fill(255); //white
  textSize(32); //Set the score text size
  textAlign(LEFT);
  text("SCORE: " + score, 10, 30); //Display score
  textAlign(RIGHT);
  text("SHIPS: " + lives, width-5, 30); //Display lives remaining
}

/**
 This function performs invincibility tests.
 If ship has just spawned, set isInvincible to true, countdown 3s and then set isInvincible to false.
 Related Variables:
 - isInvincible       | Boolean storing whether invincibility is on or off
 - time               | Stores current time in ms
 - tempInvincibility  | Timer for the amount of invincibility in ms
 **/
void invincibilityTimer() {
  if (isInvincible) {
    if (millis() < time + tempInvincibility) {
      isInvincible = true;
    } else {
      isInvincible = false;
    }
  }
}

/**
 This function checks for cannon bullet collission with asteroids.
 **/
void cannonCollision() { 
  float cX = 0; //stores cannon X
  float cY = 0; //stores cannon y
  float aX = 0; //stores asteroid x
  float aY = 0; //stores asteroid y
  
  if(aliens.size() > 0){ //Check to see if there are any aliens     
    for(int i = 0; i < cannons.size(); i++ ){ //for loop, loops through each cannon bullet
    cX = cannons.get(i).getX(); 
    cY = cannons.get(i).getY();
    for(int j = 0; j < aliens.size(); j++){    //for loop, loops through all aliens  
    float aliensX = aliens.get(j).getX(); //Store the X value of the alien ship in a variable
    float aliensY = aliens.get(j).getY(); //Store the Y value of the alien ship in a variable
    
      if(cX <= aliensX + 12.5 && cX >= aliensX - 12.5 && cY <= aliensY + 11 && cY >= aliensY - 11){
        aliens.remove(j); //remove the alien ship that was hit
        cannons.remove(i); //remove the bullet that hit the alien ship
        shipFrames = frameCount; //set frames to intercept frame
        sDebris = new ShipDebris(aliensX, aliensY); //Create new ship debris in position that the ship crashed
        score += 75; //increase score
        alienExplosion.rewind();
        alienExplosion.play();
        }
      }
    }
  }

  for (int j = 0; j < cannons.size(); j++ ) { //for loop, loops through each cannon bullet
    cX = cannons.get(j).getX(); 
    cY = cannons.get(j).getY();
    for (int i = 0; i < asteroids.size(); i++ ) { //for loop, loops through each asteroid
      aX = asteroids.get(i).getX();
      aY = asteroids.get(i).getY();
      if (cX < aX + asteroids.get(i).getSize() && cX > aX - asteroids.get(i).getSize() && cY < aY + asteroids.get(i).getSize() && cY > aY - asteroids.get(i).getSize()) {
        if (asteroids.get(i).getSize() == 60) { //if the asteroid that is shot is a big one create two medium ones at the asteroids current x/y
          debrisFrames = frameCount; //Assign current frame count to debrisFrame for animation control
          for (int p = 0; p < 3; p++) {  //For loop to create three asteroid objects of size 1 that look like asteroid debris
            debris.add(new Asteroid(aX + random(0, 60), aY + random(0, 60), random(-0.25, 0.25), 1));
          }
          asteroidCreate(2, asteroidSize/2, aX, aY);
          asteroids.remove(i); //remove the Asteroid that collided
          cannons.remove(j); //Remove the Cannon that collided
          score += 10; //Increment the score by 10 for a large asteroid
          asteroidExplode.rewind();
          asteroidExplode.play();
          break; //break from for loop after that bullet is removed no point checking against rest of the asteroids.
        } else if (asteroids.get(i).getSize() == 30) { //If the asteroid that is shot is a medium one create two small ones at asteroids current x/y
          debrisFrames = frameCount; //Assign current frame count to debrisFrame for animation control
          for (int p = 0; p < 3; p++) {  //For loop to create three asteroid objects of size 1 that look like asteroid debris
            debris.add(new Asteroid(aX + random(0, 30), aY + random(0, 30), random(-0.25, 0.25), 1));
          }
          asteroidCreate(2, asteroidSize/4, aX, aY); 
          score += 25; //Increment the score by 25 for a medium asteroid
          asteroidExplode.rewind();
          asteroidExplode.play();          
          asteroids.remove(i); //remove the Asteroid that collided
          cannons.remove(j); //Remove the Cannon that collided
          break; //break from for loop after that bullet is removed no point checking against rest of the asteroids.
        } else if (asteroids.get(i).getSize() == 15) { //If the asteroid that is shot is the smallest one remove it all together
          debrisFrames = frameCount; //Assign current frame count to debrisFrame for animation control
          for (int p = 0; p < 3; p++) {  //For loop to create three asteroid objects of size 1 that look like asteroid debris
            debris.add(new Asteroid(aX + random(0, 15), aY + random(0, 15), random(-0.25, 0.25), 1));
          }
          score += 50; //Increment the score by 50 for a small asteroid
          asteroidExplode.rewind();
          asteroidExplode.play();          
          asteroids.remove(i); //remove the Asteroid that collided
          cannons.remove(j); //Remove the Cannon that collided
          break; //break from for loop after that bullet is removed no point checking against rest of the asteroids.
        }
      }
    }
  }
}

/**
 This function checks for ship collission with asteroids.
 **/
void shipCollision() {
  invincibilityTimer(); //Check for invincibility
  if (!isInvincible) {
    if(aliens.size() > 0){ //Check to see if the national guard has been called      
      for(int i = 0; i < aliens.size(); i++){ //For every alien that exists      
      float aliensX = aliens.get(i).getX(); //Store the X value of the alien ship in a variable
      float aliensY = aliens.get(i).getY(); //Store the Y value of the alien ship in a variable
        if(shipX <= aliensX + 12.5 && shipX >= aliensX - 12.5 && shipY <= aliensY + 11 && shipY >= aliensY - 11){
          shipFrames = frameCount; //Frame counter for ship debris
          sDebris = new ShipDebris(shipX, shipY); //Create new ship debris in position that the ship crashed
          reset(); //reset the starting parameters
          cannons.clear(); //Remove all cannon bullets after ship crash
          lives--; //Reduce the amount of ships remaining by one
          time = millis(); //Set point in time equal to elapsed time at point of collision
          isInvincible = true; //Set invincibility to true
          shipExplosion.rewind();
          shipExplosion.play();
        }
      }
      for(int j = 0; j < alienCannon.size(); j++){ //For every alien bullet (j used to prevent confusion, or add to it)
      //println("Alien Cannon: ", alienCannon.get(j).getX());
      //println("Alien Cannon: ", alienCannon.get(j).getY());
      float alienBulletX = alienCannon.get(j).getX();
      float alienBulletY = alienCannon.get(j).getY();
      
        if(shipX + 20 >= alienBulletX  && shipX - 20 <= alienBulletX && shipY + 20 >= alienBulletY && shipY - 20 <= alienBulletY ){
          println("Bitch got hit");
          shipFrames = frameCount; //Frame counter for ship debris
          sDebris = new ShipDebris(shipX, shipY); //Create new ship debris in position that the ship crashed
          reset(); //reset the starting parameters
          cannons.clear(); //Remove all cannon bullets after ship crash
          lives--; //Reduce the amount of ships remaining by one
          time = millis(); //Set point in time equal to elapsed time at point of collision
          isInvincible = true; //Set invincibility to true
          shipExplosion.rewind();
          shipExplosion.play();          
        }
      }
    }
    for (int i = 0; i < asteroids.size(); i++) { //Loop through all asteroids to check if the collide with the ship
      float aX = 0; //asteroid x coordinate
      float aY = 0; //asteroid y coordinate

      aX = asteroids.get(i).getX(); //get the x-coordinate of each asteroid and store here
      aY = asteroids.get(i).getY(); //get the y-coordinate of each asteroid and store here

      //Logical statement to check if the x and y of the ship are close enough to the x and y of the asteroid to make a collission
      if (shipX < aX + asteroids.get(i).getSize() && shipX > aX - asteroids.get(i).getSize() && shipY < aY + asteroids.get(i).getSize() && shipY > aY - asteroids.get(i).getSize()) {
        //reset the ship to starting position
        shipFrames = frameCount; //Frame counter for ship debris
        sDebris = new ShipDebris(shipX, shipY); //Create new ship debris in position that the ship crashed
        reset(); //reset the starting parameters
        if (asteroids.get(i).getSize() == 60) { //if the asteroid that collides is a big one create two medium ones at the asteroids current x/y
          debrisFrames = frameCount; //Assign current frame count to debrisFrame for animation control
          for (int p = 0; p < 3; p++) {  //For loop to create three asteroid objects of size 1 that look like asteroid debris
            debris.add(new Asteroid(aX + random(0, 60), aY + random(0, 60), random(-0.25, 0.25), 1));
          }
          asteroidCreate(2, asteroidSize/2, aX, aY); //Create two medium asteroids
          asteroids.remove(i); //remove the asteroid that collided
        } else if (asteroids.get(i).getSize() == 30) { //If the asteroid that collides is a medium one create two small ones at asteroids current x/y
          debrisFrames = frameCount; //Assign current frame count to debrisFrame for animation control
          for (int p = 0; p < 3; p++) {  //For loop to create three asteroid objects of size 1 that look like asteroid debris
            debris.add(new Asteroid(aX + random(0, 30), aY + random(0, 30), random(-0.25, 0.25), 1));
          }
          asteroidCreate(2, asteroidSize/4, aX, aY); //Create two small asteroids
          asteroids.remove(i); //Remove the medium asteroid
        } else if (asteroids.get(i).getSize() == 15) { //If the asteroid is the smallest one remove it all together
          debrisFrames = frameCount; //Assign current frame count to debrisFrame for animation control
          for (int p = 0; p < 3; p++) {  //For loop to create three asteroid objects of size 1 that look like asteroid debris
            debris.add(new Asteroid(aX + random(0, 15), aY + random(0, 15), random(-0.25, 0.25), 1));
          }
          asteroids.remove(i); //Remove the small asteroid
        }
        cannons.clear(); //Remove all cannon bullets after ship crash
        lives--; //Reduce the amount of ships remaining by one
        time = millis(); //Set point in time equal to elapsed time at point of collision
        isInvincible = true; //Set invincibility to true
        shipExplosion.rewind();
        shipExplosion.play();        
      }
    }
  }
}

/**
 Function draws the start screen.
 **/
void startMenu() {
  textAlign(CENTER);
  fill(255);
  textSize(64);
  text("ASTEROIDS", width/2, 250);
  textSize(32);
  text("PLAY GAME", width/2, 325);

  //Displays the top three high scores 
  text("HIGH SCORES", width/2, 400);
  textSize(25);
  try {
    text(highScores[0] + highScores[1], width/2, 440);
    text(highScores[2] + highScores[3], width/2, 480);
    text(highScores[4] + highScores[5], width/2, 520);
  }
  //Error catcher, if the HighScores.txt file exists but contains no data, wrtie the default data
  catch(ArrayIndexOutOfBoundsException e) { 
    f = createWriter(dataPath(fileName)); //Initilise a createWriter to write to the text file
    //Default high score values
    f.println("Player 1: "); 
    f.println("0");
    f.println("Player 2: ");
    f.println("0");
    f.println("Player 3: ");
    f.println("0");
    f.flush();
    f.close();
    highScores = loadStrings(fileName); //Load the default values into the highScores array
  }
}

/**
 Function draws the screen for the user to input their name
 **/
void playerNameMenu() {
  textAlign(CENTER);
  fill(255);
  textSize(64);
  text("Enter Your Name", width/2, 250);
  textSize(32);
  text("Name: " + playerName, width/2, 325);
}

/**
 Function draws the end screen and checks to see if a high score has been made
 **/
void gameOver() {
  textAlign(CENTER);
  textSize(64);
  text("GAME OVER", width/2, 300);
  textSize(32);
  text("RESET", width/2, 450);
  levelCount = 1; //Restart level count
  maxSpeed = 1; //Reset maxSpeed of asteroids
  if (highScore == 1) { //If user achieved a high score display HIGH SCORE!! flashing
    textSize(45);
    if (frameCount % 2 == 0) { //Display every second frame to create flashing effect
      text("HIGH SCORE!!", width/2, 385);
    }
  }
  while (score > 0) { //While loop to check for high scores, reset once high score added
    if (score > int(highScores[1])) { //Check to see if top score reached
      highScores[5] = highScores[3]; //Assign the second high score to the third high score
      highScores[4] = highScores[2]; //Assign the second high score name to the third high score name
      highScores[3] = highScores[1]; //Assign the current high score to the third high score
      highScores[2] = highScores[0]; //Assign the current high score name to the third high score name
      highScores[1] = Integer.toString(score); //Assign the new high score to high score
      highScores[0] = playerName + ": "; //Assign the playerName to the new high score
      highScore = 1; //Reset highScore to one for next game
      score = 0; //Reset score to escape from while loop
    } else if (score > int(highScores[3])) { //Check to see if second highest score reached
      highScores[5] = highScores[3]; //Assign the second high score to the third high score
      highScores[4] = highScores[2]; //Assign the second high score name to the third high score name
      highScores[3] = Integer.toString(score); //Assign the new high score to the second high score
      highScores[2] = playerName + ": "; //Assign the playerName to the new second high score
      highScore = 1; //Reset highScore to one for next game
      score = 0; //Reset score to escape from while loop
    } else if (score > int(highScores[5])) { //Check to see if third highest score reached
      highScores[5] = Integer.toString(score); //Assign the new high score to the third high score
      highScores[4] = playerName + ": "; //Assign the playerName to the new third high score
      highScore = 1; //Reset highScore to one for next game
      score = 0; //Reset score to escape from while loop
    }
    //Write the high scores to the text file "HighScores.txt"
    f = createWriter(dataPath(fileName));
    f.println(highScores[0]);
    f.println(highScores[1]);
    f.println(highScores[2]);
    f.println(highScores[3]);
    f.println(highScores[4]);
    f.println(highScores[5]);
    f.flush();
    f.close();
  }
}  

/**
 This Function draws the pause screen
 **/
void pause() {
  if (pauseInt == 1) { //If pauseInt == 1 display pause screen
    fill(255);
    textSize(64);
    textAlign(CENTER);
    text("PAUSED", 300, 350);
    textSize(100);
    text("II", 300, 250);
  }
}

/**
 This function resets starting parameters.
 **/
void reset() {
  cannons.clear();
  alienCannon.clear();
  aliens.clear();
  shipX = width/2; 
  shipY = height/2;
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
  if (mouseX > (width/2 - 100) && mouseX < (width/2+100) && mouseY< 400 && mouseY > 225 && start == 0) { //Start Screen
    start = 1;
  }
  if (mouseX > (width/2 - 100) && mouseX < (width/2 + 100) && mouseY< 500 && mouseY > 400 && lives < 1) { //Game Over Screen
    start = 0;
    score = 0;
    lives = 3;
    reset(); //Reset starting parameters
    highScore = 0; //Reset high score
  }
}

/**
 Function checks for key presses
 **/
void keyPressed() {
  int pauseFrames = 0;
  buttonPressed[keyCode] = true; //Assign true to the key that has been pressed

  //On the player name screen take the input and assign it to playerName variable
  if (keyCode == BACKSPACE && start == 1) { //deal with backspace
    if (playerName.length() > 0) {
      playerName = playerName.substring(0, playerName.length()-1);
    }
  } else if (keyCode == DELETE && start == 1) { //deal with delete
    playerName = "";
  } else if (keyCode != SHIFT && keyCode != CONTROL && keyCode != ALT && keyCode != ENTER && keyCode != RETURN && start == 1) {
    playerName = playerName + key; //Assign the name typed to player name
  }
  if (keyCode == ENTER && start == 1) { //Once the user presses enter start the game
    start = 2;
  }
  if (key == 'p' && start == 3) { //Use p key to pause the game
    pauseFrames = frameCount;
    pauseInt = 1; //pauseInt to 1 to display the pause screen
    start = 4; //Start to 4 then switch case will call the pause() function
    pause(); //Call pause aswell to ensure it happen quickly
  } else if (key == 'p' && start == 4) { //Use p key to unpause the game
    alienFrames = pauseFrames;
    start = 3; //Back to gameplay
    pauseInt = 0; //Game not paused
  }
}

/**
 Function checks for key releases
 **/
void keyReleased() {
  buttonPressed[keyCode] = false; //Asign false to the key when the key is released
  if(key == UP){
    shipThrust3.pause();
  }
}

/**
 Function displays the cannon bullets
 **/
void shoot() {
  if (buttonPressed[' '] && frameCount - frames > 15 && lives > 0) { //If the space key is pressed and it has been more than 15 frames (i.e fire rate) do this
    shipLaser.rewind();
    shipLaser.play();
    frames = frameCount; //Stores the current frameCount
    cannons.add(new Cannon(shipX, shipY, shipAngle + radians(90), 1)); //Create new cannon object
    for (int i = 0; i < cannons.size(); i++) { //For loop to display each cannon object
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
    //Each asteroid has a random x and y starting co-ordinate between that is between 0 and width, 
    //but 120 away from the ship in x and y, and a random speed between -2,2 
    asteroids.add(new Asteroid(aX, aY, random(-maxSpeed, maxSpeed), size2));
  }
}

/**
 Function creates asteroids for start screen and initial game play.
 **/
void asteroidCreate(int amountOfAsteroids, int sizeOfAsteroids) { //Accepts an amount and size of asteroids required.
  int a = amountOfAsteroids; //How many asteroids to make
  int size2 = sizeOfAsteroids; //The size of the asteroids
  //Create the initial asteroids inside an array
  for (int i = 0; i < a; i++) {
    //Each asteroid has a random x and y starting co-ordinate that is between 0 and width, but 120 away from the ship 
    //in x OR y, and a random speed between -maxSpeed and maxSpeed
    int x1 = int(random(0, shipX-120));
    int x2 = int(random(shipX+120, width));
    int y1 = int(random(0, shipY-120));
    int y2 = int(random(shipY+120, height));
    int[] randints = { x1, x2, y1, y2 };
    // Randomly selects one of the position constraints above
    int index = int(random(randints.length));
    int xy = randints[index];
    //if /else if condition for allowing more possible asteroid positions
    if (xy == x1 || xy == x2) {
      int x = xy;
      int y = int(random(0, height));
      asteroids.add(new Asteroid(x, y, random(-maxSpeed, maxSpeed), size2));
    } else if (xy == y1 || xy == y2) {
      int y = xy;
      int x = int(random(0, width));
      asteroids.add(new Asteroid(x, y, random(-maxSpeed, maxSpeed), size2));
    }
  }
}

/**
 Function draws the ship triangle and allows for rotation
 **/
void ship() {
  sSpeedX *= drag; //Slow the ship based on drag co-efficient
  sSpeedY *= drag; //Slow the ship based on drag co-efficient

  shipX += sSpeedX; //Move the ship based on current speed
  shipY += sSpeedY; //Move the ship based on current speed

  //This code will move the ship to opposite side if it reaches the boundaries    
  if (shipX > width + 10) 
    shipX = -10;
  else if (shipX < -10) 
    shipX = width + 10;
  if (shipY > height + 20) 
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
    if(!shipThrust3.isPlaying()){ 
      shipThrust3.rewind();
      shipThrust3.play();
    }
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
  if (buttonPressed[UP]) {
    //Draw the ship flames out the tail (rocket engines)
    noStroke();
    fill(255, random(0, 255), 0, random(0, 255)); 
    ellipse(0, -14, random(0, 7), random(2, 12));
  }
  popMatrix();
}

/**
 ShipDebris class displays crash annimation for ship
 **/
class ShipDebris {
  float x;
  float y;

  /**
  Ship constructor method accepts x and y coorindates input of where crash occured
  **/
  ShipDebris(float dX, float dY) {
    x = dX;
    y = dY;
  }

  /**
   This method displays random lines in vacinity of crash site to represent ship debris
   **/
  void display() {
    strokeWeight(2);
    stroke(255);
    fill(255);
    line(random(x-5, x+5), random(y-10, y+10), random(x-10, x+10), random(y-10, y+10)); 
    line(random(x-5, x+5), random(y-10, y+10), random(x-10, x+10), random(y-10, y+10)); 
    line(random(x-5, x+5), random(y-10, y+10), random(x-10, x+10), random(y-10, y+10));
  }
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
   Display method draws the cannon bullet
   **/
  void display() {
    stroke(255);
    strokeWeight(size); //Size of the cannon bullet
    point(x, y); //Draws teh cannon bullet
  }

  /**
  The fire method moves the cannon bullet in the direction the ship was pointing
  **/
  void fire() { 
    x += (speed * cos(angle) * 5); //Change the x co-ordinate based on speed
    y += (speed * sin(angle) * 5); //Change the y co-ordinate based on speed
    display(); //Calls to display after moving x and y
  }

  /**
   The getX method returns the cannon bullets x
   **/
  float getX() {
    return x;
  }

  /**
  The getY method returns the cannon bullets y
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
  int n = round(random(0, 1));

  /**
  The Asteroid constructor method accepts x, y coordinate variables +
  the speed of the asteroids and the size of the asteroids
  **/
  Asteroid(float ax, float ay, float aSpeed, int aSize) {
    x = ax; //stores the x co-ordinate of the asteroid
    y = ay; //stores the y co-ordinate of the asteroid
    speed = aSpeed; //stores the speed of the asteroid, each is different
    size = aSize; //stores the size of the asteroid

    //Sets the rotation speed of the asteroids to half the speed
    if (speed == 0) { 
      rotSpeed = 0;
    } else {
      rotSpeed = speed/2;
    }

    //The following lines of code create the shape of the asteroid using a PShape
    a = createShape();
    a.beginShape();
    a.noFill(); //Tranparent
    a.strokeWeight(0.5);
    a.stroke(255); //White outline
    //For loop creates verticies randomly to create asteroid like shape, each time the program loads the asteroid will look different
    for (float i=0; i<TWO_PI; i=i+PI/(random(3, 10))) {
      a.vertex(random(size*0.8, size)*cos(i), random(size*0.8, size)*sin(i));
    }
    a.endShape(CLOSE);
  }

  /**
  The move method moves the asteroid based on its speed
  **/
  void move() {
    if (n ==0) {
      x += speed; //Change the x co-ordinate based on speed
      y -= speed; //Change the y co-ordinate based on speed
    } else if (n == 1) {
      x += speed;
      y += speed;
    }    
    a.rotate(radians(rotSpeed));
    display(); //Calls to display after moving x and y
  }

  /**
   The display() method ensures the asteroid is within the defined boundaries and then draws the asteroid.
   **/
  void display()
  {
    fill(0);
    //The following if statements ensure the asteroid is within the screen if not it will rejoin the other side.
    if (x < (0 - (size/2))) {
      x = width + (size/2);
    }
    if (x > (width + (size/2))) {
      x = (0 - (size/2));
    }
    if (y < (0 - (size/2))) { 
      y = height + (size/2);
    }
    if (y > (height + (size/2))) {
      y = (0 - (size/2));
    }
    shape(a, x, y); //draw the PShape (asteroid)
  }

  /**
   This method returns the current x co-ordinate of the asteroid
   **/
  float getX() {
    return x;
  }

  /**
   This method returns the current y co-ordinate of the asteroid
   **/
  float getY() {
    return y;
  }

  /**
   This method returns the current size of the asteroid
   **/
  int getSize() {
    return size;
  }
}

/**
Alien Class creates alien ship objects (enemy).
**/
class Alien {
  PShape aS;
  float x; //Alien ship x-coordinate
  float y; //Alien ship y-coordinate
  float speed = 1; //Alien ship speed variable
  float angle = radians(180); //Alien ship movement direction
  float distance = 0; //Stores the distance the alien ship has travelled
  float cannonTiming = 0; //Stores the distance to see when next cannon bullet fires
  float t1; //Temp variable for calculating distance for cannon timing
  float t2; //Temp variable for calculating distance for cannon timing

  /** 
  Constructor method for default alien object
  **/
  Alien() {
    x = width +10; //Alien ship starts at width + 10 x
    y = 100;
  }

  /**  
  Overloaded constructor accepts new x and y variable coordinates
  **/
  Alien(float ax, float ay) {
    x = ax;
    y = ay;
  }

  /**
  Overloaded constructor accepts new x and y variable coordinates and new start angle
  **/
  Alien(float ax, float ay, float aAngle) {
    x = ax;
    y = ay;
    angle = aAngle;
  }

  /** 
  The direction method changes the alien ship direction when it has moved at 
  least 1/4 of the width of the screen
  **/
  void direction() {
    if (distance > width / 4) {
      angle = -radians(random(0, 180));
      distance = 0;
    }
  }

  /**
  The move method moves the alien ship and creates the cannon bullets after certain distance
  **/
  void move() {
    x += (speed * cos(angle + radians(270))); //Change the x co-ordinate based on speed
    y += (speed * sin(angle + radians(270))); //Change the y co-ordinate based on speed
    //Constrict y movement of the alien ship to on screen parameters
    if (y < 10) { 
      y = 10;
    }
    if (y > height - 10) {
      y = height - 10;
    }
    //Used to calculate the distance travelled by the alien ship
    t1 = (speed * cos(angle + radians(270))); 
    t2 = (speed * sin(angle + radians(270)));
    //Pythagoras' theorem
    distance += sqrt(t1 * t1 + t2 * t2); 
    cannonTiming += sqrt(t1 * t1 + t2 * t2);

    if (cannonTiming > width /10) { //Cannon fire rate is every 1/10 the width of the screen
      //Change the direction to fire the alien bullets based on which quadrant the alien ship is in
      //Fire at the opposite quadrant
      if (y < height/2) {
        if (x > width/2) {
          alienCannon.add(new Cannon(x, y, radians(110), 4));
          alienFire.rewind();
          alienFire.play();          
        } else {
          alienCannon.add(new Cannon(x, y, radians(60), 4));
          alienFire.rewind();
          alienFire.play();
        }
      } else {
        if (x > width/2) {
          alienCannon.add(new Cannon(x, y, -radians(110), 4));
          alienFire.rewind();
          alienFire.play();          
        } else {
          alienCannon.add(new Cannon(x, y, -radians(60), 4));
          alienFire.rewind();
          alienFire.play();          
        }
      }
      cannonTiming = 0; //Reset the distance variable
    }
  }

  /** 
  The display method displays the 2 ellipses that make up the alien space ship graphic
  **/
  void display() {
    stroke(255);
    strokeWeight(0.5);
    fill(255);
    ellipse(x, y, 10, 7);
    noFill();
    ellipse(x, y+2, 25, 13);
  }
  
  /**
  Method to return the x-coordinate of the alien ship
  **/
  float getX() {
    return x;
  }
  
  /**
  Method to return the x-coordinate of the alien ship
  **/
  float getY() {
    return y;
  }
}
