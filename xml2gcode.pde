

import java.io.File;
import uibooster.*;
import java.util.*;






//String plot_name = "orbits_8x2";
//String plot_name = "plot_face";
//String plot_name = "roland";
String plot_name = "spline_test";
//String plot_name = "hexa_cube_01.A3POR";


MyDraw my_draw;


void setup() {
  size(1000, 1000);
  surface.setTitle("xml 2 GCODE");

  Locale.setDefault(Locale.US);

  //String file_name = "C:\\Users\\roland\\Downloads\\" + plot_name + ".svg";
  String file_name = sketchPath() + "\\svg_in\\"+ plot_name + ".svg";

  saveit(file_name, plot_name);

  noLoop();
}

void draw() {
}


void mouseClicked() {
  String f_name = sketchPath() + "/png/" + plot_name + ".png";
  println("saving to " + f_name);
  save(f_name);
}

////////////////////////////////////////////////////////
// Read the xml file and create a MyPath object from it
void handle_svg_g(XML xml_layer, MyPaths paths) {
      String layer_id = xml_layer.getString("id", "#000000");
      println("new layer : " + layer_id);
      paths.startLayer(layer_id);
      for (XML xml_path : xml_layer.getChildren()) {
        LinkedList<MyLine> visible_lines = new LinkedList<MyLine>();
        if (xml_path.getName() == "path") {
          color c = color(0);
          if (xml_path.hasAttribute("transform")) {
            println("TRANSFORM NOT SUPPORTED " + xml_path.getString("transform"));        
          }
          if (xml_path.hasAttribute("stroke")) {
            String stroke = xml_path.getString("style");
            // not implemented
          }
          if (xml_path.hasAttribute("style")) {
            String style = xml_path.getString("style");
            style = style.replaceAll("[\n]", " ");
            style = style.replaceAll(",", " ");
            style = style.replaceAll(":", " ");
            style = style.replaceAll(";", " ");
            Scanner sc = new Scanner(style).useLocale(Locale.US);
            while (sc.hasNext()) {
              String next = sc.next();
              if (next.equals("stroke")) {
                //c = color(sc.next());
                // not implemented
              }
            }
          }
          if (xml_path.hasAttribute("d")) {
            paths.startPath(c);
            //println("start path");
            String d = xml_path.getString("d");
            //https://regexr.com/
            PVector prev = new PVector(0,0);
            String prev_command = "";
            //d = d.replaceAll("[MmLl\n,z]", " ");
            d = d.replaceAll("[\n]", " ");
            d = d.replaceAll(",", " ");
            //d = d.trim();
            PVector first_pos = null;

            d = d.replaceAll("([mMlLhHvVzZcCsSqQtTaA])", "$1 ");  // add extra space when character is attached to the numbers
            d = d.replaceAll("\\s{2,}", " ");       // remove double spaces.
            //d = d.trim();
            println(d);
            Scanner sc = new Scanner(d).useLocale(Locale.US);
            
            // https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/d
            while (sc.hasNext()) {

              
              // determine if the new command is new command, or a new number which uses same command.
              String command = "";
              if (sc.hasNextDouble()){
                command = new String(prev_command);
                //println("" + command + " (copy prev)");
              } else {
                command = sc.next();
                prev_command = new String(command);
                //println("" + command);
              }
              PVector p = new PVector(0,0);
              if (command.equals("M")) {
                p.x = (float)sc.nextDouble();
                p.y = (float)sc.nextDouble();

              } else if (command.equals("m")) {
                p.x = (float)sc.nextDouble() + prev.x;
                p.y = (float)sc.nextDouble() + prev.y;
              } else if (command.equals("L")) {
                p.x = (float)sc.nextDouble();
                p.y = (float)sc.nextDouble();
              } else if (command.equals("l")) {
                p.x = (float)sc.nextDouble() + prev.x;
                p.y = (float)sc.nextDouble() + prev.y;
              } else if (command.equals("H")) {
                p.x = (float)sc.nextDouble();
                p.y = prev.y;
              } else if (command.equals("h")) {
                p.x = (float)sc.nextDouble() + prev.x;
                p.y = prev.y;
              } else if (command.equals("V")) {
                p.x = prev.x;
                p.y = (float)sc.nextDouble();
              } else if (command.equals("v")) {
                p.x = prev.x;
                p.y = (float)sc.nextDouble() + prev.y;
              } else if ((command.equals("z")) || (command.equals("Z")))  {
                p.x = first_pos.x;
                p.y = first_pos.y;
              } else if (command.equals("C"))  {
                float x1 = (float)sc.nextDouble();
                float y1 = (float)sc.nextDouble();
                float x2 = (float)sc.nextDouble();
                float y2 = (float)sc.nextDouble();
                p.x = (float)sc.nextDouble();
                p.y = (float)sc.nextDouble();
              }  else if (command.equals("c"))  {
                float x1 = (float)sc.nextDouble()  + prev.x;
                float y1 = (float)sc.nextDouble()  + prev.y;
                float x2 = (float)sc.nextDouble()  + prev.x;
                float y2 = (float)sc.nextDouble()  + prev.y;
                p.x = (float)sc.nextDouble() + prev.x;;
                p.y = (float)sc.nextDouble() + prev.y;
              } else if ((command.equals("S")) || (command.equals("s")))  {
                println(" do not support SMOOTH BEZIER " );
              } else if ((command.equals("q")) || (command.equals("Q")))  {
                println(" do not support Quadratic Bézier Curve " );
              } else if ((command.equals("t")) || (command.equals("T")))  {
                println(" do not support SMOOTH Quadratic Bézier Curve " );
              }else if ((command.equals("a")) || (command.equals("A")))  {
                println(" do not support Elliptical Arc Curve " );
              }
              //println(" " + p.x + " " + p.y);
              //paths.addPathPoint(p);
              
              if (first_pos == null) {
                first_pos = p.copy();
              } else {
                paths.addLine(prev, p);
              }
              
              prev = p.copy();

            }

            sc.close();
          }
        } else if (xml_path.getName() == "line") {
          float x1 = xml_path.getFloat("x1");
          float x2 = xml_path.getFloat("x2");
          float y1 = xml_path.getFloat("y1");
          float y2 = xml_path.getFloat("y2");
          PVector p1 = new PVector(x1,y1);
          PVector p2 = new PVector(x2,y2);
          paths.addLine( p1, p2 );
          //paths.addPathPoint( p2 );

        } else if (xml_path.getName() == "g") {
            handle_svg_g(xml_path, paths);
        }
        
      }
      paths.endLayer(layer_id);
      println("layer added, no_lines : " + paths.getNoLines() );
      
}




void saveit(String file_name, String plot_name) {

  File f = new File(file_name);
  if(!f.exists() || f.isDirectory()) { 
      // do something
    println("file does not exist " + file_name) ;
    return;
  }

  XML svg_xml_data = loadXML(file_name);
  // recursive_print_kids(svg_xml_data, 0);

  MyPaths paths = new MyPaths();
  // top level SVG
  for (XML xml_layer : svg_xml_data.getChildren()) {
    // get the layers
    if (xml_layer.getName() == "g") {
      handle_svg_g(xml_layer, paths);
    }
  }

  println("no paths " + paths.getNoPaths());
  println("no lines " + paths.getNoLines());






  String selection = new UiBooster().showSelectionDialog(
    "Select Format",
    "Format?",
    Arrays.asList("A4 PORTRAIT", "A4 LANDSCAPE", "A3 PORTRAIT", "A3 LANDSCAPE"));


  String name_ext = "";
  float p_w = A4_PORTRAIT_WIDTH;
  float p_h = A4_PORTRAIT_HEIGHT;
  println("selection " + selection);
  if (selection == "A4 PORTRAIT") {
    p_w = A4_PORTRAIT_WIDTH;
    p_h = A4_PORTRAIT_HEIGHT;
    name_ext = ".A4POR";
  } else if (selection == "A4 LANDSCAPE") {
    p_w = A4_PORTRAIT_HEIGHT;
    p_h = A4_PORTRAIT_WIDTH;
    name_ext = ".A4LAN";
  } else if (selection == "A3 PORTRAIT") {
    p_w = A3_PORTRAIT_WIDTH;
    p_h = A3_PORTRAIT_HEIGHT;
    name_ext = ".A3POR";
  } else if (selection == "A3 LANDSCAPE") {
    p_w = A3_PORTRAIT_HEIGHT;
    p_h = A3_PORTRAIT_WIDTH;
    name_ext = ".A3LAN";
  }

  PVector min = new PVector();
  PVector max = new PVector();
  paths.getBounds(min, max);

  String filename = sketchPath() + "/gcode/" + plot_name+name_ext;

  MyGCode gcode = new MyGCode(min, max, p_w, p_h);
  paths.draw(gcode);
  gcode.finalize();
  gcode.fsave(filename);

  filename = sketchPath() + "/svg/" + plot_name;

  MySvg svg = new MySvg(min, max, p_w, p_h);
  paths.draw(svg);
  svg.finalize();
  svg.fsave(filename);

  my_draw = new MyDraw(min, max);
  paths.draw(my_draw);
  my_draw.finalize();
}

void recursive_print_kids(XML xml, int indent) {
  String kid_s =xml.getName();
  int ac = xml.getAttributeCount();

  printspace(indent);

  print(kid_s + " " + ac );
  for (String a : xml.listAttributes()) {
    print(" " + a);
  }
  println("");

  XML [] kids = xml.getChildren();
  for (XML kid : kids) {
    recursive_print_kids(kid, indent+1);
  }
}

void printspace(int indent) {
  for (int i = 0; i < indent; i ++) {
    print(" ");
  }
}
