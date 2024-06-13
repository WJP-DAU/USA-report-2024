## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
##
## Script:            USA Report 2024 - RunMe File
##
## Author(s):         Carlos A. Toruño Paniagua   (ctoruno@worldjusticeproject.org)
##
## Dependencies:      World Justice Project
##
## Creation date:     June 7th, 2024
##
##
## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
##
## Outline:                                                                                                 ----
##
## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
##
## 0.  Presettings                                                                                          ----
##
## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# Loading settings and functions
source("code/settings.R")
source("code/data-wrangling.R")

# Loading data
master_data <- read_dta("data/USA_data.dta") %>%
  mutate(
    latestYear = 2024,
    pparty = case_when(
      year == 2021 & paff3 == "The Democratic Party" ~ "Democrats",
      year == 2021 & paff3 == "The Republican Party" ~ "Republicans",
      year == 2024 & USA_paff1 == 2 ~ "Democrats",
      year == 2024 & USA_paff1 == 1 ~ "Republicans"
    )
  ) %>%
  filter(
    year >= 2014
  )

# Loading figure map & outline
figure_map <- read.xlsx("../report_outline.xlsx", sheet = "figure_map") %>%
  mutate(
    panelID = paste(id, panel, sep = "_")
  ) %>%
  relocate(panelID)
outline <- read.xlsx("../report_outline.xlsx", sheet = "outline") 


## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
##
## 1.  Data Wrangling                                                                                       ----
##
## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# Producing a data bank
data_bank <- DataBank(master_data)

# Producing data points
viz_panels <- figure_map %>% 
  filter(
    type %in% c("Bars")
  ) %>%
  pull(panelID)
names(viz_panels) <- viz_panels
data_points <- lapply(
  viz_panels,
  getDataPoints,
  figure_map = figure_map
)

# Saving data points
write.xlsx(data_points, "outputs/data_points.csv")


## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
##
## 2.  Data Visualization                                                                                   ----
##
## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


