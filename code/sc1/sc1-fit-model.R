source("code/sc1/sc1-fit-load.R")
source("code/include/stacking.R")

sc1_params_xgb <- readRDS("model-pm/sc1_params_xgb.rds")
sc1_params_lgb <- readRDS("model-pm/sc1_params_lgb.rds")
sc1_params_cat <- readRDS("model-pm/sc1_params_cat.rds")

sc1_model <- stacktree_train(
  sc1_x_train, sc1_y_train,
  params = list(
    xgb.nrounds = sc1_params_xgb$nrounds,
    xgb.learning_rate = sc1_params_xgb$learning_rate,
    xgb.max_depth = sc1_params_xgb$max_depth,
    lgb.num_iterations = sc1_params_lgb$num_iterations,
    lgb.max_depth = sc1_params_lgb$max_depth,
    lgb.learning_rate = sc1_params_lgb$learning_rate,
    cat.iterations = sc1_params_cat$iterations,
    cat.depth = sc1_params_cat$depth
  ),
  seed = 1003
)

# phase 1 model summary
sc1_p1_pred <- stacktree_predict(sc1_model, sc1_x_train)
caret::confusionMatrix(table(as.factor(sc1_p1_pred$resp), sc1_y_train))
pROC::auc(sc1_y_train, sc1_p1_pred$prob)

# write the data used for submission
write_tsv(sc1_x_train, "submission/subchallenge_1_data_used_x.tsv")
write_tsv(data.frame("SURVIVAL_STATUS" = sc1_y_train), "submission/subchallenge_1_data_used_y.tsv")
