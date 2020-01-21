source("code/sc2/sc2-fit-load.R")
source("code/include/stacking.R")

sc2_params_xgb <- readRDS("model-pm/sc2_params_xgb.rds")
sc2_params_lgb <- readRDS("model-pm/sc2_params_lgb.rds")
sc2_params_cat <- readRDS("model-pm/sc2_params_cat.rds")

xtrain <- as.matrix(convert_num(sc2_x_train))
ytrain <- sc2_y_train

sc2_model <- lightgbm(
  data = xtrain,
  label = ytrain,
  objective = "binary",
  learning_rate = sc2_params_lgb$learning_rate,
  num_iterations = sc2_params_lgb$num_iterations,
  max_depth = sc2_params_lgb$max_depth,
  num_leaves = 2^(sc2_params_lgb$max_depth) - 2,
  verbose = -1,
  num_threads = parallel::detectCores()
)

# phase 1 model summary
sc2_p1_pred_prob <- predict(sc2_model, xtrain)
sc2_p1_pred_resp <- ifelse(sc2_p1_pred_prob > 0.5, 1L, 0L)
caret::confusionMatrix(table(as.factor(sc2_p1_pred_resp), sc2_y_train))
pROC::auc(sc2_y_train, sc2_p1_pred_prob)

# write the data used for submission
write_tsv(sc2_x_train, "submission/subchallenge_2_data_used_x.tsv")
write_tsv(data.frame("SURVIVAL_STATUS" = sc2_y_train), "submission/subchallenge_2_data_used_y.tsv")
