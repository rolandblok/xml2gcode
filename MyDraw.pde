
class  MyDraw extends MyExporter{

  PVector prev_point;
  PVector pix_min;
  PVector pix_max;
  
  
  MyDraw(PVector pix_min, PVector pix_max) {
    this.pix_min = pix_min;
    this.pix_max = pix_max;
    this.prev_point = null;
  }

  void finalize() {
  }


  void start_layer(String layer_id) {
    
  }
  void end_layer()
  {
  }

  void start_path(String c, PVector point_arg) {
    stroke(color(0));
    prev_point = point_arg;
  }
  

  void add_path(PVector point_arg) {
    line(prev_point.x, prev_point.y, point_arg.x, point_arg.y);
    prev_point = point_arg;
  }

  void end_path() {}

  void fsave(String path_str) {
    save(path_str + ".png");
  }
}
  
