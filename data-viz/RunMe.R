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
## 0.  Presetting                                                                                           ----
##
## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# Loading settings and functions
source("code/settings.R")
source("code/data-wrangling.R")
source("code/data-viz.R")

# Loading data
master_data <- read_dta(
  file.path(path2main,
            "data-viz/data/USA_data.dta",
            fsep = "/")
) %>%
  mutate(
    latestYear = 2024,
    pparty = case_when(
      year == 2021 & paff3 == "The Democratic Party" ~ "Democrats",
      year == 2021 & paff3 == "The Republican Party" ~ "Republicans",
      year == 2024 & USA_paff1 == 2 ~ "Democrats",
      year == 2024 & USA_paff1 == 1 ~ "Republicans"
    ),
    USA_q21j_merge = case_when(  # USA_q21j_G1 & USA_q21e_G2 are the same
      !is.na(USA_q21j_G1) ~ USA_q21j_G1,
      !is.na(USA_q21e_G2) ~ USA_q21e_G2
    )
  ) %>%
  filter(
    year >= 2014
  )

# Loading figure map & outline
figure_map <- read.xlsx("../report_outline.xlsx", sheet = "figure_map") %>%
  select(-status) %>%
  mutate(
    panelID = paste(id, panel, sep = "_")
  ) %>%
  relocate(panelID)
outline <- read.xlsx("../report_outline.xlsx", sheet = "outline") 

# Cleaning outputs
outputsReset(figure_map)


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
    type %in% c("Bars", "Lines", "Radar", "Gauge", "Dots", "Edgebars", "Dumbbells", "Slope")
    # type %in% c("Gauge") # For testing purposes
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

# Calling a Visualizer for every panel
data_plots <- lapply(
  viz_panels,
  callVisualizer,
  figure_map = figure_map,
  outline    = outline
)
