
import java.util.*;

abstract class MyLine {
  abstract void    reverse() ;
  abstract PVector p_start();
  abstract PVector p_end();
  
  abstract PVector p_at(float t);
  abstract PVector direction();
  abstract float   length();
  abstract String  toString();
  abstract boolean equals(Object obj);
  
}

class MySimpleLine extends MyLine {
  private PVector[] ps;
  public static final String my_type =  "line";
  public PVector p; // get coordinate on the grid

  MySimpleLine(PVector p1_arg, PVector p2_arg) {
    ps = new PVector[2];
    ps[0] = p1_arg;
    ps[1] = p2_arg;
    p = new PVector((ps[0].x + ps[1].x)/2, (ps[0].y + ps[1].y)/2);
  }

  @Override
  public String toString() {
    return "MyLine p1:" + ps[0] + " ;p2:" + ps[1];
  }

  PVector p_start() {
    return ps[0];
  }
  PVector p_end(){
    return ps[1];
  }
  float length(){
    return PVector.sub(ps[1], ps[0]).mag();
  }

  PVector p_at(float t) {
    return ps[0].lerp(ps[1], t);
  }

  void reverse() {
    PVector p_temp = ps[0];
    ps[0] = ps[1];
    ps[1] = p_temp;
  }
  PVector direction() {
    return PVector.sub(ps[1], ps[0]);
  }

  @Override
  public boolean equals(Object obj) {
    if (obj instanceof MySimpleLine) {
      MySimpleLine l_check = (MySimpleLine) obj;
      return (((ps[0].equals(l_check.ps[0])) && (ps[1].equals(l_check.ps[1]))) ||
        ((ps[0].equals(l_check.ps[1])) && (ps[1].equals(l_check.ps[0])))   );
    }
    return false;
  }
}

/**
 * line that has control points alla cubic bezier,
  https://en.wikipedia.org/wiki/B%C3%A9zier_curve
 * ps[] are start and end point (in wiki : p0 and p3)
 * pbs[]  are the bezier control points (in wiki : p1 and p2)
 */
class MyCubicBezier extends MyLine {
  private PVector[] ps;
                  
  
  MyCubicBezier(PVector p0_arg, PVector p1_arg, PVector p2_arg, PVector p3_arg) {
    ps = new PVector[4];
    ps[0] = p0_arg;
    ps[1] = p1_arg;
    ps[2] = p2_arg;
    ps[3] = p3_arg;

  }
  void reverse() {
    Collections.reverse(Arrays.asList(ps));

  }
  PVector direction() {
    return PVector.sub(ps[3], ps[0]);
  }
  float length() {
    //https://stackoverflow.com/questions/29438398/cheap-way-of-calculating-cubic-bezier-length
    float  chord = PVector.sub(ps[3],ps[0]).mag();
    
    float  cont_net = PVector.sub(ps[1], ps[0]).mag() + PVector.sub(ps[2], ps[1]).mag() +  PVector.sub(ps[3], ps[2]).mag();

    float app_arc_length = (cont_net + chord) / 2;
    return app_arc_length;
    
  }
  
  PVector p_start() {
    return ps[0];
  }
  PVector p_end(){
    return ps[3];
  }
  PVector p1(){
    return ps[1];
  }
  PVector p2(){
    return ps[2];
  }


  
  @Override
  public String toString() {
    return "Bezier p0: " + ps[0] + " ;p1: " +ps[1] + " ;p2: " + ps[2]  + " ;p3: " + ps[3];
  }
  
  PVector p_at(float t) {
    PVector p = new PVector(0,0);
    p.x = cubic_bezier(t, ps[0].x, ps[1].x, ps[2].x, ps[3].x);
    p.y = cubic_bezier(t, ps[0].y, ps[1].y, ps[2].y, ps[3].y);
    return p;
  }
  private float cubic_bezier(float t, float p0, float p1, float p2, float p3) {
    
    float omt  = (1-t);
    float omt2 = omt * omt;
    float omt3 = omt2 * omt;
    float t2 = t*t;
    float t3 = t2*t;
    
    float v = omt3*p0 + 3.*omt2*t*p1 + 3.*omt*t2*p2 + t3*p3;
    return v; 

  }
  
  @Override
  public boolean equals(Object obj) {
    if (obj instanceof MyCubicBezier) {
      MyCubicBezier l = (MyCubicBezier) obj;

      return (((ps[0].equals(l.ps[0])) && (ps[1].equals(l.ps[1])) && (ps[2].equals(l.ps[2])) && (ps[3].equals(l.ps[3])) ) ||
              ((ps[0].equals(l.ps[3])) && (ps[1].equals(l.ps[2])) && (ps[2].equals(l.ps[1])) && (ps[3].equals(l.ps[0])) )    );
    }
    return false;
  }
  
}
