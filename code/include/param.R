# parameter tuning with k-fold cross-validation + grid search

library("xgboost")
library("lightgbm")
library("catboost")

source("code/include/tidy.R")

cv_xgb <- function(x, y, nfolds = 5L, seed = 2019, verbose = TRUE,
                   nrounds = c(10, 50, 100, 200, 500, 1000),
                   max_depth = c(2, 3, 4, 5),
                   learning_rate = c(0.001, 0.01, 0.02, 0.05, 0.1)) {
  set.seed(seed)
  nrow_x <- nrow(x)
  index <- sample(rep_len(1L:nfolds, nrow_x))
  df_grid <- expand.grid(
    "nrounds" = nrounds,
    "max_depth" = max_depth,
    "learning_rate" = learning_rate,
    "metric" = NA
  )
  x <- as.matrix(convert_num(x))

  for (j in 1L:nrow(df_grid)) {
    ypred <- matrix(NA, ncol = 2L, nrow = nrow_x)
    for (i in 1L:nfolds) {
      if (verbose) cat("Fold", i, "in grid row", j, "of", nrow(df_grid), "\n")
      xtrain <- x[index != i, , drop = FALSE]
      ytrain <- y[index != i]
      xtest <- x[index == i, , drop = FALSE]
      ytest <- y[index == i]

      xtrain <- xgb.DMatrix(xtrain, label = ytrain)
      xtest <- xgb.DMatrix(xtest)

      fit <- xgb.train(
        params = list(
          objective = "binary:logistic",
          eval_metric = "auc",
          max_depth = df_grid[j, "max_depth"],
          eta = df_grid[j, "learning_rate"]
        ),
        data = xtrain,
        nrounds = df_grid[j, "nrounds"],
        nthread = parallel::detectCores()
      )
      ypredvec <- predict(fit, xtest)
      ypred[index == i, 1L] <- ytest
      ypred[index == i, 2L] <- ypredvec
    }
    colnames(ypred) <- c("y.real", "y.pred")
    df_grid[j, "metric"] <- as.numeric(pROC::auc(ypred[, "y.real"], ypred[, "y.pred"], quiet = TRUE))
  }

  best_row <- which.max(df_grid$metric)
  best_metric <- df_grid$metric[best_row]
  best_nrounds <- df_grid$nrounds[best_row]
  best_learning_rate <- df_grid$learning_rate[best_row]
  best_max_depth <- df_grid$max_depth[best_row]

  list(
    df = df_grid,
    metric = best_metric,
    nrounds = best_nrounds,
    learning_rate = best_learning_rate,
    max_depth = best_max_depth
  )
}

cv_lgb <- function(x, y, nfolds = 5L, seed = 2019, verbose = TRUE,
                   num_iterations = c(10, 50, 100, 200, 500, 1000),
                   max_depth = c(2, 3, 4, 5),
                   learning_rate = c(0.001, 0.01, 0.02, 0.05, 0.1)) {
  set.seed(seed)
  nrow_x <- nrow(x)
  index <- sample(rep_len(1L:nfolds, nrow_x))
  df_grid <- expand.grid(
    "num_iterations" = num_iterations,
    "max_depth" = max_depth,
    "learning_rate" = learning_rate,
    "metric" = NA
  )
  x <- as.matrix(convert_num(x))

  for (j in 1L:nrow(df_grid)) {
    ypred <- matrix(NA, ncol = 2L, nrow = nrow_x)
    for (i in 1L:nfolds) {
      if (verbose) cat("Fold", i, "in grid row", j, "of", nrow(df_grid), "\n")
      xtrain <- x[index != i, , drop = FALSE]
      ytrain <- y[index != i]
      xtest <- x[index == i, , drop = FALSE]
      ytest <- y[index == i]

      fit <- lightgbm(
        data = xtrain,
        label = ytrain,
        objective = "binary",
        learning_rate = df_grid[j, "learning_rate"],
        num_iterations = df_grid[j, "num_iterations"],
        max_depth = df_grid[j, "max_depth"],
        num_leaves = 2^(df_grid[j, "max_depth"]) - 1,
        verbose = -1,
        num_threads = parallel::detectCores()
      )
      ypredvec <- predict(fit, xtest)
      ypred[index == i, 1L] <- ytest
      ypred[index == i, 2L] <- ypredvec
    }
    colnames(ypred) <- c("y.real", "y.pred")
    df_grid[j, "metric"] <- as.numeric(pROC::auc(ypred[, "y.real"], ypred[, "y.pred"], quiet = TRUE))
  }

  best_row <- which.max(df_grid$metric)
  best_metric <- df_grid$metric[best_row]
  best_num_iterations <- df_grid$num_iterations[best_row]
  best_max_depth <- df_grid$max_depth[best_row]
  best_learning_rate <- df_grid$learning_rate[best_row]

  list(
    df = df_grid,
    metric = best_metric,
    num_iterations = best_num_iterations,
    max_depth = best_max_depth,
    learning_rate = best_learning_rate
  )
}

cv_cat <- function(x, y, nfolds = 5L, seed = 2019, verbose = TRUE,
                   iterations = c(10, 50, 100, 200, 500, 1000),
                   depth = c(2, 3, 4, 5)) {
  set.seed(seed)
  nrow_x <- nrow(x)
  index <- sample(rep_len(1L:nfolds, nrow_x))
  df_grid <- expand.grid(
    "iterations" = iterations,
    "depth" = depth,
    "metric" = NA
  )
  # x <- as.matrix(convert_num(x)) # uncomment to use non-categorical features

  for (j in 1L:nrow(df_grid)) {
    ypred <- matrix(NA, ncol = 2L, nrow = nrow_x)
    for (i in 1L:nfolds) {
      if (verbose) cat("Fold", i, "in grid row", j, "of", nrow(df_grid), "\n")
      xtrain <- x[index != i, , drop = FALSE]
      ytrain <- y[index != i]
      xtest <- x[index == i, , drop = FALSE]
      ytest <- y[index == i]
      train_pool <- catboost.load_pool(data = xtrain, label = ytrain)
      test_pool <- catboost.load_pool(data = xtest, label = NULL)
      fit <- catboost.train(
        train_pool, NULL,
        params = list(
          loss_function = "Logloss",
          iterations = df_grid[j, "iterations"],
          depth = df_grid[j, "depth"],
          logging_level = "Silent",
          thread_count = parallel::detectCores()
        )
      )
      ypredvec <- catboost.predict(fit, test_pool, prediction_type = "Probability")
      ypred[index == i, 1L] <- ytest
      ypred[index == i, 2L] <- ypredvec
    }
    colnames(ypred) <- c("y.real", "y.pred")
    df_grid[j, "metric"] <- as.numeric(pROC::auc(ypred[, "y.real"], ypred[, "y.pred"], quiet = TRUE))
  }

  best_row <- which.max(df_grid$metric)
  best_metric <- df_grid$metric[best_row]
  best_iterations <- df_grid$iterations[best_row]
  best_depth <- df_grid$depth[best_row]

  list(
    df = df_grid,
    metric = best_metric,
    iterations = best_iterations,
    depth = best_depth
  )
}
