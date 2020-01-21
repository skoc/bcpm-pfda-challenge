# model stacking
# level 1: catboost lightgbm xgboost
# level 2: logistic regression

source("code/include/tidy.R")

library("xgboost")
library("lightgbm")
library("catboost")

stacktree_train <- function(x, y, params, nfolds = 5L, seed = 2019, verbose = TRUE) {
  set.seed(seed)
  nrow_x <- nrow(x)
  index_xgb <- sample(rep_len(1L:nfolds, nrow_x))
  index_lgb <- sample(rep_len(1L:nfolds, nrow_x))
  index_cat <- sample(rep_len(1L:nfolds, nrow_x))

  model_xgb <- vector("list", nfolds)
  model_lgb <- vector("list", nfolds)
  model_cat <- vector("list", nfolds)

  x_glm <- matrix(NA, nrow = nrow_x, ncol = 3L)
  colnames(x_glm) <- c("xgb", "lgb", "cat")

  # xgboost
  x_xgb <- as.matrix(convert_num(x))
  for (i in 1L:nfolds) {
    if (verbose) cat("Fold", i, "in xgboost\n")
    xtrain <- x_xgb[index_xgb != i, , drop = FALSE]
    ytrain <- y[index_xgb != i]
    xtest <- x_xgb[index_xgb == i, , drop = FALSE]
    ytest <- y[index_xgb == i]

    xtrain <- xgb.DMatrix(xtrain, label = ytrain)
    xtest <- xgb.DMatrix(xtest)

    fit <- xgb.train(
      params = list(
        objective = "binary:logistic",
        eval_metric = "auc",
        max_depth = params$xgb.max_depth,
        eta = params$xgb.learning_rate
      ),
      data = xtrain,
      nrounds = params$xgb.nrounds
    )

    model_xgb[[i]] <- fit
    x_glm[index_xgb == i, "xgb"] <- predict(fit, xtest)
  }

  # lightgbm
  x_lgb <- as.matrix(convert_num(x))
  for (i in 1L:nfolds) {
    if (verbose) cat("Fold", i, "in lightgbm\n")
    xtrain <- x_lgb[index_lgb != i, , drop = FALSE]
    ytrain <- y[index_lgb != i]
    xtest <- x_lgb[index_lgb == i, , drop = FALSE]
    ytest <- y[index_lgb == i]

    fit <- lightgbm(
      data = xtrain,
      label = ytrain,
      objective = "binary",
      learning_rate = params$lgb.learning_rate,
      num_iterations = params$lgb.num_iterations,
      max_depth = params$lgb.max_depth,
      num_leaves = 2^params$lgb.max_depth - 1,
      verbose = -1
    )

    model_lgb[[i]] <- fit
    x_glm[index_lgb == i, "lgb"] <- predict(fit, xtest)
  }

  # catboost
  x_cat <- x
  for (i in 1L:nfolds) {
    if (verbose) cat("Fold", i, "in catboost\n")
    xtrain <- x_cat[index_cat != i, , drop = FALSE]
    ytrain <- y[index_cat != i]
    xtest <- x_cat[index_cat == i, , drop = FALSE]
    ytest <- y[index_cat == i]

    train_pool <- catboost.load_pool(data = xtrain, label = ytrain)
    test_pool <- catboost.load_pool(data = xtest, label = NULL)
    fit <- catboost.train(
      train_pool, NULL,
      params = list(
        loss_function = "Logloss",
        iterations = params$cat.iterations,
        depth = params$cat.depth,
        logging_level = "Silent"
      )
    )
    model_cat[[i]] <- fit
    x_glm[index_cat == i, "cat"] <- catboost.predict(fit, test_pool, prediction_type = "Probability")
  }

  model_glm <- glm(y ~ ., data = data.frame(cbind(y, x_glm)), family = binomial())

  list(
    "model_xgb" = model_xgb,
    "model_lgb" = model_lgb,
    "model_cat" = model_cat,
    "model_glm" = model_glm
  )
}

stacktree_predict <- function(model, xnew) {
  nrow_xnew <- nrow(xnew)
  nfolds <- length(model$model_xgb)

  pred_xgb <- matrix(NA, nrow = nrow_xnew, ncol = nfolds)
  pred_lgb <- matrix(NA, nrow = nrow_xnew, ncol = nfolds)
  pred_cat <- matrix(NA, nrow = nrow_xnew, ncol = nfolds)

  xnew_xgb <- as.matrix(convert_num(xnew))
  xnew_xgb <- xgb.DMatrix(xnew_xgb)
  for (i in 1L:nfolds) pred_xgb[, i] <- predict(model$model_xgb[[i]], xnew_xgb)

  xnew_lgb <- as.matrix(convert_num(xnew))
  for (i in 1L:nfolds) pred_lgb[, i] <- predict(model$model_lgb[[i]], xnew_lgb)

  xnew_cat <- xnew
  xnew_cat <- catboost.load_pool(data = xnew_cat, label = NULL)
  for (i in 1L:nfolds) pred_cat[, i] <- catboost.predict(model$model_cat[[i]], xnew_cat, prediction_type = "Probability")

  xnew_glm <- data.frame(
    "xgb" = rowMeans(pred_xgb),
    "lgb" = rowMeans(pred_lgb),
    "cat" = rowMeans(pred_cat)
  )

  pred_prob <- unname(predict(model$model_glm, xnew_glm, type = "response"))
  pred_resp <- ifelse(pred_prob > 0.5, 1L, 0L)

  list("prob" = pred_prob, "resp" = pred_resp)
}
