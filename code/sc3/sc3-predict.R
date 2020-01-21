library("readr")

source("code/include/tidy.R")
source("code/include/stacking.R")

sc3_x1_test <- read_tsv(
  "data/sc3_Phase2_CN_GE_Phenotype.tsv",
  col_types = cols(
    PATIENTID = col_character(),
    SEX = col_character(),
    RACE = col_character(),
    WHO_GRADING = col_character(),
    CANCER_TYPE = col_character()
  )
)
sc3_x2_test <- read_tsv(
  "data/sc3_Phase2_CN_GE_FeatureMatrix.tsv",
  col_types = cols(
    .default = col_double(),
    PATIENTID = col_character()
  )
)

# use tidy_clinical() for the phenotype data to get consistent encoding of clinical variables
sc3_x1_test <- tidy_clinical(sc3_x1_test)

# load feature selection results
sc3_features <- colnames(readRDS("data-fs/sc3_x_train.rds"))[-c(1:4)]

# construct predictor matrix
sc3_patientid <- sc3_x2_test$PATIENTID
sc3_x2_test <- sc3_x2_test[, sc3_features]
sc3_x2_test <- as.matrix(sc3_x2_test)

sc3_x_test <- cbind(sc3_x1_test, sc3_x2_test)

xtest <- as.matrix(convert_num(sc3_x_test))

# make predictions
sc3_pred <- predict(sc3_model, xtest)
sc3_pred <- ifelse(sc3_pred > 0.5, 1L, 0L)

# write results for submission
sc3_submit <- data.frame("PATIENTID" = sc3_patientid, "SURVIVAL_STATUS" = sc3_pred)
write_tsv(sc3_submit, "submission/subchallenge_3.tsv")
