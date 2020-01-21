model_selection <- function (x_train, y_train, params_xgb, params_lgb, params_cat, seed_stacked) {
  # stacked model
  stack_fit <- stacktree_train(
    x_train, y_train,
    params = list(
      xgb.nrounds = params_xgb$nrounds,
      xgb.learning_rate = params_xgb$learning_rate,
      xgb.max_depth = params_xgb$max_depth,
      lgb.num_iterations = params_lgb$num_iterations,
      lgb.max_depth = params_lgb$max_depth,
      lgb.learning_rate = params_lgb$learning_rate,
      cat.iterations = params_cat$iterations,
      cat.depth = params_cat$depth
    ),
    seed = seed_stacked,
    verbose = FALSE
  )

  roc_test_stack <- pROC::roc(y_test, stacktree_predict(stack_fit, x_test)$prob, quiet = TRUE)

  # xgboost only
  xtrain <- xgb.DMatrix(as.matrix(convert_num(x_train)), label = y_train)
  xtest <- xgb.DMatrix(as.matrix(convert_num(x_test)))

  xgb_fit <- xgb.train(
    params = list(
      objective = "binary:logistic",
      eval_metric = "auc",
      max_depth = params_xgb$max_depth,
      eta = params_xgb$learning_rate
    ),
    data = xtrain,
    nrounds = params_xgb$nrounds
  )

  roc_test_xgb <- pROC::roc(y_test, predict(xgb_fit, xtest), quiet = TRUE)

  # lightgbm only
  xtrain <- as.matrix(convert_num(x_train))
  xtest <- as.matrix(convert_num(x_test))

  lgb_fit <- lightgbm(
    data = xtrain,
    label = y_train,
    objective = "binary",
    learning_rate = params_lgb$learning_rate,
    num_iterations = params_lgb$num_iterations,
    max_depth = params_lgb$max_depth,
    num_leaves = 2^params_lgb$max_depth - 1,
    verbose = -1
  )

  roc_test_lgb <- pROC::roc(y_test, predict(lgb_fit, xtest), quiet = TRUE)

  # catboost only
  train_pool <- catboost.load_pool(data = x_train, label = y_train)
  test_pool <- catboost.load_pool(data = x_test, label = NULL)
  cat_fit <- catboost.train(
    train_pool, NULL,
    params = list(
      loss_function = "Logloss",
      iterations = params_cat$iterations,
      depth = params_cat$depth,
      logging_level = "Silent"
    )
  )

  roc_test_cat <- pROC::roc(y_test, catboost.predict(cat_fit, test_pool, prediction_type = "Probability"), quiet = TRUE)

  cat("xgboost  :", as.numeric(roc_test_xgb$auc), "\n")
  cat("lightgbm :", as.numeric(roc_test_lgb$auc), "\n")
  cat("catboost :", as.numeric(roc_test_cat$auc), "\n")
  cat("stacked  :", as.numeric(roc_test_stack$auc), "\n")

  invisible(NULL)
}
