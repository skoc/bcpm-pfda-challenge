source("code/include/l0learn.R")

fit <- L0Learn.fit(
  sc1_x2_train, sc1_y_train,
  loss = "Logistic", penalty = "L0", maxSuppSize = 20,
  intercept = TRUE
)

sc1_fs_idx <- l0learn.nzv(fit)
sapply(sc1_fs_idx, length)

# names of the selected features
idx <- 7
cat(colnames(sc1_x2_train)[sc1_fs_idx[[idx]]], sep = ", ")

# selected features
sc1_x2_train_fs <- sc1_x2_train[, sc1_fs_idx[[idx]], drop = FALSE]
sc1_x_train <- cbind(sc1_x1_train, sc1_x2_train_fs)

# save the df for training
saveRDS(sc1_x_train, file = "data-fs/sc1_x_train.rds")
