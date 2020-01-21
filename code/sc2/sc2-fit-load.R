library("readr")

sc2_x_train <- readRDS("data-fs/sc2_x_train.rds")

sc2_y_train <- read_tsv(
  "data/sc2_Phase1_CN_Outcome.tsv",
  col_types = cols(
    PATIENTID = col_character(),
    SURVIVAL_STATUS = col_integer()
  )
)
sc2_y_train$PATIENTID <- NULL
sc2_y_train <- as.vector(sc2_y_train$SURVIVAL_STATUS)
