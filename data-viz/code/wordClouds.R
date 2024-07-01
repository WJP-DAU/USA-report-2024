# 
# Project:            USA Report 2024
# Module Name:        Word Clouds (Q16 and Q17)
# Author:             Isabella Coddington
# Date:               June 28,2024
# Description:        This module contains the code to make and save word clouds for US report.
# This version:       July 1st, 2024
#

# Load the packages
library(ggwordcloud)
source("code/settings.R")
source("https://raw.githubusercontent.com/ctoruno/WJPr/main/R/wordcloudChart.R")

lemmas <- read_csv(
  file.path(path2main,
            "data-viz/lemmas.csv",
            fsep = "/"))

ROL_wordCloud <- wjp_wordcloud(
  df    = lemmas,
  word_col = "ROL",
  freq_col = "frequency_rol"
  
)

US_wordCloud <- wjp_wordcloud(
  df = lemmas,
  word_col = "ROL_us",
  freq_col = "frequency_us",
  min_freq = 3
)

ggsave("rol_word_cloud.svg", plot = ROL_wordCloud, device = "svg", width = 8, height = 6)
ggsave("us_cloud.svg", plot = US_wordCloud, device = "svg", width = 8, height = 6)
