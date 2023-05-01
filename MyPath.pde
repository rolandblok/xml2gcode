import java.util.*; //<>// //<>//

float ACC = 0.01;

class MyPaths {

  // layers     1=set of paths  1=set of lines  1=line
  HashMap<String, LinkedList<   LinkedList<      MyLine>>> layered_paths_list;

  LinkedList<   LinkedList<      MyLine>> cur_paths_list; // used to build the path while reading from SVG
  LinkedList<      MyLine>   cur_lines;                     // used to build the path while reading from SVG
  color active_color ;

  public MyPaths() {
    layered_paths_list = new HashMap<String, LinkedList<LinkedList<MyLine>>>();
  }

  public void startLayer(String layer_id) {
    if (!layered_paths_list.containsKey(layer_id)) {
      println("new  layer with name : " + layer_id);
      cur_paths_list = new LinkedList<   LinkedList<      MyLine>> ();
      layered_paths_list.put(layer_id, cur_paths_list);
  
      cur_lines      = new LinkedList<MyLine>();
    } else {
      println("adding to existing layer with same name : " + layer_id);
    }
    
  }

  public void startPath(color c) {
    active_color = c;
    //LinkedList<      MyLine>  cur_path = new LinkedList<      MyLine>();
    //cur_paths_list.add(cur_path);
  }

  public void addLine(MyLine l) {
    //println("add line " +l.toString());
    cur_lines.add(l);
  }
  
  public void endLayer(String layer_id) {
    if (cur_lines.size() > 0) {
      println("createPathsLayer for " + layer_id);
      createPathsLayer(cur_lines, cur_paths_list);
    }
  }


  void draw(MyExporter svg)
  {
    //HashMap<String, LinkedList<   LinkedList<      PVector>>> layered_paths_list;

    for (Map.Entry<String, LinkedList<LinkedList<MyLine>>> layer_paths : layered_paths_list.entrySet()) {
      String c_str =  layer_paths.getKey();
      LinkedList<LinkedList<MyLine>> paths_list = layer_paths.getValue();
      svg.start_layer(c_str);
      for (LinkedList<MyLine> path : paths_list) {
        Iterator<MyLine> vec_it = path.iterator();
        MyLine next = vec_it.next();
        svg.start_path((int)next.p_start().z, next.p_start());
        svg.add_path( next);
        while (vec_it.hasNext()) {
          svg.add_path( vec_it.next());
        }
        svg.end_path();
      }
      svg.end_layer();
    }
  }

  void getBounds(PVector pix_min, PVector pix_max) {
    PVector grid_min = null;
    PVector grid_max = null;
    for (Map.Entry<String, LinkedList<LinkedList<MyLine>>> layer_paths_entries : layered_paths_list.entrySet()) {
      LinkedList<LinkedList<MyLine>> paths_list = layer_paths_entries.getValue();
      println("layer "+ layer_paths_entries.getKey());
      if (grid_min == null) {
        grid_min = new PVector();
        grid_max = new PVector();
        LinkedList<MyLine> line_list = paths_list.get(0);
        MyLine line = line_list.get(0);
        float x = line.p_start().x;
        grid_min.x = min(paths_list.get(0).get(0).p_start().x, paths_list.get(0).get(0).p_end().x);
        grid_max.x = max(paths_list.get(0).get(0).p_start().x, paths_list.get(0).get(0).p_end().x);
        grid_min.y = min(paths_list.get(0).get(0).p_start().y, paths_list.get(0).get(0).p_end().y);
        grid_max.y = max(paths_list.get(0).get(0).p_start().y, paths_list.get(0).get(0).p_end().y);
      }
      for (LinkedList<MyLine> path : paths_list) {
          for (MyLine l : path) {
            grid_min.x = min(grid_min.x, l.p_end().x);
            grid_max.x = max(grid_max.x, l.p_end().x);
            grid_min.y = min(grid_min.y, l.p_end().y);
            grid_max.y = max(grid_max.y, l.p_end().y);
          }
      }
      
    }

    PVector Smin = grid_min;
    PVector Smax = grid_max;
    pix_min.set(Smin);
    pix_max.set(Smax);
  }


  int getNoPaths( )
  {
    int no_paths = 0;
    for (Map.Entry<String, LinkedList<LinkedList<MyLine>>> paths_list : layered_paths_list.entrySet()) {
      no_paths += paths_list.getValue().size();
    }
    return no_paths;
  }

  int getNoLines( )
  {
    int no_lines = 0;
    for (Map.Entry<String, LinkedList<LinkedList<MyLine>>> paths_list : layered_paths_list.entrySet()) {

      for (LinkedList<MyLine> path : paths_list.getValue()) {
        no_lines += path.size();
      }
    }
    return no_lines;
  }
  PVector getPathEndDir(LinkedList<MyLine> path) {
    if (path.size() < 1) {
      return null;
    } else {
      return path.getLast().direction();
    }
  }
  PVector getPathFrontDir(LinkedList<MyLine> path) {
    if (path.size() < 1) {
      return null;
    } else {
      return path.get(0).direction();
    }
  }

  int removeDoubleLines(LinkedList<MyLine> visible_lines)
  {
    int no_lines_start = visible_lines.size();
    ListIterator<MyLine> outer_it = visible_lines.listIterator();
    while (outer_it.hasNext()) {
      //for(ListIterator<MyLine> outer = visible_lines.listIterator(); outer.hasNext() ; ) {
      MyLine line_outer = outer_it.next();
      ListIterator<MyLine> inner_it = visible_lines.listIterator(outer_it.nextIndex());
      //for(ListIterator<MyLine> inner = visible_lines.listIterator(outer.nextIndex()); inner.hasNext(); ) {
      while (inner_it.hasNext()) {
        MyLine line_inner = inner_it.next();
        if (line_inner.equals(line_outer)) {
          outer_it.remove();

          //cout << ".";
          break;
        }
      }
    }

    return no_lines_start - visible_lines.size();
  }



  void createPathsLayer(LinkedList<MyLine> visible_lines, LinkedList<LinkedList<MyLine>> paths_list)
  {


    //Find length 0 lines, kill em.
    print(" Culling zero length lines : from " + visible_lines.size() + " -> ");
    ListIterator<MyLine> zero_line_it = visible_lines.listIterator();
    while (zero_line_it.hasNext()) {
      MyLine line_it = zero_line_it.next();
      if (fEQ(line_it.p_start().x, line_it.p_end().x, ACC) &&
        fEQ(line_it.p_start().y, line_it.p_end().y, ACC)    ) {
        zero_line_it.remove();
      }
    }
    println(""+visible_lines.size());

    //Find length double lines, kill em.
    removeDoubleLines(visible_lines);
    println(" Culling double lines to " + visible_lines.size() );

    boolean connections_found = false;
    while (visible_lines.size() > 0) {
      // create a line list and put it to the path list

      LinkedList<MyLine> line_path;
      if (!connections_found) {
        line_path = new LinkedList<MyLine>();
        paths_list.addLast(line_path);
        
        MyLine check_line = visible_lines.poll();
        line_path.addFirst(check_line);          // copy the first line
        visible_lines.remove(check_line);         // remove it from the list, and go for the next one
      } else {
        line_path = paths_list.getLast();
        connections_found = false;
      }

      // we look for all lines that connect to front or end : we do this to select the most straight connection
      Iterator<MyLine> line_it = visible_lines.iterator();
      LinkedList<MyLine> connecting_end_lines   = new LinkedList<MyLine>();
      LinkedList<MyLine> connecting_front_lines = new LinkedList<MyLine>();
      while (line_it.hasNext()) {
        MyLine check_line = line_it.next();
        // see if the next line connects to the start or end.
        PVector start = line_path.getFirst().p_start();       // get a reference to the front (for readability)
        PVector end   = line_path.getLast().p_end();       // get a reference to the back (for readability)

        // find lines with equal point to begin or end of list.
        if (fEQ(start.x, check_line.p_start().x, ACC) &&
          fEQ(start.y, check_line.p_start().y, ACC)) {
          // start connects to left (0) of iterated line
          connecting_front_lines.add(check_line);
          check_line.reverse();
        } else if (fEQ(start.x, check_line.p_end().x, ACC) &&
          fEQ(start.y, check_line.p_end().y, ACC)) {
          // start connects to right of iterated line
          connecting_front_lines.add(check_line);
        } else if (fEQ(end.x, check_line.p_start().x, ACC) &&
          fEQ(end.y, check_line.p_start().y, ACC)) {
          // start connects to left of iterated line
          connecting_end_lines.add(check_line);
        } else if (fEQ(end.x, check_line.p_end().x, ACC) &&
          fEQ(end.y, check_line.p_end().y, ACC)) {
          // start connects to right of iterated line
          connecting_end_lines.add(check_line);
          check_line.reverse();
        }
      }

      // add line to path : prefer the straight continue to really connect.
      if (connecting_end_lines.size() > 0) {
        Iterator<MyLine> con_end_lines_it = connecting_end_lines.iterator();
        MyLine best_end_line = con_end_lines_it.next();
        float best_dot = best_end_line.direction().dot(getPathEndDir(line_path));
        while (con_end_lines_it.hasNext()) {
          MyLine cur_end_line = con_end_lines_it.next();
          float cur_dot = cur_end_line.direction().dot(getPathEndDir(line_path));
          if (cur_dot > best_dot) {
            best_dot = cur_dot;
            best_end_line = cur_end_line;
          }
        }
        line_path.addLast(best_end_line);
        visible_lines.remove(best_end_line);
        connections_found = true;
      }
      if (connecting_front_lines.size() > 0) {
        Iterator<MyLine> con_front_lines_it = connecting_front_lines.iterator();
        MyLine best_front_line = con_front_lines_it.next();
        float best_dot = best_front_line.direction().dot(getPathFrontDir(line_path));
        while (con_front_lines_it.hasNext()) {
          MyLine cur_front_line = con_front_lines_it.next();
          float cur_dot = cur_front_line.direction().dot(getPathFrontDir(line_path));
          if (cur_dot > best_dot) {
            best_dot = cur_dot;
            best_front_line = cur_front_line;
          }
        }
        line_path.addFirst(best_front_line);
        visible_lines.remove(best_front_line);
        connections_found = true;
      }
    }
    println(" number of paths " + getNoPaths() );
    


    return;
  }
}
