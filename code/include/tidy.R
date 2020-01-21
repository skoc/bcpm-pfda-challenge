# unified feature transformation for the clinical (phenotype) data
# on both training (phase 1) and test (phase 2) data
# this makes sure that the clinical features in training and test
# are encoded in the identical way

tidy_clinical <- function(df) {
  # patient id
  df$PATIENTID <- NULL
  # gender
  df[which(df$SEX == "FEMALE"), "SEX"] <- "1"
  df[which(df$SEX == "MALE"), "SEX"] <- "2"
  df$SEX <- as.factor(df$SEX)
  # race
  df[which(df$RACE == "ASIAN"), "RACE"] <- "1"
  df[which(df$RACE == "ASIANNOS"), "RACE"] <- "2"
  df[which(df$RACE == "BLACK"), "RACE"] <- "3"
  df[which(df$RACE == "HISPANIC"), "RACE"] <- "4"
  df[which(df$RACE == "NATIVEHAWAIIAN"), "RACE"] <- "5"
  df[which(df$RACE == "OTHER"), "RACE"] <- "6"
  df[which(df$RACE == "WHITE"), "RACE"] <- "7"
  df$RACE <- as.factor(df$RACE)
  # cancer type
  df[which(df$CANCER_TYPE == "ASTROCYTOMA"), "CANCER_TYPE"] <- "1"
  df[which(df$CANCER_TYPE == "GBM"), "CANCER_TYPE"] <- "2"
  df[which(df$CANCER_TYPE == "MIXED"), "CANCER_TYPE"] <- "3"
  df[which(df$CANCER_TYPE == "OLIGODENDROGLIOMA"), "CANCER_TYPE"] <- "4"
  df[which(df$CANCER_TYPE == "UNCLASSIFIED"), "CANCER_TYPE"] <- "5"
  df[which(df$CANCER_TYPE == "UNKNOWN"), "CANCER_TYPE"] <- "6"
  df$CANCER_TYPE <- as.factor(df$CANCER_TYPE)
  # grading
  df[which(df$WHO_GRADING == "I"), "WHO_GRADING"] <- "1"
  df[which(df$WHO_GRADING == "II"), "WHO_GRADING"] <- "2"
  df[which(df$WHO_GRADING == "III"), "WHO_GRADING"] <- "3"
  df[which(df$WHO_GRADING == "IV"), "WHO_GRADING"] <- "4"
  df$WHO_GRADING <- as.numeric(df$WHO_GRADING)

  df
}

# convert categorical clinical variables to numeric while
# keeping the value (for xgboost and lightgbm training/prediction)
convert_num <- function (df) {
  df$SEX <- as.numeric(df$SEX)
  df$RACE <- as.numeric(df$RACE)
  df$CANCER_TYPE <- as.numeric(df$CANCER_TYPE)
  df
}
