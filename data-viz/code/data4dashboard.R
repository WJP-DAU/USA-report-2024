get_data4dash <- function() {
  
  data_bank <- map_dfr(
    study_variables,
    function(target){
      
      bind_rows(
        
        # Total sample
        master_data %>%
          select(year, value = all_of(target)) %>%
          group_by(year, value) %>%
          summarise(
            count = n(),
            .groups = "keep"
          ) %>%
          filter(
            !is.na(value) & !(value %in% c(98, 99))
          ) %>%
          mutate(
            variable = target
          ) %>%
          group_by(year, variable) %>%
          mutate(
            total  = sum(count, na.rm = T),
            perc   = count/total,
            sample = "Total"
          ) %>%
          relocate(
            all_of(c("variable", "sample")),
            .after = year
          ),
        
        # Political Affiliation Sample
        master_data %>%
          select(year, pparty, value = all_of(target)) %>%
          group_by(year, sample = pparty, value) %>%
          summarise(
            count = n(),
            .groups = "keep"
          ) %>%
          filter(
            !is.na(value) & !is.na(sample) & !(value %in% c(98, 99))
          ) %>%
          mutate(
            variable = target
          ) %>%
          group_by(year, sample, variable) %>%
          mutate(
            total  = sum(count, na.rm = T),
            perc   = count/total,
          ) %>%
          relocate(
            all_of(c("variable", "sample")),
            .after = year
          ),
        
        # Ethnicity Sample
        master_data %>%
          select(year, ethnicity_binary, value = all_of(target)) %>%
          group_by(year, sample = ethnicity_binary, value) %>%
          summarise(
            count = n(),
            .groups = "keep"
          ) %>%
          filter(
            !is.na(value) & !is.na(sample) & !(value %in% c(98, 99))
          ) %>%
          mutate(
            variable = target
          ) %>%
          group_by(year, sample, variable) %>%
          mutate(
            total  = sum(count, na.rm = T),
            perc   = count/total,
          ) %>%
          relocate(
            all_of(c("variable", "sample")),
            .after = year
          )
        
        
      ) %>%
        mutate(
          perc = perc*100
        )
    }
  )
  
  # Pivoting figure map to allow for individual variables
  figmap <- figure_map %>%
    select(var_id, chart_title, chart_subtitle, reportValues, panel_title, panel_subtitle) %>%
    separate(
      var_id, 
      into = paste0("var_", seq(1,11)), 
      sep  = ", "
    ) %>%
    pivot_longer(
      starts_with("var_"),
      names_to  = "to_discard",
      values_to = "var_id" 
    ) %>%
    select(var_id, reportValues, chart_title, chart_subtitle, panel_title, panel_subtitle) %>%
    filter(!is.na(var_id))
  
  # Getting data for dashboard
  data4dashboard <- map_dfr(
    study_variables,
    function(target_var){
      
      # Defining reporting values
      reportValues <- figmap %>%
        filter(var_id == target_var) %>%
        distinct(var_id, .keep_all = T) %>%
        pull(reportValues)
      
      if(length(reportValues) == 0){
        return(NULL)
      }
      
      # Getting data
      if (reportValues == "All"){
        
        targetData <- data_bank %>%
          filter(
            variable == target_var
          ) %>%
          select(
            year, variable, sample, answer = value, percentage = perc
          )
        
        labels_attr <- attr(master_data[[target_var]], "labels")
        has_labels  <- !is.null(labels_attr)
        
        # if (has_labels == T){
        #   targetData <- targetData %>%
        #     mutate(
        #       answer = labelValue(answer)
        #     )
        # }
        
      } else {
        
        reportValues <- unlist(
          str_split(
            reportValues,
            pattern = ", "
          )
        )
        
        subtitle <- unlist(
          str_split(
            figmap %>%
              filter(var_id == target_var) %>%
              distinct(var_id, .keep_all = T) %>%
              pull(reportValues),
            pattern = ", "
          )
        )
        
        targetData <- data_bank %>%
          mutate(
            value = as.character(value)
          ) %>%
          filter(
            (variable == target_var) & (value %in% reportValues)
          ) %>%
          select(
            year, variable, sample, answer = value, percentage = perc
          ) %>%
          group_by(year, variable, sample) %>%
          summarise(
            percentage = sum(percentage, na.rm = T),
            .groups = "keep"
          ) %>%
          ungroup() %>%
          mutate(
            answer = "See Metadata"
          )
        
      }
      
      targetData <- targetData %>%
        left_join(
          figmap %>%
            select(-reportValues),
          by = c("variable" = "var_id")
        ) %>%
        mutate(
          answer = as.character(answer)
        )
      
      return(targetData)
    }
  )
  
  write.csv(
    data4dashboard,
    file.path(
      path2main,
      "data-viz/outputs/data4app.csv"
    )
  )
  
  return(data4dashboard)
  
}



  
