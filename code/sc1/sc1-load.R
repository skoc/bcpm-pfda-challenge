library("readr")

source("code/include/tidy.R")

sc1_y_train <- read_tsv(
  "data/sc1_Phase1_GE_Outcome.tsv",
  col_types = cols(
    PATIENTID = col_character(),
    SURVIVAL_STATUS = col_integer()
  )
)
sc1_x1_train <- read_tsv(
  "data/sc1_Phase1_GE_Phenotype.tsv",
  col_types = cols(
    PATIENTID = col_character(),
    SEX = col_character(),
    RACE = col_character(),
    WHO_GRADING = col_character(),
    CANCER_TYPE = col_character()
  )
)
sc1_x2_train <- read_tsv(
  "data/sc1_Phase1_GE_FeatureMatrix.tsv.zip",
  col_types = cols(
    .default = col_double(),
    PATIENTID = col_character()
  )
)

sc1_y_train$PATIENTID <- NULL
sc1_y_train <- as.vector(sc1_y_train$SURVIVAL_STATUS)

sc1_x1_train <- tidy_clinical(sc1_x1_train)

sc1_x2_train$PATIENTID <- NULL
sc1_x2_train <- as.matrix(sc1_x2_train)
