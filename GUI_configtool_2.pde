import processing.serial.*;
Serial myPort;  // Create object from Serial class
int val;      // Data received from the serial port

//Image Definitions
PImage check_yes;   //image background
PImage check_no;   //image battery
PImage save_serial; //Save Image
PImage logo;   //image logo
PImage RGB_LCD;
PImage Mono_LCD;

//Font Definitions
PFont fontA; //Main font

//Element Definitions
boolean check_Ground = true;
boolean check_GFCI = true;
boolean check_Diode = false ;
boolean check_Vent = true;
boolean check_Relay = true;
boolean save_val = false;
boolean LCD_is_RGB = true;
boolean firstDrawComplete = false;
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
int logo_X = 5;
int logo_Y = 480;
int logo_W = 180;
int logo_H = 75;
int state_X = 240;
int state_Y = 60;

int debounce = 250;
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

int EVSE_STATE = 0x02,BYTE;
int amp = 30;
int svc = 2;

void setup() 
{
  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 38400);
  
  
  size(540,580);
  frameRate(30);
  
  
 

  check_yes = loadImage("check_yes.png");
  check_no = loadImage("check_no.png");
  logo = loadImage("OpenEVSE_logo.jpg");
  save_serial = loadImage("filesave.png");
  RGB_LCD = loadImage("RGB_LCD.jpg");
  Mono_LCD = loadImage("Mono_LCD.jpg");

  fontA = loadFont("CharterBT-Roman-48.vlw");


}


void check_box (boolean checked, int check_y, int press) 
{
  //text("None", 100, 100);
  if (checked == true){
    image(check_yes, check_X, check_y, icon_size, icon_size);
  }
  else {
    image(check_no, check_X, check_y, icon_size, icon_size);
  } 
}

void firstdraw()
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

check_box (check_Ground, check_Ground_Y, press);  
check_box (check_GFCI, check_GFCI_Y, press);
check_box (check_Diode, check_Diode_Y, press);
check_box (check_Vent, check_Vent_Y, press);
check_box (check_Relay, check_Relay_Y, press);
}
void draw() 
{
  //Init static display components.
if(!firstDrawComplete)
{
  firstdraw();
  firstDrawComplete = true;
}

if(mousePressed && (millis() - press >= debounce && mouseX >= check_X && mouseX < (check_X + icon_size)))
{
  press = millis();
    //Ground
  if(mouseY>= check_Ground_Y && mouseY < check_Ground_Y + icon_size)
  { 
    if(check_Ground)  {  
      image(check_no, check_X, check_Ground_Y, icon_size, icon_size);
      check_Ground = false;
      myPort.write("$SG 0*0E");
      //Add code for key press!
    }
    else{
      image(check_yes, check_X, check_Ground_Y, icon_size, icon_size);   
      check_Ground = true;
      myPort.write("$SG 1*0F");
      //Add code for key press!
    } 
  }
    //GFCI
  if(mouseY>= check_GFCI_Y && mouseY < check_GFCI_Y + icon_size)
  { 
    if(check_GFCI)  {  
      image(check_no, check_X, check_GFCI_Y, icon_size, icon_size);
      check_GFCI = false;
      //Add code for key press!
    }
    else{
      image(check_yes, check_X, check_GFCI_Y, icon_size, icon_size);   
      check_GFCI = true;
      //Add code for key press!
    } 
  }
      //Diode
  if(mouseY>= check_Diode_Y && mouseY < check_Diode_Y + icon_size)
  { 
    if(check_Diode)  {  
      image(check_no, check_X, check_Diode_Y, icon_size, icon_size);
      check_Diode = false;
      myPort.write("$SD 1*0C");
    }
    else{
      image(check_yes, check_X, check_Diode_Y, icon_size, icon_size);   
      check_Diode = true;
      myPort.write("$SD 0*0B");
    } 
  }
      //Vent
  if(mouseY>= check_Vent_Y && mouseY < check_Vent_Y + icon_size)
  { 
    if(check_Vent)  {  
      image(check_no, check_X, check_Vent_Y, icon_size, icon_size);
      check_Vent = false;
      myPort.write("$SV 0*1D");
    }
    else{
      image(check_yes, check_X, check_Vent_Y, icon_size, icon_size);   
      check_Vent = true;
      myPort.write("$SV 1*1E");
    } 
  }
      //Relay
  if(mouseY>= check_Relay_Y && mouseY < check_Relay_Y + icon_size)
  { 
    if(check_Relay)  {  
      image(check_no, check_X, check_Relay_Y, icon_size, icon_size);
      check_Relay = false;
      //Add code for key press!
    }
    else{
      image(check_yes, check_X, check_Relay_Y, icon_size, icon_size);   
      check_Relay = true;
      //Add code for key press!
    } 
  }
}

image(save_serial, save_X, save_Y, icon_size, icon_size);

  
if (LCD_is_RGB == true){  
  image(RGB_LCD, (check_X - 40), (check_Ground_Y - 100), 100, 45); 
  }
if (LCD_is_RGB == false){  
  image(Mono_LCD, (check_X - 40), (check_Ground_Y - 100), 100, 45); 
  }

  if (mouseX >= save_X && mouseX <= (save_X + icon_size) && mouseY >= save_Y && mouseY < (save_Y + icon_size) && mousePressed){
  if (save_val  == false && millis() - press >= debounce){
    save_val = true;
    press = millis();
  }
 }
 if (mouseX >= logo_X && mouseX <= (logo_X + logo_W) && mouseY >= logo_Y && mouseY < (logo_Y + logo_H) && mousePressed){
 link("https://code.google.com/p/open-evse/");
 }
if (mouseX >= (check_X - icon_size) && mouseX <= (check_X + icon_size) && mouseY >= 50 && mouseY < 100 && mousePressed){
  if (LCD_is_RGB == true && millis() - press >= debounce){
    LCD_is_RGB = false ;
    myPort.write("$S0 0*F7");
    press = millis();
   } 
  else if (LCD_is_RGB == false && millis() - press >= debounce){
    LCD_is_RGB = true ;
    myPort.write("$S0 1*F8");
    press = millis();    
  } 
 }


fill(0);
textFont(fontA, 36);
if (EVSE_STATE == 0x00){  
  text("Unknown", state_X, state_Y);
}

if (EVSE_STATE == 0x01){  
  text("Ready", state_X, state_Y);
  text("L", (state_X), (state_Y + icon_size));
  text(svc, (state_X + 20), (state_Y + icon_size));
  text("-", (state_X + 45), (state_Y + icon_size));
  text(amp, state_X + 60, (state_Y + icon_size));
  text("A", (state_X + 100), (state_Y + icon_size));
}

if (EVSE_STATE == 0x02){  
  text("Connected", state_X, state_Y);
  text("L", (state_X), (state_Y + icon_size));
  text(svc, (state_X + 20), (state_Y + icon_size));
  text("-", (state_X + 45), (state_Y + icon_size));
  text(amp, state_X + 60, (state_Y + icon_size));
  text("A", (state_X + 100), (state_Y + icon_size));
}

if (EVSE_STATE == 0x03){  
  text("Charging", state_X, state_Y);
  text("L", (state_X), (state_Y + icon_size));
  text(svc, (state_X + 20), (state_Y + icon_size));
  text("-", (state_X + 45), (state_Y + icon_size));
  text(amp, state_X + 60, (state_Y + icon_size));
  text("A", (state_X + 100), (state_Y + icon_size));
} 

if (EVSE_STATE >= 0x04){  
  text("Error", state_X, state_Y);
  
}



//Read Sreial values 

//  if ( myPort.available() > 0) {  // If data is available,
//    val = myPort.read();         // read it and store it in val
val = 1;
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

//Write settings to OpenEVSE via Serial
if (save_val == true){  
  
  //Serial.print ; 
  myPort.write("$SS*CA"); //Save Current settings to OpenEVSE EEPROM
  save_val = false;   
  }
 }


