library("readr")

source("code/include/tidy.R")
source("code/include/stacking.R")

sc2_x1_test <- read_tsv(
  "data/sc2_Phase2_CN_Phenotype.tsv",
  col_types = cols(
    PATIENTID = col_character(),
    SEX = col_character(),
    RACE = col_character(),
    WHO_GRADING = col_character(),
    CANCER_TYPE = col_character()
  )
)
sc2_x2_test <- read_tsv(
  "data/sc2_Phase2_CN_FeatureMatrix.tsv",
  col_types = cols(
    .default = col_double(),
    PATIENTID = col_character()
  )
)

# use tidy_clinical() for the phenotype data to get consistent encoding of clinical variables
sc2_x1_test <- tidy_clinical(sc2_x1_test)

# load feature selection results
sc2_features <- colnames(readRDS("data-fs/sc2_x_train.rds"))[-c(1:4)]

# construct predictor matrix
sc2_patientid <- sc2_x2_test$PATIENTID
sc2_x2_test <- sc2_x2_test[, sc2_features]
sc2_x2_test <- as.matrix(sc2_x2_test)

sc2_x_test <- cbind(sc2_x1_test, sc2_x2_test)

xtest <- as.matrix(convert_num(sc2_x_test))

# make predictions
sc2_pred <- predict(sc2_model, xtest)
sc2_pred <- ifelse(sc2_pred > 0.5, 1L, 0L)

# write results for submission
sc2_submit <- data.frame("PATIENTID" = sc2_patientid, "SURVIVAL_STATUS" = sc2_pred)
write_tsv(sc2_submit, "submission/subchallenge_2.tsv")
