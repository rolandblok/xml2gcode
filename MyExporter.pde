float A4_PORTRAIT_WIDTH =  210.;
float A4_PORTRAIT_HEIGHT = 297.;
float A3_PORTRAIT_WIDTH =  297.;
float A3_PORTRAIT_HEIGHT = 420.;
float PADDING_FRAC       = 0.05;

abstract class  MyExporter{



  abstract void finalize() ;


  abstract void start_layer(String l_id) ;
  abstract void end_layer();

  abstract void start_path(String c, PVector point_arg);

  abstract void add_path(PVector point_arg);

  abstract void end_path();

  abstract void fsave(String path_str) ;
  
}
  
