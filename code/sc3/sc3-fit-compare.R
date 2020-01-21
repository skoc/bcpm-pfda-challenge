# select a model for each subchallenge from single xgboost,
# single lightgbm, single catboost, or a stacked model of the three.

source("code/sc3/sc3-fit-load.R")
source("code/include/stacking.R")
source("code/include/model-selection.R")

sc3_params_xgb <- readRDS("model-pm/sc3_params_xgb.rds")
sc3_params_lgb <- readRDS("model-pm/sc3_params_lgb.rds")
sc3_params_cat <- readRDS("model-pm/sc3_params_cat.rds")

set.seed(1001)
idx_tr <- sample(1:166, round(166 * 0.8))
idx_te <- setdiff(1:166, idx_tr)
x_train <- sc3_x_train[idx_tr, ]
y_train <- sc3_y_train[idx_tr]
x_test <- sc3_x_train[idx_te, ]
y_test <- sc3_y_train[idx_te]

model_selection(x_train, y_train, sc3_params_xgb, sc3_params_lgb, sc3_params_cat, 1002)

# from below we decide to use the lightgbm model - it's consistently top 1 or top 2

# 0.8
# xgboost  : 0.9065934
# lightgbm : 0.9175824
# catboost : 0.8461538
# stacked  : 0.9395604

# 0.7
# xgboost  : 0.8530702
# lightgbm : 0.8815789
# catboost : 0.8311404
# stacked  : 0.8596491

# 0.6
# xgboost  : 0.8427371
# lightgbm : 0.8403361
# catboost : 0.8235294
# stacked  : 0.8091236
