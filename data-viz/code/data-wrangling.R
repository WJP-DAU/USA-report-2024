## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
##
## Script:            USA Report - Data Wrangling
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
## 0.  Study Variables                                                                                     ----
##
## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

study_variables <- c(
  "USA_q18a","USA_q18b","USA_q18c","q43_G2","USA_Regis1","USA_Regis2","USA_midterm",
  "USA_paff3","USA_vote","USA_q21b_G1","USA_q21g_G1","USA_q21d_G2","USA_q21h_G2","USA_q21i_G2","USA_q21a_G1",
  "USA_q21e_G1","USA_q21f_G1","USA_q21h_G1","USA_q21a_G2","USA_q1k","USA_q2h","USA_q21c_G1","USA_q21d_G1",
  "USA_q21b_G2","USA_q21f_G2","USA_q21g_G2","USA_q21j_G2","USA_q21j_G1","USA_q21c_G2","USA_q21e_G2","USA_q20a",
  "USA_q20b","USA_q19a","USA_q19b","USA_q19c","USA_q19d","USA_q19e","USA_q19f","USA_q22a_G2","USA_q22b_G2",
  "USA_q22c_G2","USA_q22d_G2","USA_q22e_G2","USA_q22g","q1i","USA_q29","USA_q25","USA_q26","USA_q28","q50",
  "q51","q52","CAR_q73","CAR_q74","q45a_G1","q45b_G1","q46c_G2","q46f_G2","q46g_G2","q46c_G1","q46e_G2",
  "q46d_G2","q46f_G1","q46a_G2","q46d_G1","q46e_G1","q46h_G2","q2a","q2d","q2b","q2c","q2e","q2f","q2g",
  "q1a","q1d","q1b","q1c","q1e","q1f","q1g","q48a_G2","q48b_G2","q48c_G2","q48d_G2","q48a_G1","q48b_G1",
  "q48c_G1","q48d_G1","q18a","q18b","q18c","q18d","q18e","q18f","q48e_G2","q48f_G2","q48g_G2","q48e_G1",
  "q48f_G1","q48g_G1", "q48h_G1"
)

## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
##
## 1.  Data Bank                                                                                            ----
##
## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

DataBank <- function(data) {
  
  map_dfr(
    study_variables,
    function(target){
      
      bind_rows(
        
        # Total sample
        data %>%
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
        data %>%
          select(year, pparty, value = all_of(target)) %>%
          group_by(year, sample = pparty, value) %>%
          summarise(
            count = n(),
            .groups = "keep"
          ) %>%
          filter(!is.na(value) & !is.na(sample)) %>%
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
}

## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
##
## 2.  Data Points Extraction                                                                               ----
##
## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

getDataPoints <- function(pid, figure_map){
  
  # Extracting relevant parameters
  parameters <- lapply(
    c("target_vars"  = "var_id", 
      "reportValues" = "reportValues", 
      "grouping"     = "sample"),
    function(target){
      unlist(
        str_split(
          figure_map %>%
            filter(panelID %in% pid) %>%
            select(v = all_of(target)) %>%
            pull(v),
          pattern = ", "
        )
      )
    }
  )
  
  # Defining data2plot
  if (parameters["reportValues"] == "All"){
    data2plot <- data_bank %>%
      filter(
        variable %in% parameters[["target_vars"]] & 
          sample %in% parameters[["grouping"]]
      )
    
  } else {
    data2plot <- data_bank %>%
      filter(
        variable %in% parameters[["target_vars"]] & 
          value %in% parameters[["reportValues"]] & 
          sample %in% parameters[["grouping"]]
      )
  }
  data2plot <- data2plot %>%
    group_by(year, variable, sample) %>%
    summarise(
      values2plot = sum(perc, na.rm = T),
      .groups = "keep"
    )
  
  return(data2plot)
  
}
