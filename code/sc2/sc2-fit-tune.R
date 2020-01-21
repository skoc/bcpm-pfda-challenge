source("code/sc2/sc2-fit-load.R")
source("code/include/param.R")

sc2_params_xgb <- cv_xgb(sc2_x_train, sc2_y_train, seed = 1003)
sc2_params_lgb <- cv_lgb(sc2_x_train, sc2_y_train, seed = 1003)
sc2_params_cat <- cv_cat(sc2_x_train, sc2_y_train, seed = 1003)

saveRDS(sc2_params_xgb, file = "model-pm/sc2_params_xgb.rds")
saveRDS(sc2_params_lgb, file = "model-pm/sc2_params_lgb.rds")
saveRDS(sc2_params_cat, file = "model-pm/sc2_params_cat.rds")
