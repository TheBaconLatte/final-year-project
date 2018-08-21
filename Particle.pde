/*
The code in this class was sourced from GuruBlog
https://www.local-guru.net/blog/2011/4/14/sparkles-with-processing
*/

public class Particle {

  PVector p;
  PVector s;
  int ttl;
  PImage img;
  //float colour;
  
  //public Particle( PVector p, PVector s, int ttl, float colour) {
  public Particle( PVector p, PVector s, int ttl) {
    this.p = p;
    this.s = s;
    this.ttl = ttl;
    //this.colour = colour;
    
    //img = makeTexture(5, colour);
    img = makeTexture(5);

  }

  public void update() {
    if ( ttl > 0 ) {
      ttl--;
      p.add( s );
    }
  }
 
  public void draw() {
    if ( !isDead() ) {
      blend( img, 0,0, img.width, img.height, int(p.x - img.width/2), int(p.y - img.height/2), img.width, img.height, ADD );
    }
  }
  
  public boolean isDead() {
    return ttl <= 0;
  }
  
  
  //PGraphics makeTexture( int r, float colour ) {
  PGraphics makeTexture( int r ) {
      PGraphics res = createGraphics(r * 6, r * 6, P2D);
      res.beginDraw();
      res.loadPixels();
        for ( int x = 0; x < res.width; x++) {   
          for( int y = 0; y < res.height; y++ ) {
            float d = min( 512, 50*  sq( r / sqrt( sq( x - 3 * r) + sq( y - 3 * r))));
            //if ( d < 10 ) d = 0;
            res.pixels[y * res.width + x] = color( min(255, d), min(255, d*0.8), d* 0.5 );
    
          }
        }
      res.updatePixels();
      res.endDraw();
      
      return res;  
  }  
}