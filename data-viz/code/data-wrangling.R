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
  "USA_paff3","USA_vote","USA_q20a",
  "USA_q20b","USA_q19a","USA_q19b","USA_q19c","USA_q19d","USA_q19e","USA_q19f","USA_q22a_G2","USA_q22b_G2",
  "USA_q22c_G2","USA_q22d_G2","USA_q22e_G2","USA_q22g","q1i","USA_q29","USA_q25","USA_q26","USA_q28","q50",
  "q51","q52","CAR_q73","CAR_q74","q45a_G1","q45b_G1","q46c_G2","q46f_G2","q46g_G2","q46c_G1","q46e_G2",
  "q46d_G2","q46f_G1","q46a_G2","q46d_G1","q46e_G1","q46h_G2","q2a","q2d","q2b","q2c","q2e","q2f","q2g",
  "q1a","q1d","q1b","q1c","q1e","q1f","q1g","q48a_G2","q48b_G2","q48c_G2","q48d_G2","q48a_G1","q48b_G1",
  "q48c_G1","q48d_G1","q18a","q18b","q18c","q18d","q18e","q18f","q48e_G2","q48f_G2","q48g_G2","q48e_G1",
  "q48f_G1","q48g_G1", "q48h_G1", "USA_q22a_G1", "USA_q22b_G1", "USA_q22c_G1", "USA_q22d_G1", "USA_q22e_G1",
  "q45c_G1",
  "USA_q21b_G1","USA_q21g_G1","USA_q21d_G2","USA_q21h_G2","USA_q21i_G2","USA_q21a_G1",
  "USA_q21e_G1","USA_q21f_G1","USA_q21h_G1","USA_q21a_G2","USA_q1k","USA_q2h","USA_q21c_G1","USA_q21d_G1",
  "USA_q21b_G2","USA_q21f_G2","USA_q21g_G2","USA_q21j_G2","USA_q21j_merge","USA_q21c_G2"
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
    
    # Electoral Integrity - Panel A: Electoral Process
    input == "USA_q21b_G2"  ~ "The process prevents fraud",
    input == "USA_q21g_G1"  ~ "The process is safe from cyberattacks",
    input == "USA_q21h_G2"  ~ "The process is free of corruption",
    input == "USA_q21i_G2"  ~ "The process is free from foreign interference",
    input == "USA_q21c_G2"  ~ "Electoral rules are impartial",
    
    # Electoral Integrity - Panel B: Voting rights
    input == "USA_q21a_G1"  ~ "Ballot secrecy is guaranteed",
    input == "USA_q21a_G2"  ~ "Voting access is equal for all citizens",
    input == "USA_q21b_G1"  ~ "People are able to vote conveniently",
    input == "USA_q21h_G1"  ~ "Political entry barriers are low",
    
    # Electoral Integrity - Panel C: Electoral Authorities
    input == "USA_q21e_G1"  ~ "The electoral authority is impartial and effective",
    input == "USA_q21f_G1"  ~ "Checks and balances ensure electoral confidence",
    input == "USA_q1k"      ~ "Election officials are trustworthy",
    input == "USA_q2h"      ~ "Election officials are free of corruption",
    input == "USA_q21g_G2"  ~ "Complaint mechanisms are transparent and impartial",
    
    # Electoral Integrity - Panel D: Electoral Results and Vote Counting
    input == "USA_q21c_G1"  ~ "Votes are counted accurately",
    input == "USA_q21d_G1"  ~ "Monitors can oversee voting and counting",
    input == "USA_q21f_G2"  ~ "Election results are transparently available",
    input == "USA_q21j_G2"  ~ "Losing candidates accept the results as legitimate",
    input == "USA_q21j_merge"  ~ "Candidates and parties avoid misinformation",
    
    # Police - Panel A: Trust and Safety
    input == "q1d"         ~ "Trust the police",
    input == "q48a_G2"     ~ "Resolve security problems in  the community",
    input == "q48b_G2"     ~ "Help them feel safe",
    input == "q48c_G2"     ~ "Are available to help when needed",
    input == "q48d_G2"     ~ "Treat all people with respect",
    
    # Police - Panel B: Accountability and Due Process
    input == "q48a_G1"     ~ "Act lawfully",
    input == "q48b_G1"     ~ "Perform effective and lawful investigations",
    input == "q48c_G1"     ~ "Respect the rights of suspects",
    input == "q48d_G1"     ~ "Are held accountable for violating laws",
    
    # Police - Panel C: Discrimination
    input == "q18a" ~ "Socioeconomic status",
    input == "q18b" ~ "Gender",
    input == "q18c" ~ "Ethnicity",
    input == "q18d" ~ "Religion",
    input == "q18e" ~ "Citizenship status",
    input == "q18f" ~ "Sexual orientation",
    
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
  
  if (parameters[["time_frame"]][1] == "All"){
    parameters[["time_frame"]] <- c(2013, 2014, 2016, 2017, 2018, 2021, 2024)
  }
  
  # Filtering data
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
  
  if (parameters[["type"]] == "Dots") {
    data2plot <- data2plot %>%
      group_by(year, variable, sample) %>%
      summarise(
        values2plot = sum(perc, na.rm = TRUE),
        total   = first(total),
        .groups = "keep"
      )
  }
  
  if (parameters[["type"]] == "Gauge"){  # Special grouping for Gauge Charts
    
    if (parameters["target_vars"] %in% c("q52")) {
      positive_statement <- c(1,2)
      negative_statement <- c(3,4)
    } else {
      positive_statement <- c(3,4)
      negative_statement <- c(1,2)
    }
    
    data2plot <- data2plot %>%
      mutate(
        value = case_when(
          value %in% positive_statement ~ "Positive Statement",
          value %in% c(5)               ~ "Neither",
          value %in% negative_statement ~ "Negative Statement"
        )
      ) %>%
      group_by(year, variable, sample, value) %>%
      summarise(
        values2plot = sum(perc, na.rm = T),
        .groups = "keep"
      )
  }
  
  if (!parameters[["type"]] %in% c("Dots", "Gauge")){
    data2plot <- data2plot %>%
      group_by(year, variable, sample) %>%
      summarise(
        values2plot = sum(perc, na.rm = T),
        .groups = "keep"
      )
  }
  
  if (parameters[["type"]] == "Bars"){
    data2plot <- data2plot %>%
      mutate(
        label_position = values2plot + 3
      )
  }
  
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
          democrat_value   = if_else(sample == "Democrats", values2plot, NA_real_),
          republican_value = if_else(sample == "Republicans", values2plot, NA_real_)
        ) %>%
        group_by(variable) %>%
        mutate(
          democrat_value   = first(democrat_value, na_rm = T),
          republican_value = first(republican_value, na_rm = T),
          across(
            ends_with("_value"),
            ~paste0(
              format(
                round(.x, 0),
                nsmall = 0
              ),
              "%"
            )
          ),
          across(labels,
                 ~paste0(
                   "<span style='color:#003b8a;font-size:4.217518mm'>",democrat_value,"</span>",
                   "<span style='color:#524F4C;font-size:4.217518mm'> | </span>",
                   "<span style='color:#fa4d57;font-size:4.217518mm'>",republican_value,"</span><br>",
                   "<span style='color:#524F4C;font-size:3.514598mm;font-weight:bold'>",
                   labels,
                   "</span>"
                 )
          )
        ) %>% 
        group_by(year, sample) %>%
        mutate(
          order = row_number()
        )
    }
  }
  
  if (parameters["label_var"] == "Values"){
    data2plot <- data2plot %>%
      mutate(
        labels = labelVals(values2plot)
      )
  }
  
  if (parameters["type"] == "Dumbbells"){
    data2plot <- data2plot %>%
      mutate(
        labpos = case_when(
          year == 2018 & sample == "Democrats"   ~ values2plot - 5,
          year == 2018 & sample == "Republicans" ~ values2plot + 5,
          year == 2024 & sample == "Democrats"   ~ values2plot + 5,
          year == 2024 & sample == "Republicans" ~ values2plot - 5
        )
      )
  }
  
  if (parameters["type"] == "Edgebars"){
    
    if (pid %in% c("Figure_11_A")){
      data2plot <- data2plot %>%
        mutate(
          order = case_when(
            variable == "USA_q1k"     ~ 5,
            variable == "USA_q21g_G2" ~ 4,
            variable == "USA_q21f_G1" ~ 3,
            variable == "USA_q21e_G1" ~ 2,
            variable == "USA_q2h"     ~ 1
          )
        )
    }
    if (pid %in% c("Figure_11_B")){
      data2plot <- data2plot %>%
        mutate(
          order = case_when(
            variable == "USA_q21b_G1" ~ 5,
            variable == "USA_q21a_G2" ~ 4,
            variable == "USA_q21a_G1" ~ 3,
            variable == "USA_q21h_G1" ~ 2,
            variable == "USA_q21j_merge" ~ 1
          )
        )
    }
    if (pid %in% c("Figure_11_C", "Figure_11_D")){
      data2plot <- data2plot %>%
        mutate(
          order = row_number()
        )
    }
  }
  
  return(data2plot)
  
}
