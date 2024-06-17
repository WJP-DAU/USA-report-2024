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
## 2.  Labellers                                                                                             ----
##
## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

labelVars <- function(input){
  
  output <- case_when(
    
    # Fundamental Freedoms
    input == "q46c_G2"      ~ paste("**People** can <br> express opinions<br>against the government"),
    input == "q46f_G2"      ~ paste("**Civil society** <br>organizations can <br> express opinions",
                                    "against<br>the government"),
    input == "q46g_G2"      ~ paste("**Political parties**<br>can express opinions<br>",
                                    "against the<br>government"),
    input == "q46c_G1"      ~ paste("**The media**<br>can express opinions<br>",
                                    "against the<br>government"),
    input == "q46e_G2"      ~ paste("The media<br>can **expose cases<br>of corruption**"),
    input == "q46d_G2"      ~ paste("People can<br>**attend community<br>meetings**"),
    input == "q46f_G1"      ~ paste("People can<br>**join any political<br>organization**"),
    input == "q46a_G2"      ~ paste("People can<br>**organize around an<br>issue or petition**"),
    input == "q46d_G1"      ~ paste("Local government<br>officials **are elected<br>through a clean<br>process**"),
    input == "q46e_G1"      ~ paste("People can<br>**vote freely** without<br>feeling harassed<br>or pressured"),
    input == "q46h_G2"      ~ paste("Religious minorities<br>can **observe their<br>holy days**"),
    
    # USA Elections - TRUST
    input == "USA_q19a"     ~ "Local Poll Workers",
    input == "USA_q19b"     ~ "State-level Election<br>Administrators",
    input == "USA_q19c"     ~ "State and Local<br>Courts",
    input == "USA_q19d"     ~ "Congress",
    input == "USA_q19e"     ~ "Federal and Appeal<br>Courts",
    input == "USA_q19f"     ~ "Supreme Court",
    
    # USA Elections - Supreme Court set
    input == "USA_q22a_G2"  ~ "Criminal cases<br>against presidential<br>candidates.",
    input == "USA_q22b_G2"  ~ "Absentee ballot<br>rejection.",
    input == "USA_q22c_G2"  ~ "Voting rights<br>cases.",
    input == "USA_q22d_G2"  ~ "Cases of voter<br>",
    input == "USA_q22e_G2"  ~ "Cases of vote<br>recounts.",
    input == "USA_q22g"     ~ "A contested<br>presidential election.",
    
  )
  
  return(output)
}

labelVals <- function(input){
  output <- paste0(format(round(input, 0),
                          nsmall = 0),
                   "%")
  
  return(output)
}


## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
##
## 3.  Data Points Extraction                                                                               ----
##
## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

getDataPoints <- function(pid, figure_map){
  
  # Extracting relevant parameters
  parameters <- lapply(
    c("target_vars"  = "var_id", 
      "reportValues" = "reportValues", 
      "grouping"     = "sample",
      "type"         = "type",
      "label_var"    = "label_at",
      "time_frame"   = "years"),
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
  
  if (parameters[["time_frame"]] == "All"){
    parameters[["time_frame"]] <- c(2014, 2016, 2017, 2018, 2021, 2024)
  }
  
  # Defining data2plot
  if (parameters["reportValues"] == "All"){
    data2plot <- data_bank %>%
      filter(
        variable %in% parameters[["target_vars"]] & 
          sample %in% parameters[["grouping"]] &
          year   %in% parameters[["time_frame"]]
      )
    
  } else {
    data2plot <- data_bank %>%
      filter(
        variable %in% parameters[["target_vars"]] & 
          value  %in% parameters[["reportValues"]] & 
          sample %in% parameters[["grouping"]] &
          year   %in% parameters[["time_frame"]]
      )
  }
  
  data2plot <- data2plot %>%
    group_by(year, variable, sample) %>%
    summarise(
      values2plot = sum(perc, na.rm = T),
      .groups = "keep"
    )
  
  # Calling labelers
  if (parameters["label_var"] == "Variables"){
    data2plot <- data2plot %>% 
      mutate(
        labels = labelVars(variable)
      )
    
    # Special labeling for Radars
    if (parameters["type"] == "Radar"){
      data2plot <- data2plot %>%
        mutate(
          across(labels,
                 ~paste0("<span style='color:#524F4C;font-size:3.514598mm;font-weight:bold'>",
                         labels,
                         "</span>"))
        )
    }
    
  } else if (parameters["label_var"] == "Values"){
    data2plot <- data2plot %>%
      mutate(
        labels = labelVals(values2plot)
      )
    
    
  } else {
    data2plot <- data2plot
  }
  
  return(data2plot)
  
}
