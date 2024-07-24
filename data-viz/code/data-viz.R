## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
##
## Script:            USA Report - Data Viz
##
## Author(s):         Carlos A. Toruño Paniagua   (ctoruno@worldjusticeproject.org)
##
## Dependencies:      World Justice Project
##
## Creation date:     June 12th, 2024
##
##
## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
##
## Outline:                                                                                                 ----
##
## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
##
## 1.  Utilities                                                                                            ----
##
## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# Extarct Viz Parameters function
extractParameters <- function(pid, figure_map, outline){
  
  # Extracting general parameters
  parameters <- lapply(
    c("legend_labels" = "legend_text", 
      "color_codes"   = "legend_color",
      "sample"        = "sample",
      "chart_id"      = "id",
      "variables"     = "var_id",
      "plot_function" = "type"),
    
    function(item){
      
      unlist(
        str_split(
          figure_map %>%
            filter(panelID %in% pid) %>%
            select(v = all_of(item)) %>%
            pull(v),
          pattern = ", "
        )
      )
    }
  )
  
  # Defining color palette
  parameters[["color_palette"]] <- parameters[["color_codes"]]
  
  if (all(parameters[["legend_labels"]] != "None")) {
    names(parameters[["color_palette"]]) <- parameters[["legend_labels"]]
  }
  
  if (pid %in% c(
    # "Figure_17_C", "Figure_17_D",                # Corruption over time (NO LONGER IN OUTLINE)
    "Figure_7_C", "Figure_7_D"                     # Trust over time
    # "Figure_23_A", "Figure_23_B", "Figure_23_C"  # Criminal Justice Actors (NO LONGER IN OUTLINE)
  )){
    names(parameters[["color_palette"]]) <- parameters[["variables"]]
  }
  
  # Extracting macro type
  parameters[["HTML_macro"]] <- outline %>%
    separate_wider_delim(
      charts, 
      names = c("charts1", "charts2"), 
      delim = ", ", 
      too_few = "align_start"
    ) %>%
    filter(
      charts1 %in% parameters[["chart_id"]] | charts2 %in% parameters[["chart_id"]]
    ) %>%
    distinct(macro, .keep_all = T) %>%
    pull(macro)
  
  # Manually modifying the HTML macro for bars, these will have a different dimension for visualization purposes
  # Design will used them as inputs for creating a single panel infographic
  if (parameters[["chart_id"]] %in% c("Figure_2", "Figure_12")){
    parameters[["HTML_macro"]] == "tripanel"
  }
    
  return(parameters)
}

# Saving function
saveIT.fn <- function(chart, fig, pid, w, h) {
  ggsave(plot   = chart,
         file   = file.path(path2main, 
                            "data-viz/outputs",
                            fig,
                            paste0(pid, ".svg"),
                            fsep = "/"), 
         width  = w, 
         height = h,
         units  = "mm",
         dpi    = 72,
         device = "svg")
} 


## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
##
## 2.  Visualizer                                                                                           ----
##
## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

callVisualizer <- function(pid, figure_map, outline){
  
  print(paste("Generating ", pid))
  
  # Defining data & parameters
  data       <- data_points[[pid]]
  parameters <- extractParameters(pid, figure_map, outline)
  
  # Calling visualizer
  if(parameters[["plot_function"]] == "Bars"){
    viz <- wjp_bars(
      data       = data,     
      labels     = "labels",
      lab_pos    = "label_position", 
      target     = "values2plot",        
      grouping   = "sample",      
      colors     = "sample",        
      cvec       = parameters[["color_palette"]],            
      direction  = "horizontal",         
      ptheme     = WJP_theme()
    )
  }
  
  if(parameters[["plot_function"]] == "Lines"){
    viz <- wjp_lines(
      data           = data,                    
      target         = "values2plot",             
      grouping       = "year",
      ngroups        = data$variable,                 
      labels         = "labels",
      colors         = "variable",
      cvec           = parameters[["color_palette"]],
      custom.axis    = T,
      x.breaks       = seq(2014, 2024, 2),
      x.labels       = paste0("'", str_sub(seq(2014, 2024, 2), 
                                           start = -2)),
      sec.ticks      = seq(2014, 2024, 1),
      ptheme         = WJP_theme()
    )
  }
  
  if(parameters[["plot_function"]] == "Radar"){
    viz <- wjp_radar(
      data       = data,
      axis_var   = "variable",
      target_var = "values2plot",
      label_var  = "labels",
      order_var  = "order",
      color_var  = "sample",
      colors     = parameters[["color_palette"]],
      maincat    = "Democrats"
    )
  }
  
  if(parameters[["plot_function"]] == "Dots"){
    viz <- wjp_dots(
      data        = data,
      target      = "values2plot",
      sample_size = "total",
      grouping    = "sample",
      labels      = "labels",
      cvec        = parameters[["color_palette"]],
      ptheme      = WJP_theme()
    )
  }
  
  if(parameters[["plot_function"]] == "Gauge"){
    
    # Standardizing theoretical order for Gauge Charts
    factor_order <- c("Positive Statement", "Neither", "Negative Statement")
    viz <- wjp_gauge(
      data         = data,
      target       = "values2plot",
      colors       = "value",
      cvec         = parameters[["color_palette"]],
      labels       = "labels",
      factor_order = factor_order,
      ptheme       = WJP_theme()
    )
  }
    
  if(parameters[["plot_function"]] == "Edgebars"){
    viz <- wjp_edgebars(
        data         = data,
        y_value      = "values2plot",
        x_var        = "variable",
        label_var    = "labels",
        color_var    = "sample",
        nudge_lab    = 4.5,
        bar_colors   = parameters[["color_palette"]],
        margin_top   = 15,
        bar_width    = 0.5,
        ptheme       = WJP_theme()
      )
  }
  
  if(parameters[["plot_function"]] == "Slope"){
    viz <- wjp_slope(
        data     = data,
        target   = "values2plot",
        grouping = "year",
        ngroups  = data$sample,
        colors   = "sample",
        cvec     = parameters[["color_palette"]],
        labels   = "labels",
        repel    = TRUE,
        ptheme   = WJP_theme()
    )
  }
  
  if(parameters[["plot_function"]] == "Dumbbells"){
    
    if (pid %in% c("Figure_3_2_A")){
      r = "sample"
    } else {
      r = "labels"
    }
    
    viz <- wjp_dumbbells(
      data    = data,
      target  = "values2plot",
      rows    = r,
      color   = "year",
      cgroups = c("2021", "2024"),
      cvec    = parameters[["color_palette"]],
      ptheme  = WJP_theme()
    )
  }
  
  # Defining plot dimensions
  if (parameters[["HTML_macro"]] == "singlepanel"){
    h = 183.1106
    w = 189.7883
  }
  if (parameters[["HTML_macro"]] == "bipanel"){
    h = 68.88612
    w = 189.7883
  }
  if (parameters[["HTML_macro"]] == "tripanel"){
    h = 49.90729
    w = 189.7883
  }
  if (parameters[["HTML_macro"]] == "quadpanel"){
    h = 76.9697
    w = 91.37955
  }
  if (parameters[["HTML_macro"]] == "dash"){
    h = 74.86094
    w = 82.59305
    
  }
  if (parameters[["HTML_macro"]] == "pentapanel"){
    h = 40.26276
    w = 63.26276
  }
  if (parameters[["HTML_macro"]] == "hexpanel"){
    h = 45.68977
    w = 90.67663
  }
  
  # Saving plot as SVG
  saveIT.fn(chart = viz, 
            fig   = parameters[["chart_id"]], 
            pid   = pid, 
            w     = w, 
            h     = h)
  
  return(viz)
  
}
