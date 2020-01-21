library("readr")

sc3_x_train <- readRDS("data-fs/sc3_x_train.rds")

sc3_y_train <- read_tsv(
  "data/sc3_Phase1_CN_GE_Outcome.tsv",
  col_types = cols(
    PATIENTID = col_character(),
    SURVIVAL_STATUS = col_integer()
  )
)
sc3_y_train$PATIENTID <- NULL
sc3_y_train <- as.vector(sc3_y_train$SURVIVAL_STATUS)
