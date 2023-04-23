import java.io.*;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.*;


class MyGCode extends MyExporter{
  Vector<Vector<String>> layers_gcode_list;
  int     cur_layer;
  PVector pix_min;
  
  float pix2mm_scl ;
  PVector pix_offset;
  PVector mm_offset;
  
  int draw_speed;
  int move_speed;
  
  private PVector pix2mm(PVector pix) {
    PVector mm = PVector.mult(PVector.add(pix, pix_offset), pix2mm_scl).add(mm_offset); 
    
    return mm; 
  }
  
  private void pen_up() {
    String ss = "M5\n";
    __add_to_svg(ss);
  }
    
  private void pen_down() {
    int no_steps = 5;
    for (int i = 0; i < no_steps; i++){
        float sv = lerp(10, 30,i/(no_steps-1.));
        String ss = String.format("m3 s%02d;\n", (int)sv);
        __add_to_svg(ss);
        __add_to_svg("G4 P0.1;\n");
    }
  }

  void __add_to_svg(String text) {
      //"""
      //    Utility function to add element to drawing.
      //    """
      layers_gcode_list.get(cur_layer).add(text);
  }


  public MyGCode(PVector pix_min, PVector pix_max, float mm_width, float mm_height) {
    move_speed = 4000;
    draw_speed = 2000;
    
    
    layers_gcode_list = new Vector<Vector<String>>();
    cur_layer = -1;
  
    // start determine PIX2MM 
    pix2mm_scl = 1.;
    mm_offset = new PVector(0,0);
    pix_offset = PVector.mult(pix_min, -1.);

    // determine the scaling
    PVector pix_size = pix2mm(pix_max);
    float pix2mm_scl_x = mm_width / pix_size.x;
    float pix2mm_scl_y = mm_height / pix_size.y;
    if (pix2mm_scl_y * pix_size.x > mm_width) {
      pix2mm_scl = pix2mm_scl_x; 
    } else {
       pix2mm_scl = pix2mm_scl_y; 
    }
    println(" pix_min " + pix_min + " pix_max " + pix_max);
    println(" pix2mm_scl * pix_size " + PVector.mult(pix_size, pix2mm_scl));
    
    // fraction to pad on the edge
    float padding = 0.1;
    pix2mm_scl = (1.0-padding) * pix2mm_scl;

    
    //determine the center offset : mm_offset
    PVector paper_size = new PVector(mm_width, mm_height);
    println(" paper_size " + paper_size);
    PVector mm_size = pix2mm(pix_max);
    mm_offset = PVector.sub(paper_size, mm_size).mult(0.5);
    

/*   
G1 F2000 x0 Y0
G1 F700 X210 Y0
G1 F700 X210 Y291
G1 F700 X0   Y291
G1 F700 X0   Y0
M5
*/
  }


  void finalize() {
  }



  void start_layer(String layer_id) {
    cur_layer ++;
    Vector<String> gcode_list = new Vector<String>();
    layers_gcode_list.add(gcode_list);
    
    String ss = "G90\nM5\n";
    __add_to_svg(ss);
    
  }
  void end_layer() {
    pen_up();
  }

  void start_path(color c, PVector p_pix)
  {
      PVector p_mm = pix2mm(p_pix);
      String ss = String.format("G1 F%d X%.3f Y%.3f\n", (int)move_speed, p_mm.x, p_mm.y);
      __add_to_svg(ss);
      pen_down();
  }

  void add_path(PVector p_pix)
  {
      PVector p_mm = pix2mm(p_pix);
      String ss = String.format("G1 F%d X%.3f Y%.3f\n", (int)draw_speed, p_mm.x, p_mm.y);
      __add_to_svg(ss);
  }

  void end_path()
  {
    pen_up();
  }

  void fsave(String path_str) {
    
    for (int i = 0; i < layers_gcode_list.size(); i++) {
      Vector<String> gcode_list = layers_gcode_list.get(i);
      String fn = String.format("%s.L%02d.gcode", path_str, i);
      println("saving to : "+fn); 

      File file = new File(fn);
      try {
        FileWriter wr = new FileWriter(file);
        for (String s : gcode_list) {
          wr.write(s);
        }
        wr.flush();
        wr.close();
      } catch (IOException ioe) {
         println("save failed " + ioe); 
      }
    }

  }

}
