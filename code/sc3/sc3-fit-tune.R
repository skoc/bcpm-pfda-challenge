source("code/sc3/sc3-fit-load.R")
source("code/include/param.R")

sc3_params_xgb <- cv_xgb(sc3_x_train, sc3_y_train, seed = 1002)
sc3_params_lgb <- cv_lgb(sc3_x_train, sc3_y_train, seed = 1002)
sc3_params_cat <- cv_cat(sc3_x_train, sc3_y_train, seed = 1002)

saveRDS(sc3_params_xgb, file = "model-pm/sc3_params_xgb.rds")
saveRDS(sc3_params_lgb, file = "model-pm/sc3_params_lgb.rds")
saveRDS(sc3_params_cat, file = "model-pm/sc3_params_cat.rds")
