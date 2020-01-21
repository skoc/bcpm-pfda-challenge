source("code/sc3/sc3-fit-load.R")
source("code/include/stacking.R")

sc3_params_xgb <- readRDS("model-pm/sc3_params_xgb.rds")
sc3_params_lgb <- readRDS("model-pm/sc3_params_lgb.rds")
sc3_params_cat <- readRDS("model-pm/sc3_params_cat.rds")

xtrain <- as.matrix(convert_num(sc3_x_train))

sc3_model <- lightgbm(
  data = xtrain,
  label = sc3_y_train,
  objective = "binary",
  learning_rate = sc3_params_lgb$learning_rate,
  num_iterations = sc3_params_lgb$num_iterations,
  max_depth = sc3_params_lgb$max_depth,
  num_leaves = 2^sc3_params_lgb$max_depth - 1,
  verbose = -1
)

# phase 1 model summary
sc3_p1_pred_prob <- predict(sc3_model, xtrain)
sc3_p1_pred_resp <- ifelse(sc3_p1_pred_prob > 0.5, 1L, 0L)
caret::confusionMatrix(table(as.factor(sc3_p1_pred_resp), sc3_y_train))
pROC::auc(sc3_y_train, sc3_p1_pred_prob)

# write the data used for submission
write_tsv(sc3_x_train, "submission/subchallenge_3_data_used_x.tsv")
write_tsv(data.frame("SURVIVAL_STATUS" = sc3_y_train), "submission/subchallenge_3_data_used_y.tsv")
