library("readr")

source("code/include/tidy.R")

sc3_y_train <- read_tsv(
  "data/sc3_Phase1_CN_GE_Outcome.tsv",
  col_types = cols(
    PATIENTID = col_character(),
    SURVIVAL_STATUS = col_integer()
  )
)
sc3_x1_train <- read_tsv(
  "data/sc3_Phase1_CN_GE_Phenotype.tsv",
  col_types = cols(
    PATIENTID = col_character(),
    SEX = col_character(),
    RACE = col_character(),
    WHO_GRADING = col_character(),
    CANCER_TYPE = col_character()
  )
)
sc3_x2_train <- read_tsv(
  "data/sc3_Phase1_CN_GE_FeatureMatrix.tsv.zip",
  col_types = cols(
    .default = col_double(),
    PATIENTID = col_character()
  )
)

sc3_y_train$PATIENTID <- NULL
sc3_y_train <- as.vector(sc3_y_train$SURVIVAL_STATUS)

sc3_x1_train <- tidy_clinical(sc3_x1_train)

sc3_x2_train$PATIENTID <- NULL
sc3_x2_train <- as.matrix(sc3_x2_train)
