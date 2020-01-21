library("readr")

source("code/include/tidy.R")

sc2_y_train <- read_tsv(
  "data/sc2_Phase1_CN_Outcome.tsv",
  col_types = cols(
    PATIENTID = col_character(),
    SURVIVAL_STATUS = col_integer()
  )
)
sc2_x1_train <- read_tsv(
  "data/sc2_Phase1_CN_Phenotype.tsv",
  col_types = cols(
    PATIENTID = col_character(),
    SEX = col_character(),
    RACE = col_character(),
    WHO_GRADING = col_character(),
    CANCER_TYPE = col_character()
  )
)
sc2_x2_train <- read_tsv(
  "data/sc2_Phase1_CN_FeatureMatrix.tsv",
  col_types = cols(
    .default = col_double(),
    PATIENTID = col_character()
  )
)

sc2_y_train$PATIENTID <- NULL
sc2_y_train <- as.vector(sc2_y_train$SURVIVAL_STATUS)

sc2_x1_train <- tidy_clinical(sc2_x1_train)

sc2_x2_train$PATIENTID <- NULL
sc2_x2_train <- as.matrix(sc2_x2_train)
