library("readr")

sc1_x_train <- readRDS("data-fs/sc1_x_train.rds")

sc1_y_train <- read_tsv(
  "data/sc1_Phase1_GE_Outcome.tsv",
  col_types = cols(
    PATIENTID = col_character(),
    SURVIVAL_STATUS = col_integer()
  )
)
sc1_y_train$PATIENTID <- NULL
sc1_y_train <- as.vector(sc1_y_train$SURVIVAL_STATUS)
