int car1Position = 550;
int car2Position = 550;
int car3Position = 550;
int car4Position = 550;
int start = 0;
int go = 0;

boolean finished = false;
String result;
void setup(){
   size(400, 600); 
   smooth();
   trafficLights(0);
   
}

void draw(){
  background(255);
  trafficLights(start);
   
  if(start == 0) {
    stroke(0);
    fill(0);
    text("Click to start race!", 5, 300);
  }
  
  drawRoad();
  drawCar(120,car1Position);
  drawCar(165,car2Position);
  drawCar(210,car3Position);
  drawCar(255,car4Position);
  if(go == 1){
    drawCar(120,car1Position);
    drawCar(165,car2Position);
    drawCar(210,car3Position);
    drawCar(255,car4Position);
    if(finished == false){
      car1Position = car1Position - int(random(1.0,3.0));
      car2Position = car2Position - int(random(1.0,3.0));
      car3Position = car3Position - int(random(1.0,3.0));
      car4Position = car4Position - int(random(1.0,3.0));
    
      if (car1Position <= 20 ){
         finished = true;
         result = "Car 1 has won!";
      }else if (car2Position <= 20){
       result = "Car 2 has won!";
       finished = true; 
      }else if (car3Position <= 20){
        result = "Car 3 has won!";
        finished = true;
      }else if (car4Position <= 20){
        result = "Car 4 has won!";
        finished = true;
      }
    }else{
       fill(255,0,0);
       text(result,5,15); 
    }
  }
}
void drawRoad(){
  fill(50);
  noStroke();
  rect(105, 0, 185,600);
  stroke(255);
  strokeWeight(4);
  line(152,0,152,600);
  line(197,0,197,600);
  line(242,0,242,600);
  
}
void drawCar(int x, int y){
  stroke(0);
  strokeWeight(1);
  fill(0);
  rect(x-5, y+5, 30, 10);
  rect(x-5, y+25, 30, 10);
  fill(255,0,0);
  rect(x, y, 20, 40);
  fill(0,0,255);
  ellipse(x+10, y+30,10,5);
  ellipse(x+10, y+15,10,15);  
}

void trafficLights(int a){
  int lights = a;
  if (lights < 1) {
    stroke(0);
    fill(0);
    rect(320,20,60,160); //blackbackground
    fill(204,24,48);
    ellipse(350,50, 40, 40); //red
    fill(244, 252, 83, 40);
    ellipse(350,100, 40, 40); //yellow
    fill(10,237,2,40);
    ellipse(350,150, 40, 40); //green
  }
  if (lights >= 1) {
    fill(0);
    rect(320,20,60,160); //blackbackground
    fill(204,24,48,40);
    ellipse(350,50, 40, 40); //red
    fill(244, 252, 83);
    ellipse(350,100, 40,40); //yellow
    fill(10,237,2,40);
    ellipse(350,150, 40, 40);
    if(millis() > 2000) {
    stroke(0);
    fill(0);
    rect(320,20,60,160); //blackbackground
    fill(204,24,48, 40);
    ellipse(350,50, 40, 40); //red
    fill(244, 252, 83, 40);
    ellipse(350,100, 40, 40); //yellow
    fill(10,237,2);
    ellipse(350,150,40,40); //green
    go = 1;
    }
  }
}

void mouseClicked() {
    if(mouseButton == LEFT) {
      start = 1;
   }
}