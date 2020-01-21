library("readr")

source("code/include/tidy.R")
source("code/include/stacking.R")

sc1_x1_test <- read_tsv(
  "data/sc1_Phase2_GE_Phenotype.tsv",
  col_types = cols(
    PATIENTID = col_character(),
    SEX = col_character(),
    RACE = col_character(),
    WHO_GRADING = col_character(),
    CANCER_TYPE = col_character()
  )
)
sc1_x2_test <- read_tsv(
  "data/sc1_Phase2_GE_FeatureMatrix.tsv",
  col_types = cols(
    .default = col_double(),
    PATIENTID = col_character()
  )
)

# use tidy_clinical() for the phenotype data to get consistent encoding of clinical variables
sc1_x1_test <- tidy_clinical(sc1_x1_test)

# load feature selection results
sc1_features <- colnames(readRDS("data-fs/sc1_x_train.rds"))[-c(1:4)]

# construct predictor matrix
sc1_patientid <- sc1_x2_test$PATIENTID
sc1_x2_test <- sc1_x2_test[, sc1_features]
sc1_x2_test <- as.matrix(sc1_x2_test)

sc1_x_test <- cbind(sc1_x1_test, sc1_x2_test)

# make predictions
sc1_pred <- stacktree_predict(sc1_model, sc1_x_test)$resp

# write results for submission
sc1_submit <- data.frame("PATIENTID" = sc1_patientid, "SURVIVAL_STATUS" = sc1_pred)
write_tsv(sc1_submit, "submission/subchallenge_1.tsv")
