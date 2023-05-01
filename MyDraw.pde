
class  MyDraw extends MyExporter{

  PVector prev_point;
  PVector pix_min;
  PVector pix_max;
  
  float   BEZIER_INTERPOLATION_SCALE = 5.;
  
  MyDraw(PVector pix_min, PVector pix_max) {
    this.pix_min = pix_min;
    this.pix_max = pix_max;
  }

  void finalize() {
  }


  void start_layer(String layer_id) {
    
  }
  void end_layer()
  {
  }

  void start_path(color c, PVector point_arg) {
    stroke(c);
  }
  

  void add_path(MyLine line_arg) {
    if (line_arg instanceof MySimpleLine) {
      beginShape();
      vertex(line_arg.p_start().x, line_arg.p_start().y);
      vertex(line_arg.p_end().x, line_arg.p_end().y);
      endShape();
    } else if ( line_arg instanceof MyCubicBezier) {
      MyCubicBezier bezier = (MyCubicBezier) line_arg;
      float bl = bezier.length();
      int interp_cnt = max(2,floor(bl/BEZIER_INTERPOLATION_SCALE));
      
      noFill();
      beginShape();
      
      for (int i = 0; i <= interp_cnt; i ++) {
        float f = (float)i / interp_cnt;
        PVector p = bezier.p_at(f);
        vertex(p.x, p.y);
      }
      endShape();
      
    }
  }

  void end_path() {}

  void fsave(String path_str) {
    save(path_str + ".png");
  }
}
  
