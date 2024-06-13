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


extractParameters <- function(pid, figure_map, outline){
  
  # Extracting parameters
  parameters <- lapply(
    c("legend_labels" = "legend_text", 
      "color_codes"   = "legend_color",
      "sample"        = "sample",
      "chart_id"      = "id",
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
  names(parameters[["color_palette"]]) <- parameters[["legend_labels"]]
  
  # Extracting macro type
  parameters["HTML_macro"] <- outline %>%
    filter(
      id %in% parameters[["chart_id"]]
    ) %>%
    pull(macro)
    
  return(parameters)
}

callVisualizer <- function(pid, figure_map, outline){
  
  # Defining data & parameters
  data       <- data_points[[pid]]
  parameters <- extractParameters(pid, figure_map, outline)
  
  # Calling visualizer
  if(parameters[["plot_function"]] == "Bars"){
    viz <- wjp_bars(
      data       = data,              
      target     = "values2plot",        
      grouping   = "sample",      
      colors     = "sample",        
      cvec       = parameters[["color_palette"]],            
      direction  = "horizontal",         
      ptheme     = USA_theme()
    )
  }
  
  return(viz)
  
}


