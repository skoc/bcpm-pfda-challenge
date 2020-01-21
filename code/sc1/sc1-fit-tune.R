source("code/sc1/sc1-fit-load.R")
source("code/include/param.R")

sc1_params_xgb <- cv_xgb(sc1_x_train, sc1_y_train, seed = 1003)
sc1_params_lgb <- cv_lgb(sc1_x_train, sc1_y_train, seed = 1003)
sc1_params_cat <- cv_cat(sc1_x_train, sc1_y_train, seed = 1003)

saveRDS(sc1_params_xgb, file = "model-pm/sc1_params_xgb.rds")
saveRDS(sc1_params_lgb, file = "model-pm/sc1_params_lgb.rds")
saveRDS(sc1_params_cat, file = "model-pm/sc1_params_cat.rds")
