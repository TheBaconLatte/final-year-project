import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

import java.util.ArrayList;
import java.util.List;
import de.voidplus.leapmotion.*;

List particles;
ArrayList<PVector> old;
ArrayList<String> gestures;
boolean init, cleared, noSpell, endIntro, started, found, inRange, read;
boolean circle, stem, prong1, prong2, created, transform, pickedUp, isLeftHand, keyCount, insert;
PVector old_position, old_velocity, center, target, finger_position, prev_pos;
PFont f, A;
PImage img, bg, scroll, oldkey, endScreen;
String welcome, displayText, lumos, alohamora, fileName, a, b, g, swish, flick, loop, time, scrollText, scrollText1, scrollText2, scrollText3, clear, welcome1, welcome2;
Minim minim;
FilePlayer player;
AudioOutput out;
float alpha, instructions, note, handGrab, t1, t2, t3, loopX, loopY, swishX, swishY, flickX, flickY, handPinch, keyX, keyY, cAlpha, endAlpha;
int currTime, hold, start, count, index, keyStart, keyHold, scrollCount;
MoogFilter moog;
Gain gain;

LeapMotion leap;

void setup(){
      size(942, 541, P2D);
      img = loadImage("forestWLetter.png"); //sets the background to forest image with letter hidden within
      bg = img;
      scroll = loadImage("scroll.png");
      endScreen = loadImage("magicClassroom.jpg");

      particles = new ArrayList();
      minim = new Minim(this);
      fileName = "YOI.mp3";
      player = new FilePlayer(minim.loadFileStream(fileName));
      moog = new MoogFilter(14000, 0.5);
      gain = new Gain(0.f);
      out = minim.getLineOut();
      player.patch(moog).patch(out);
      player.patch(gain).patch(out);
      out.setTempo(80);
      player.play();
    
     
      /* === INITIALISING FONTS === */      
      f = createFont("MagicMedieval",60,true);  //creates font, sets default size, set anti-aliasing to true
      A = createFont("Arial",40,true);  //creates font, sets default size, set anti-aliasing to true
    
      /* === INITIALISING BOOLEANS === */
      init = true;
      cleared = false;
      endIntro = false;
      started = false;
      found = false;
      inRange = false;
      circle = false;
      stem = false;
      prong1 = false;
      prong2 = false;
      created = false;
      transform = false;
      pickedUp = false;
      isLeftHand = false;
      keyCount = false;
      insert = false;

      /* === INITIALISING ARRAY LISTS === */
      old = new ArrayList<PVector>();
      gestures = new ArrayList<String>();
      
      old_position = new PVector(0,0,0);
      old_velocity = new PVector(0,0,0);
      finger_position = new PVector();
      
      center = new PVector(width/2, height, 50);
      target = new PVector();
      noFill();
      
      leap = new LeapMotion(this).allowGestures();
      
      /* === INITIALISING STRINGS === */
      displayText = ""; //sets text to default blank
      clear = "";
      lumos = "Lumos!";
      alohamora = "Alohamora!";
      a = "";
      b = "";
      g = "";
      swish = "Swish!";
      flick = "Flick!";
      loop = "Loop!";
      welcome1 = "Welcome to basic magic training! \nLet's get started; \nfor your first spell, you will create a light \nto search through the forest and find the scroll. \nDo this by making a loop( circle )\nand swish( horizontal line ). \nThe music will guide you.";
      welcome2 = "Once you find the item, do a flick( keytap ).\nIf you ever need to clear a spell\n simply make a fist with your hand\n and hold for 3 seconds.\n If you begin to accidentally clear a spell\n spread your fingers!\n The text will help you.\n Good luck!";
      welcome = welcome1;
      scrollText1 = "For your next spell, \nyou'll need to make \na swish( horizontal line ) \nand a flick( tap ). \nSwipe the text away\nonce you're \nready to proceed!";
      scrollText2 = "\nOnce you cast the spell,\nyou'll need to create a key\nmade of 3 lines( 3 swipes )\nand a circle base ( 1 circle ).";
      scrollText3 = "After the shape is created,\n tap it to turn it into\n a real key. Form a fist at the base\nof the key to move it\nand insert it into the\nkeyhole at the top of the screen\n to unlock your ending!";
      scrollText = scrollText1;
      
      /* === INITIALISING INTS === */
      count = 0;
      alpha = 0;
      cAlpha = 254;
      instructions = 254;
      t1 = 0;
      t2 = 0;
      t3 = 0;
      currTime = 0;
      start = 0;
      hold = 0;
      keyX = 405;
      keyY = 130;
      keyStart = 0;
      endAlpha = 0;
      scrollCount = 0;

}


void draw() {
      loadPixels();
      img.loadPixels();
      background(0); //background black
      
      currTime = millis()/1000; //gets current time in milliseconds
      
      /* === INTRODUCTORY TEXT ===*/
      textFont(f, 35); //initialises font
      fill(227,227,96, instructions); //colour for font
      textAlign(CENTER);
      text(welcome, width/2, 100);
      
      
      /* ===== CALLS TO FADE TEXT ===== */
      if(currTime > 15 && currTime < 30){ //wait 15 seconds before displaying the second page of introductory instructions
        welcome = welcome2;
      }else if(currTime >= 30){
          instructions = fade(instructions); //waits another 15 seconds before fading these instructions
      }
      if(displayText != ""){
        alpha = fade(alpha); //spell text gradually fades
      }
      cAlpha = fade(cAlpha);
      t1 = fade(t1);
      t2 = fade(t2);
      t3 = fade(t3);
      /* ===== END OF FADE ===== */
      
      
      if(instructions<=0){ // MAKES SURE USER HAS A CHANCE TO READ THE INTRO TEXT BEFORE THEY CAN CAST SPELLS BY CHECKING THE TRANSPARENCY VALUE OF THE INTRO TEXT
          endIntro = true; 
      }
      
      if(displayText == "" && alpha <=1 ){ //If no text for the spell is set and all spell related text is transparent
        noSpell = true; //there is no spell current cast
      }      
      
      
      if (leap.getHands().size() == 0) {
        init = true;
      }
      
      for (Hand hand : leap.getHands()) {
        if(endIntro && !insert){ //only begins tracking hands if the introduction is over
            handGrab          = hand.getGrabStrength(); //if user makes a fist
            handPinch         = hand.getPinchStrength(); //if user pinches their fingers

            leapGestures(gestures); //calls method for gesture combinations
            timer(handGrab); //calls method to clear spells
            
            isLeftHand = hand.isLeft() ? true : false; //checks if hand is left hand
            
            for (Finger finger : hand.getFingers()) {
        
              // ----- BASICS -----

              finger_position   = finger.getPosition();
        
              // ----- SPECIFIC FINGER -----
        
              switch(finger.getType()) {
              case 0:
                // System.out.println("thumb");
                break;
              case 1:
                // System.out.println("index");
        
                if (init) {
                  old_position = finger_position;
                  old.clear(); // Empties the ArrayList
                  for (int i=0; i < 3; i++) {
                    old.add(old_position); //adds positions to array list to track finger movement
                  }
                  init = false;
                }
        

                particles.add( new Particle( new PVector( finger_position.x, finger_position.y ), new PVector(random(-1,1),random(-1,1)), 30));
        
               
                // Store actual finger position for next round.
                old_position = finger_position;
                
                //removes last known finger position
                prev_pos = old.remove(0);
                boolean same = false;
                if (round(prev_pos.x)/10 == round(finger_position.x)/10){ same = true; } //if the user's finger hasn't moved
                
                if(frameCount%2 == 0 && displayText != lumos){ //only plays sound every second frame, doesn't play at all in lumos spell
                 if(!same){ //Only play the sound when the user's finger is moving around, prevents continuous noise when user's finger is in the same place

                     note = map(finger_position.x, 0, width, 450, 1000); //maps finger position to frequency
                     out.playNote(0.0, 0.4, new BumpyInstrument(note, 0.02));
                  
                  }
                }
                old.add(old_position);  
        
                break;
              case 2:
                // System.out.println("middle");
                break;
              case 3:
                // System.out.println("ring");
                break;
              case 4:
                // System.out.println("pinky");
                break;
              }
            }
          }
      }
      
      new Spell(gestures, g, finger_position, displayText, moog);
      //CALLS SPELLS -- keeping this out of the cases makes sure that even if the finger position is out of range,  the spell doesn't stop

      scroll(found); //calls scroll method
      
      for(int i=0; i< particles.size();i++) {
        Particle p = (Particle)particles.get(i);
        if( !p.isDead() ) {
          p.update();
          p.draw(); //draws particles on screen
        }
      }
      
      /*Timer*/
      if(instructions <= 0 && !insert){ //only display the timer once the instructions are fully faded out
        time = str(currTime-32); // timer minus the time the welcome text was on screen
        textFont(A); //initialises font
        fill(227,227,96, 95); //colour for font
        textAlign(RIGHT);
        text(time, width-50, 50);
      }
      
      /*Message to clear spell, either "Clearing spell in ..." or "Spell cleared!" Value defined in timer function */
      textFont(f, 30); //initialises font
      fill(227,227,96, cAlpha); //colour for font
      textAlign(CENTER);
      text(clear, 150, 100);
      
      
      /* ===== Spell name ===== */
      textFont(f); //initialises font
      fill(227,227,96, alpha); //colour for font
      textAlign(CENTER);
      text(displayText, width/2, 100);
      
      /* ===== Gesture type text =====*/
      textFont(f, 25); //initialises font
      fill(227,227,96, t1); //colour for font
      textAlign(CENTER);
      text(swish, swishX, swishY);
      
      textFont(f, 25); //initialises font
      fill(227,227,96, t2); //colour for font
      textAlign(CENTER);
      text(loop, loopX, loopY);
      
      textFont(f, 25); //initialises font
      fill(227,227,96, t3); //colour for font
      textAlign(CENTER);
      text(flick, flickX, flickY);
      
      //end of Draw()
}



// ===== GESTURES ======
void leapOnSwipeGesture(SwipeGesture g, int state){
  int     id               = g.getId();
  //Finger  finger           = g.getFinger();
  //PVector position         = g.getPosition();
  //PVector positionStart    = g.getStartPosition();
  //PVector direction        = g.getDirection();
  //float   speed            = g.getSpeed();
  //long    duration         = g.getDuration();
  //float   durationSeconds  = g.getDurationInSeconds();

  switch(state){
    case 1: // Start
      break;
    case 2: // Update
      break;
    case 3: // Stop
      println("SwipeGesture: " + id);
      gestures.add("Swipe");
      if(noSpell && endIntro){ 
        t1 = 254; 
        swishX = random(100, 850);
        swishY = random(100, 430);
      }
      break;
  }
}

void leapOnCircleGesture(CircleGesture g, int state){
  int     id               = g.getId();
  //Finger  finger           = g.getFinger();
  //PVector positionCenter   = g.getCenter();
  //float   radius           = g.getRadius();
  //float   progress         = g.getProgress();
  //long    duration         = g.getDuration();
  //float   durationSeconds  = g.getDurationInSeconds();
  //int     direction        = g.getDirection();

  switch(state){
    case 1: // Start
      break;
    case 2: // Update
      break;
    case 3: // Stop
      println("CircleGesture: " + id);
      gestures.add("Circle");
      if(noSpell && endIntro){ 
        t2 = 254; //sets text to visible
        loopX = random(100, 850); //sets random x and y coordinates for the text
        loopY = random(100, 430);
        //println("LoopX: "+loopX+", LoopY: "+loopY);
      }
      break;
  }
}

void leapOnKeyTapGesture(KeyTapGesture g){
  int id = g.getId();
  println("KeyTapGesture: " + id);
  gestures.add("KeyTap");
  if(noSpell && endIntro){
    t3 = 254;
    flickX = random(100, 850);
    flickY = random(100, 430);
    //println("FlickX: "+flickX+", FlickY: "+flickY);
  }
}

void leapGestures(ArrayList<String> gestures){
  /* This method takes in an ArrayList of Strings which store the gestures the user makes
     The method takes the two most recent gestures and "casts" a spell depending on which gesture combination the user made
     The ArrayList will only have 2 elements in it maximum as we get the gesture at 0 then *remove* the element at 1
     This means we always have the 2 most recent gestures
  */
  
    if(!gestures.isEmpty() && a == ""){
        a = gestures.get(0); //a will always contain the first value in the array list
    }
    else if(!gestures.isEmpty() && gestures.size() > 1 && a!= "" && noSpell){ //if array list is large enough, a is defined, and there is no current spell
      
        b = gestures.remove(1); //removes the second most recent spell
        
        if( a == "Swipe" && b == "KeyTap" && found){ // checks that the letter in lumos has been found
            reset(); //resets alpha value of spell text and clears gestures
            noSpell = false; //denotes that we're currently in a spell
            displayText = alohamora; //sets the spell text, which will then call the relevant methods
            println("In second spell");
        }
        else if( a == "Circle" && b == "Swipe"){ //checks the gesture combination and that we aren't currently in a spell
            reset();
            noSpell = false;
            displayText = lumos;
            println("In first spell");
        }
        
        a = b; //as b gets updated, a will contain the last value b held, which is also element 0 in the array list
    }
}

void reset(){ //resets the gestures and alpha value so the text will appear
    alpha = 254;
    g = "";
    gestures.clear();
}

float fade(float a){
      /*Decrements value passed in by 2
        Values passed in are usually alpha values for text
        Which causes the text to gradually fade out when it appears on the canvas
      */
      
      if(a>0){
        a-=2;
      }
      return a;
}

void timer(float handGrab){
/*This method is a timer 
  The user makes a fist with their hand and if they hold their hand in a fist for 3 seconds
  The spell they're currently on is cleared
  This is so that they can cast new spells if a spell was cast by accident
*/

  if(handGrab == 1.0 && displayText!="" && !transform){ //if user makes fist
    
    if(!started){ //timer has not been started
      start = millis()/1000; //start timer
      started = true;
    }
    
    while(handGrab == 1.0 && started){ //while user holds the fist
        
        if(hold>=3){ //user holds a fist for 3 seconds
            clear = "Nix! \nSpell cleared!"; 
            
            displayText = "";
            gestures.clear();
            
            cAlpha = 270; //resets alpha value for text that indicates spell has been cleared
            alpha = 0; //resets alpha for spell names so new spells can be cast
            g = "";
            handGrab = 0; //Resets value of handGrab. Failing to do this will crash the program if the user's hand lingers over the leap motion.
            
            moog.frequency.setLastValue(14000); //reset moog so music will no longer be muted outside of spell
            
            hold = 0;
            started = false;
     
        }else{
            currTime = millis()/1000; //gets current time
            hold = currTime-start; //finds out how many seconds it's been since user first formed a fist
            
            cAlpha = 270;
            clear = "Clearing spell in "+hold+"...";
            //println("Start: "+start+", CurrTime: "+currTime+", Hold: "+hold+", Started:"+started);
        }      
      break; //breaks the while loop to prevent program freezing    
     }
    /*  END OF WHILE LOOP  */ 
    }else{
        started = false; //restarts counter if user stops making fist
    }
  /*  END OF TIMER()  */
}

void scroll(boolean found){
    /* This method checks if the user has found the hidden item in the first spell
       If they have, it will print an image of a scroll onto the screen with text explaining the next spell
       The user swipes the text away to get the next set of text
       And finally swipes to dimiss both the text and the scroll, at which stage read will be set to true
       After this the user can cast the second spell
       */
    if(found && !read){ //scroll
          image(scroll, 200, 100);
          displayText = "";
          textFont(f, 25); //initialises font
          fill(0, 0, 0, 254); //colour for font
          textAlign(CENTER);
          text(scrollText, 450, 160);
          
          if(!gestures.isEmpty()){
              index = gestures.size();
              g = gestures.remove(index-1); //removes most recent gesture
          }
                    
          if(g == "Swipe"){ //checks to see if gesture is swipe
              if(scrollCount == 0){ //checks how many times swipe has been performed within this method
                  scrollText = scrollText2;
                  //println("In the first if");
                  delay(500);
                  scrollCount++;
                  g = ""; //resets g for the next time this method is called
                  return;
              }else if(scrollCount == 1){
                  scrollText = scrollText3;
                  //println("In the second if");
                  delay(700); //delay the program to ensure the user has time to read the message
                  scrollCount++;
                  g = "";
                  return;
              }else if(scrollCount > 1){
                  read = true; //text has been read
                  noSpell = true; //no longer in a spell
                  //println("In the final if, Read = " + read);
                  gestures.clear(); //clears gestures
              }
              return;
          }
     }
}