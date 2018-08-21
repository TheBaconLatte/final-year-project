public class Spell{
  
  ArrayList<String> gestures;
  String g;
  PVector finger_position;
  String displayText;
  MoogFilter moog;
  boolean started; //reusing boolean from other class for clarity's sake
  int currTime;
  boolean inRange;
  
  public Spell(ArrayList<String> gestures, String g, PVector finger_position, String displayText, MoogFilter moog){
        this.g = g;
        this.gestures = gestures;
        this.finger_position = finger_position;
        this.displayText = displayText;
        this.moog = moog;
        
        currTime = 0;
        inRange = false;
        
        if(displayText == lumos){ //if lumos is cast
              
              lumosSpell(finger_position, moog);
              
        }else if(displayText == alohamora && !insert){ //second spell is cast (until the user completes the task within)
             
              drawShapes(gestures, g);
              
        }
        
        endScreen(insert); //load endscreen
  }
  
  
  void lumosSpell( PVector finger_position, MoogFilter moog ){  //when the spell lumos is cast it will activate this flashlight feature
      /* This code was referenced from the Learn Processing tutorial found here:
         http://learningprocessing.com/examples/chp15/example-15-09-FlashLight
      */
      
      hotOrCold(moog, finger_position); //changes background music to help user find hidden item
      img = letter(); //sets img image to whatever is returned by the letter method
      img.loadPixels(); //loads image pixels
      background(img); //sets background to image

      for (int x = 0; x < img.width; x++ ) {
         for (int y = 0; y < img.height; y++ ) {
              // Calculate the 1D pixel location
              int loc = x + y*img.width;
        
              // Get the R,G,B values from image
              float r = red  (img.pixels[loc]);
              float g = green(img.pixels[loc]);
              float b = blue (img.pixels[loc]);
        
              // Calculate an amount to change brightness
              // based on proximity to the mouse
              float distance = dist(x, y, finger_position.x, finger_position.y);
        
              // The closer the pixel is to the mouse, the lower the value of "distance" 
              // We want closer pixels to be brighter, however, so we invert the value using map()
              // Pixels with a distance of 50 (or greater) have a brightness of 0.0 (or negative which is equivalent to 0 here)
              // Pixels with a distance of 0 have a brightness of 1.0.
              float adjustBrightness = map(distance/3, 0, 50, 8, 0);
              r *= adjustBrightness;
              g *= adjustBrightness;
              b *= adjustBrightness;
        
              // Constrain RGB to between 0-255
              r = constrain(r, 0, 255);
              g = constrain(g, 0, 255);
              b = constrain(b, 0, 255);
        
              // Make a new color and set pixel in the window
              color c = color(r, g, b);
              pixels[loc] = c;
            }
        }
        
        updatePixels();
        println("X: "+finger_position.x+", Y: "+finger_position.y);
  }
  
     
   PImage letter(){  //when the spell lumos is cast, this function will be called
   // the purpose of this function is to detect when the user has found the letter
   // the user will blow against the microphone when their finger is within range
   // when the user blows on the microphone, the letter will "disappear", the background image will be set to the version *without* the letter
        println("X: "+finger_position.x +", Y: "+finger_position.y); 
        
        if((finger_position.x >= 100 && finger_position.x <= 200) && (finger_position.y >= 375 && finger_position.y <= 475)){ //checks if finger is in range of letter position
            inRange = true;
        }else{
            inRange = false;
        }
        
        if(!gestures.isEmpty()){
              index = gestures.size();
              g = gestures.remove(index-1); //removes most recent gesture
        }
        if(g == "KeyTap" && !found && inRange){ //if keytap is performed, the letter hasn't been found yet, and the finger position is in range
            bg = loadImage("forest.png"); //change background image to forest with no letter
            found = true; //found is set to true
            return bg; //image is returned
        }
        return bg;
   }
   
   
   void hotOrCold(MoogFilter moog, PVector finger_position){
     //this function will put a filter on the music playing to alert the user to when they're closer vs. further away from the target
     
     float freq = constrain(map(finger_position.x, width, 0, 0, 14000), 0, 18000); //sound becomes clearer closer to the left than to the right
     float db = map(finger_position.x, width, 0, -10, 6); //sound becomes louder closer to the left than to the right
     
     gain.setValue(db);
     moog.frequency.setLastValue(freq);
     
   }
 
  
  void drawShapes(ArrayList<String> gestures, String g){  //second spell

          if(!gestures.isEmpty()){
              index = gestures.size();
              g = gestures.remove(index-1); //removes most recent gesture
          }
       
         if(g == "Circle" && !circle){ //adding boolean check prevents image of key from flickering
             circle = true;
             return;
         } else if(g == "Swipe" && count == 0){ //checks if swipe gesture is performed and how many
             stem = true;
             count++;
             return;
         } else if(g == "Swipe" && count == 1){
             prong1 = true;
             count++;
             return;
         } else if(g == "Swipe" && count == 2){
             prong2 = true;
             count++;
         }
         
         if(!created){ //if the key has not yet been created
             if(circle == true){ //draw base of key
                    noStroke();
                    fill(227, 227, 96);
                    ellipse(450, 350, 100, 100); //create outer ring
                    noStroke();
                    fill(0);
                    ellipse(450, 350, 80, 80); //create inner ring of blackness
             }
             if(stem == true){ //draw stem
                    noStroke();
                    fill(227, 227, 96);
                    rect(440, 160, 20, 150); //draw stem of key
              }       
             if(prong1 == true){ //draw first prong
                    noStroke();
                    fill(227, 227, 96);
                    rect(450, 180, 50, 10); //draw the first prong
              } 
              if(prong2 == true){ //draw second prong
                    noStroke();
                    fill(227, 227, 96);
                    rect(450, 205, 50, 10); //draw the second prong
              }
         }
         
         key(circle, stem, prong1, prong2, g, keyX, keyY);
    }
 
    boolean key(boolean circle, boolean stem, boolean prong1, boolean prong2, String g, float keyX, float keyY){

        if(circle && stem && prong1 && prong2){ //if all 4 parts of the key are drawn
            if(g == "KeyTap" && !transform){ //when the user taps the key
                transform = true; //boolean is needed so that it only checks the gesture once
            }
            if(transform && !pickedUp){
                created = true; //the key is created
                oldkey = loadImage("key2.png"); //replace shapes with image of key
                image(oldkey, keyX, keyY);
            }
          unlock(oldkey); //allows user to pick up and "move" the key
        }
        return created;
        
    }

    void unlock(PImage oldkey){
        
        boolean grab = false;
        leftHandFix(finger_position); //fixes bug where left hand position on the x axis was smaller than right hand position
        
        if(transform){ //if the shapes have been turned into the key image
        
            if(handGrab >= 0.8 || handPinch >= 0.8){ //if they user is making a fist or pinching their fingers
                grab = true; //user intends to pick up the key
            }else{
                grab = false;
            }
            
            //sets region boundaries for base of key in image
            float lowKeyX = keyX+100; // (505 to begin with)
            float hiKeyX = keyX+200; // (605 to begin with)
            float lowKeyY = keyY+250; // (230 to begin with)
            float hiKeyY = keyY+320; // (330 to begin with)
            
            //println("LowX: "+lowKeyX+", HighX: "+hiKeyX+", LowY: "+lowKeyY+", HighY: "+hiKeyY);
            if((finger_position.x >= lowKeyX && finger_position.x <= hiKeyX) && (finger_position.y >= lowKeyY && finger_position.y <= hiKeyY) && grab){
                  pickedUp = true; //if the user's hand is in the region of the base of the key and their fist is clenched
                  println(pickedUp);
            }else{
                  pickedUp = false;
            }
            
           
            if(pickedUp){ //the key follows the user's movement while the user's fist is clenched
                keyX = finger_position.x-150; //subtractions account for size of image canvas
                keyY = finger_position.y-300;
                image(oldkey, keyX, keyY); //draw key to follow user's movement
            } else{
                image(oldkey, keyX, keyY); //the key is drawn in the last known place since the user stopped clenching their fist
            }
            
            //println("KeyX: "+keyX+", KeyY: "+keyY);
        }
        //println("Outside keyhole method, started: "+keyCount);
        keyHole(keyX, keyY);
    }
    
    boolean keyHole(float keyX, float keyY){
        /* if key is at a certain point on the screen
        start the timer
        if the key stays within that range
        "unlock" the end screen
        transition to end message    
        */
        
        if((keyX>= 300 && keyX<=500) && (keyY<= -100)){ //very top of the screen in the centre
            inRange = true;
        }else{
            inRange = false;
        }
        
        if(inRange && !insert){ //if the key is in range and has not been "inserted"
              if(!keyCount){ //timer has not been started
                  keyStart = millis()/1000; //start timer
                  keyCount = true;
              }
              
              println("KeyCount: "+keyCount+", In Range: "+inRange);
              while(inRange && keyCount){ //while user holds the fist
                    if(keyHold>=2){ //user holds a fist for 2 seconds
                        keyHold = 0;
                        keyCount = false;
                        insert = true; //key has been placed in correct position
                    }else{ //keep counting
                        currTime = millis()/1000; //gets current time
                        keyHold = currTime-keyStart; //finds out how many seconds it's been since user first formed a fist
                        println("Start: "+keyStart+", CurrTime: "+currTime+", Hold: "+keyHold+", KeyCount:"+keyCount);
                    }         
                  break; //breaks the while loop to prevent program freezing    
               }
            /*  END OF WHILE LOOP  */ 
        }else{
            keyCount = false; //restarts counter if user stops making fist
        }
        println("Insert: "+insert);
        return insert;
    }
    
    void endScreen(boolean insert){
        if(insert){ //if the key has been inserted into the correct position
              displayText = "";
              gestures.clear();
              if(endAlpha < 256){
                  endAlpha+=2; //increases transparency of background image gradually
              }
              tint(255, endAlpha);
              image(endScreen, 0, 0); //load background image
              
              if(endAlpha >= 254){ //if image is fully loaded
                  image(scroll, 200, 110); //draw scroll onto the screen
                  textFont(f, 30); //initialises font
                  fill(0, 0, 0, 254); //colour for font
                  textAlign(CENTER);
                  text("Congratulations!\nYou completed basic\ntraining in \n"+time+" seconds!", 460, 200); //end text, prints time it took
              }
        }
    }
        

    void leftHandFix(PVector finger_position){ //fixes bug where left hand x position was around 220 pixels less than right hand x position
        if(isLeftHand){
            finger_position.x = finger_position.x+220;
        }
    }
}