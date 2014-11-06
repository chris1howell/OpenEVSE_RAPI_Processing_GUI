import processing.serial.*;
Serial myPort;  // Create object from Serial class
//int val;      // Data received from the serial port
String rx;

//Image Definitions
PImage check_yes;   //image background
PImage check_no;   //image battery
PImage save_serial; //Save Image
PImage logo;   //image logo
PImage RGB_LCD;
PImage Mono_LCD;
PImage led_on;
PImage led_off;

//Font Definitions
PFont fontA; //Main font

//Element Definitions
boolean check_Ground = true;
boolean check_GFCI = true;
boolean check_Diode = true ;
boolean check_Vent = true;
boolean check_Relay = true;
boolean save_val = false;
boolean LCD_is_RGB = true;
boolean tx_led = false;
boolean rx_led = false;
int icon_size = 50;
int current_X = 15;
int settings_X = 280;
int check_X = (settings_X + 190);
int check_Ground_Y = 140;
int check_GFCI_Y = (check_Ground_Y + icon_size);
int check_Diode_Y = (check_Ground_Y + (2*icon_size));
int check_Vent_Y = (check_Ground_Y + (3*icon_size));
int check_Relay_Y = (check_Ground_Y + (4*icon_size));
int save_X = check_X;
int save_Y = 470;
int tx_led_X = (check_X - 35);
int rx_led_X = (check_X + 25);
int led_Y = 415;
int led_size = 25;
int logo_X = 5;
int logo_Y = 480;
int logo_W = 180;
int logo_H = 75;
int state_X = 240;
int state_Y = 60;

int debounce = 500;
int press = 0;

//OpenEVSE Settings
int DEFAULT_SERVICE_LEVEL = 2; // 1=L1, 2=L2

// Default capacity in amps
int DEFAULT_CURRENT_CAPACITY_L1 = 12;
int DEFAULT_CURRENT_CAPACITY_L2 = 30;

// MIN/MAX allowable current in amps
int MIN_CURRENT_CAPACITY = 6;
int MAX_CURRENT_CAPACITY_L1 = 16; // J1772 Max for L1 on a 20A circuit
int MAX_CURRENT_CAPACITY_L2 = 80; // J1772 Max for L2

int EVSE_STATE = 3;
int amp = 30;
int svc = 2;




void setup() 
{
  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 115200);
  
  size(540,580);
  frameRate(30);
  

  check_yes = loadImage("check_yes.png");
  check_no = loadImage("check_no.png");
  logo = loadImage("OpenEVSE_logo.jpg");
  save_serial = loadImage("filesave.png");
  RGB_LCD = loadImage("RGB_LCD.jpg");
  Mono_LCD = loadImage("Mono_LCD.jpg");
  led_on = loadImage("led_on.png");
  led_off = loadImage("led_off.png");

  fontA = loadFont("CharterBT-Roman-48.vlw");
  

}


void check_box (boolean checked, int check_y) {
  if (checked == true){
    image(check_yes, check_X, check_y, icon_size, icon_size);
  }
    else {
    image(check_no, check_X, check_y, icon_size, icon_size);
    }
}


void draw() 
{
background(255, 255, 255);
image(logo, logo_X, logo_Y, logo_W, logo_H);

 
fill(100,100,100);
textFont(fontA, 35);
text("EVSE State:", 30, 60);
textFont(fontA, 25);
fill(0);
text("L1 - Current", current_X, (check_Ground_Y + (icon_size / 2)));
text("L2 - Current", current_X, (check_Ground_Y + (icon_size / 2) + 75));




text(DEFAULT_CURRENT_CAPACITY_L1, (current_X + 180), (check_Ground_Y + (icon_size / 2)));
text(DEFAULT_CURRENT_CAPACITY_L2, (current_X + 180), (check_Ground_Y + (icon_size / 2)+ 75));

textFont(fontA, 20);
fill(100,100,100);
text("Min - Max", current_X, (check_Ground_Y + (icon_size / 2) + 100));
text("Min - Max", current_X, (check_Ground_Y + (icon_size / 2) + 25));
text(MIN_CURRENT_CAPACITY, (current_X + 150), (check_Ground_Y + (icon_size / 2) + 25));
text("-", (current_X + 170), (check_Ground_Y + (icon_size / 2) + 25));
text(MAX_CURRENT_CAPACITY_L1, (current_X + 180), (check_Ground_Y + (icon_size / 2) + 25));
text(MIN_CURRENT_CAPACITY, (current_X + 150), (check_Ground_Y + (icon_size / 2) + 100));
text("-", (current_X + 170), (check_Ground_Y + (icon_size / 2) + 100));
text(MAX_CURRENT_CAPACITY_L2, (current_X + 180), (check_Ground_Y + (icon_size / 2) + 100));

fill(0);
textFont(fontA, 25);
text("Ground Check", settings_X, (check_Ground_Y + (icon_size / 2)));
text("GFCI", settings_X, (check_GFCI_Y + (icon_size / 2)));
text("Diode Check", settings_X, (check_Diode_Y + (icon_size / 2)));
text("Vent Required", settings_X, (check_Vent_Y + (icon_size / 2)));
text("Stuck Relay", settings_X, (check_Relay_Y + (icon_size / 2)));
text("Save Settings", settings_X, (save_Y + (icon_size / 2)));

textFont(fontA, 15);
text("OpenEVSE Configuration Tool v1.0", 240, 560);
text("TX", 410, 435);
text("RX", 470, 435);

//Check Boxes  
    
check_box (check_Ground, check_Ground_Y);  
check_box (check_GFCI, check_GFCI_Y);
check_box (check_Diode, check_Diode_Y);
check_box (check_Vent, check_Vent_Y);
check_box (check_Relay, check_Relay_Y);

image(save_serial, save_X, save_Y, icon_size, icon_size);
 
if (LCD_is_RGB == true){  
  image(RGB_LCD, (check_X - 40), (check_Ground_Y - 100), 100, 45); 
  }
if (LCD_is_RGB == false){  
  image(Mono_LCD, (check_X - 40), (check_Ground_Y - 100), 100, 45); 
  }
  
if (tx_led == true){  
  image(led_on, tx_led_X, led_Y, led_size, led_size);
  tx_led = false;
}
  else { 
  image(led_off, tx_led_X, led_Y, led_size, led_size);
  }

if (rx_led == true){  
  image(led_on, rx_led_X, led_Y, led_size, led_size);
  rx_led = false;
}
   else  {
  image(led_off, rx_led_X, led_Y, led_size, led_size);
  }


  
if (mouseX >= check_X && mouseX <= (check_X + icon_size) && mouseY >= check_Ground_Y && mouseY < (check_Ground_Y + icon_size) && mousePressed){
  if (check_Ground == true && millis() - press >= debounce){
    check_Ground = false ;
    myPort.write("$SG 0*0E\r");
    tx_led = true;
    press = millis();
   } 
  else if (check_Ground == false && millis() - press >= debounce){
    check_Ground = true ;
    myPort.write("$SG 1*0F\r");
    tx_led = true;
    press = millis();    
  } 
 }
if (mouseX >= check_X && mouseX <= (check_X + icon_size) && mouseY >= check_GFCI_Y && mouseY < (check_GFCI_Y + icon_size) && mousePressed){
  if (check_GFCI == true && millis() - press >= debounce){
    check_GFCI = false ;
    press = millis();
    myPort.write("$SS 0*1A\r");
    tx_led = true;
   } 
  else if (check_GFCI == false && millis() - press >= debounce){
    check_GFCI = true ;
    press = millis();
    myPort.write("$SS 1*1B\r"); 
    tx_led = true;  
  } 
 } 
 if (mouseX >= check_X && mouseX <= (check_X + icon_size) && mouseY >= check_Diode_Y && mouseY < (check_Diode_Y + icon_size) && mousePressed){
  if (check_Diode == true && millis() - press >= debounce){
    check_Diode = false ;
    myPort.write("$SD 1*0C\r"); 
    tx_led = true;
    press = millis();
   } 
  else if (check_Diode == false && millis() - press >= debounce){
    check_Diode = true ;
    myPort.write("$SD 0*0B\r");
    tx_led = true;
    press = millis();    
  } 
 }
 if (mouseX >= check_X && mouseX <= (check_X + icon_size) && mouseY >= check_Vent_Y && mouseY < (check_Vent_Y + icon_size) && mousePressed){
  if (check_Vent == true && millis() - press >= debounce){
    check_Vent= false ;
    myPort.write("$SV 0*1D\r");
    press = millis();
    tx_led = true;
   } 
  else if (check_Vent == false && millis() - press >= debounce){
    check_Vent = true ;
    myPort.write("$SV 1*1E\r");
    press = millis();
    tx_led = true;    
  } 
 } 
  if (mouseX >= check_X && mouseX <= (check_X + icon_size) && mouseY >= check_Relay_Y && mouseY < (check_Relay_Y + icon_size) && mousePressed){
  if (check_Relay == true && millis() - press >= debounce){
    check_Relay= false ;
    myPort.write("$SR 0*19\r");
    
    press = millis();
    tx_led = true;
   } 
  else if (check_Relay == false && millis() - press >= debounce){
    check_Relay = true ;
    press = millis(); 
    myPort.write("$SR 1*1A\r"); 
    tx_led = true;  
  } 
 }
  if (mouseX >= save_X && mouseX <= (save_X + icon_size) && mouseY >= save_Y && mouseY < (save_Y + icon_size) && mousePressed){
    image(save_serial, (save_X + 2), (save_Y + 2), icon_size, icon_size);
    
    if (save_val  == false && millis() - press >= debounce){
      save_val = true;
      press = millis();
      tx_led = true;
  }
 }
 if (mouseX >= logo_X && mouseX <= (logo_X + logo_W) && mouseY >= logo_Y && mouseY < (logo_Y + logo_H) && mousePressed){
 link("https://code.google.com/p/open-evse/");
 }
if (mouseX >= (check_X - icon_size) && mouseX <= (check_X + icon_size) && mouseY >= 50 && mouseY < 100 && mousePressed){
  if (LCD_is_RGB == true && millis() - press >= debounce){
    LCD_is_RGB = false ;
    myPort.write("$S0 0*F7\r");
    press = millis();
    tx_led = true;
   } 
  else if (LCD_is_RGB == false && millis() - press >= debounce){
    LCD_is_RGB = true ;
    myPort.write("$S0 1*F8\r");
    press = millis(); 
    tx_led = true;   
  } 
 }


fill(45);
textFont(fontA, 36);
if (EVSE_STATE == 0){  
  text("Unknown", state_X, state_Y);
}

if (EVSE_STATE == 1){  
  text("Ready", state_X, state_Y);
  text("L", (state_X), (state_Y + icon_size));
  text(svc, (state_X + 20), (state_Y + icon_size));
  text("-", (state_X + 45), (state_Y + icon_size));
  text(amp, state_X + 60, (state_Y + icon_size));
  text("A", (state_X + 100), (state_Y + icon_size));
}

if (EVSE_STATE == 2){  
  text("Connected", state_X, state_Y);
  text("L", (state_X), (state_Y + icon_size));
  text(svc, (state_X + 20), (state_Y + icon_size));
  text("-", (state_X + 45), (state_Y + icon_size));
  text(amp, state_X + 60, (state_Y + icon_size));
  text("A", (state_X + 100), (state_Y + icon_size));
}

if (EVSE_STATE == 3){  
  text("Charging", state_X, state_Y);
  text("L", (state_X), (state_Y + icon_size));
  text(svc, (state_X + 20), (state_Y + icon_size));
  text("-", (state_X + 45), (state_Y + icon_size));
  text(amp, state_X + 60, (state_Y + icon_size));
  text("A", (state_X + 100), (state_Y + icon_size));
} 

if (EVSE_STATE >= 4){  
  text("Error", state_X, state_Y);
  
}

//Read Sreial values 
 if (myPort.available() > 0) {
   rx_led = true; 
   String returnMessage = "";
   String val = myPort.readString();   
 /*  String[] decode = split(val, " ");
     //int decodeLength = decode.length();
     returnMessage = decode[0];
      if (returnMessage.equals("$NK")) {
       }
      else if (returnMessage.equals("$OK")) {
       }
      else if (returnMessage.equals("$ST")) {
        EVSE_STATE = Integer.parseInt(decode[1]);
        }
}     
   */
   
   
   if (val != null) {
      
       if (val.equals("$ST 1\r")) { 
        EVSE_STATE = 1;           
        }
      else if (val.equals("$ST 2\r")) { 
        EVSE_STATE = 2;           
        }  
       else if (val.equals("$ST 3\r")) { 
        EVSE_STATE = 3;         
        }
        else if (val.equals("$ST 4\r")) { 
        EVSE_STATE = 4;          
        }
        else if (val.equals("$ST 5\r")) { 
        EVSE_STATE = 5;           
        }
        else if (val.equals("$ST 6\r")) { 
        EVSE_STATE = 6;           
        }
        else if (val.equals("$ST 7\r")) { 
        EVSE_STATE = 7;          
        }
        //text(val, 200, 200);
        
   }  
}     
}    


  
/*
  if (val == 0x7E) {               //BYTE 1 Header Start Byte for EVSE    
    val = myPort.read();           //BYTE 2 EVSE Current Setting
      if (val >= 6 && val <= 80){  //Allowed values 6A - 80A J1772:2010
        amp = val;                 //set current
      }  
    val = myPort.read();           //BYTE 3 EVSE STATE
      if (val >= 0 && val <= 8){   //Allowed values 0x00 - 0x08 OpenEVSE
         EVSE_STATE = val;         //set EVSE state
      }
     val = myPort.read();          //BYTE 4 EVSE Service level
     if (val >= 0 && val <= 4){    //Allowed Values 0 - 4 OpenEVSE
        svc = val;                 //set EVSE service level
      } 
      
   }


*/

