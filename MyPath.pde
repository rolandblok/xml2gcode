import java.util.*; //<>//

float ACC = 0.01;

class MyPaths {

  // layers     1=set of paths  1=set of points  1=point
  HashMap<String, LinkedList<   LinkedList<      PVector>>> layered_paths_list;

  LinkedList<   LinkedList<      PVector>> cur_paths_list; // used to build the path while reading from SVG
  LinkedList<      PVector>  cur_path;                     // used to build the path while reading from SVG
  LinkedList<      MyLine>   cur_lines;                     // used to build the path while reading from SVG
  color active_color ;

  public MyPaths() {
    layered_paths_list = new HashMap<String, LinkedList<LinkedList<PVector>>>();
  }

  public void startLayer(String layer_id) {
    cur_paths_list = new LinkedList<   LinkedList<      PVector>> ();
    layered_paths_list.put(layer_id, cur_paths_list);

    cur_lines      = new LinkedList<MyLine>();
  }

  public void startPath(color c) {
    active_color = c;
    cur_path = new LinkedList<      PVector>();
    cur_paths_list.add(cur_path);
  }
  public void addPathPoint(PVector p) {
    PVector pa = p.copy();
    p.z = active_color;
    cur_path.add(p.copy());
  }

  public void addLine( PVector p1, PVector p2) {
    cur_lines.add(new MyLine(p1, p2));
  }
  public void endLayer(String layer_id) {
    if (cur_lines.size() > 0) {
      createPathsLayer(cur_lines, cur_paths_list);
    }
  }


  void draw(MyExporter svg)
  {
    //HashMap<String, LinkedList<   LinkedList<      PVector>>> layered_paths_list;

    for (Map.Entry<String, LinkedList<LinkedList<PVector>>> layer_paths : layered_paths_list.entrySet()) {
      String c_str =  layer_paths.getKey();
      LinkedList<LinkedList<PVector>> paths_list = layer_paths.getValue();
      svg.start_layer(c_str);
      for (LinkedList<PVector> path : paths_list) {
        Iterator<PVector> vec_it = path.iterator();
        PVector next = vec_it.next();
        svg.start_path((int)next.z, next);
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
    for (Map.Entry<String, LinkedList<LinkedList<PVector>>> layer_paths : layered_paths_list.entrySet()) {
      LinkedList<LinkedList<PVector>> paths_list = layer_paths.getValue();
      if (grid_min == null) {
        grid_min = new PVector();
        grid_max = new PVector();
        grid_min.x = paths_list.get(0).get(0).x;
        grid_max.x = paths_list.get(0).get(0).x;
        grid_min.y = paths_list.get(0).get(0).y;
        grid_max.y = paths_list.get(0).get(0).y;
      }
      for (LinkedList<PVector> path : paths_list) {
        for (PVector p : path) {
          if (p.x < grid_min.x)  grid_min.x = p.x;
          if (p.y < grid_min.y)  grid_min.y = p.y;
          if (p.x > grid_max.x)  grid_max.x = p.x;
          if (p.y > grid_max.y)  grid_max.y = p.y;
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
    for (Map.Entry<String, LinkedList<LinkedList<PVector>>> paths_list : layered_paths_list.entrySet()) {
      no_paths += paths_list.getValue().size();
    }
    return no_paths;
  }

  int getNoLines( )
  {
    int no_lines = 0;
    for (Map.Entry<String, LinkedList<LinkedList<PVector>>> paths_list : layered_paths_list.entrySet()) {

      for (LinkedList<PVector> path : paths_list.getValue()) {
        no_lines += path.size();
      }
    }
    return no_lines;
  }
  PVector getPathEndDir(LinkedList<PVector> path) {
    if (path.size() < 2) {
      return null;
    } else {
      return PVector.sub(path.getLast(), path.get(path.size()-2));
    }
  }
  PVector getPathFrontDir(LinkedList<PVector> path) {
    if (path.size() < 2) {
      return null;
    } else {
      return PVector.sub(path.get(0), path.get(1));
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



  void createPathsLayer(LinkedList<MyLine> visible_lines, LinkedList<LinkedList<PVector>> paths_list)
  {


    //Find length 0 lines, kill em.
    print("Culling zero length lines : from " + visible_lines.size() + " -> ");
    ListIterator<MyLine> zero_line_it = visible_lines.listIterator();
    while (zero_line_it.hasNext()) {
      MyLine line_it = zero_line_it.next();
      if (fEQ(line_it.ps[0].x, line_it.ps[1].x, ACC) &&
        fEQ(line_it.ps[0].y, line_it.ps[1].y, ACC)    ) {
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

      LinkedList<PVector> point_path;
      if (!connections_found) {
        point_path = new LinkedList<PVector>();
        paths_list.addLast(point_path);
        MyLine check_line = visible_lines.poll();
        point_path.addFirst(check_line.ps[0]);  // copy the points of the first line
        point_path.addFirst(check_line.ps[1]);
        visible_lines.remove(check_line);         // remove it from the list, and go for the next one
      } else {
        point_path = paths_list.getLast();
        connections_found = false;
      }

      Iterator<MyLine> line_it = visible_lines.iterator();
      LinkedList<MyLine> connecting_end_lines = new LinkedList<MyLine>();
      LinkedList<MyLine> connecting_front_lines = new LinkedList<MyLine>();
      while (line_it.hasNext()) {
        MyLine check_line = line_it.next();
        // see if the next line connects to the start or end.
        PVector start = point_path.getFirst();                       // get a reference to the front (for readability)
        PVector end   = point_path.getLast();       // get a reference to the back (for readability)

        if (fEQ(start.x, check_line.ps[0].x, ACC) &&
          fEQ(start.y, check_line.ps[0].y, ACC)) {
          // start connects to left (0) of iterated line
          connecting_front_lines.add(check_line);
          check_line.reverse();
        } else if (fEQ(start.x, check_line.ps[1].x, ACC) &&
          fEQ(start.y, check_line.ps[1].y, ACC)) {
          // start connects to right of iterated line
          connecting_front_lines.add(check_line);
        } else if (fEQ(end.x, check_line.ps[0].x, ACC) &&
          fEQ(end.y, check_line.ps[0].y, ACC)) {
          // start connects to left of iterated line
          connecting_end_lines.add(check_line);
        } else if (fEQ(end.x, check_line.ps[1].x, ACC) &&
          fEQ(end.y, check_line.ps[1].y, ACC)) {
          // start connects to right of iterated line
          connecting_end_lines.add(check_line);
          check_line.reverse();
        }
      }

      // add line to path : prefer the straight continue.
      if (connecting_end_lines.size() > 0) {
        Iterator<MyLine> con_end_lines_it = connecting_end_lines.iterator();
        MyLine best_end_line = con_end_lines_it.next();
        float best_dot = best_end_line.direction().dot(getPathEndDir(point_path));
        while (con_end_lines_it.hasNext()) {
          MyLine cur_end_line = con_end_lines_it.next();
          float cur_dot = cur_end_line.direction().dot(getPathEndDir(point_path));
          if (cur_dot > best_dot) {
            best_dot = cur_dot;
            best_end_line = cur_end_line;
          }
        }
        point_path.addLast(best_end_line.ps[1]);
        visible_lines.remove(best_end_line);
        connections_found = true;
      }
      if (connecting_front_lines.size() > 0) {
        Iterator<MyLine> con_front_lines_it = connecting_front_lines.iterator();
        MyLine best_front_line = con_front_lines_it.next();
        float best_dot = best_front_line.direction().dot(getPathFrontDir(point_path));
        while (con_front_lines_it.hasNext()) {
          MyLine cur_front_line = con_front_lines_it.next();
          float cur_dot = cur_front_line.direction().dot(getPathFrontDir(point_path));
          if (cur_dot > best_dot) {
            best_dot = cur_dot;
            best_front_line = cur_front_line;
          }
        }
        point_path.addFirst(best_front_line.ps[0]);
        visible_lines.remove(best_front_line);
        connections_found = true;
      }
    }
    println(" number of paths " + getNoPaths() );


    return;
  }
}



import java.util.*;

class MyLine {
  PVector[] ps;
  public static final String my_type =  "line";
  public color c;
  public PVector p; // get coordinate on the grid

  private void createMe(PVector p1_arg, PVector p2_arg, color c_arg) {
    ps = new PVector[2];
    ps[0] = p1_arg;
    ps[1] = p2_arg;
    c = c_arg;
    p = new PVector((ps[0].x + ps[1].x)/2, (ps[0].y + ps[1].y)/2);
  }

  MyLine(PVector p1_arg, PVector p2_arg, color c_arg) {
    createMe(p1_arg, p2_arg, c_arg);
  }
  MyLine(PVector p1_arg, PVector p2_arg) {
    this(p1_arg, p2_arg, color(0, 0, 0));
  }
  @Override
    public String toString() {
    return "MyLine p1:" + ps[0] + " ;p2:" + ps[1];
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
    if (obj instanceof MyLine) {
      MyLine l_check = (MyLine) obj;
      return (((ps[0].equals(l_check.ps[0])) && (ps[1].equals(l_check.ps[1]))) ||
        ((ps[0].equals(l_check.ps[1])) && (ps[1].equals(l_check.ps[0])))   );
    }
    return false;
  }
}
static boolean fEQ(float A, float B, float acc) {
  return abs(A-B) < acc;
}

// https://stackoverflow.com/questions/939874/is-there-a-java-library-with-3d-spline-functions
static PVector spline_vect(float t, PVector p0, PVector p1, PVector p2, PVector p3) {
  PVector p = new PVector(0,0);
  p.x = spline(t, p0.x, p1.x, p2.x, p3.x);
  p.y = spline(t, p0.y, p1.y, p2.y, p3.y);
  return p;
}
static float spline(float t, float p0, float p1, float p2, float p3) {

    return 0.5 * ((2 * p1) + (-p0 + p2) * t
            + (2 * p0 - 5 * p1 + 4 * p2 - p3) * (t * t) + (-p0 + 3 * p1 - 3
            * p2 + p3)
            * (t * t * t));
}
