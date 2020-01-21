source("code/include/l0learn.R")

fit <- L0Learn.fit(
  sc3_x2_train, sc3_y_train,
  loss = "Logistic", penalty = "L0", maxSuppSize = 30,
  intercept = TRUE
)

sc3_fs_idx <- l0learn.nzv(fit)
sapply(sc3_fs_idx, length)

# names of the selected features
idx <- 4
cat(colnames(sc3_x2_train)[sc3_fs_idx[[idx]]], sep = ", ")

# selected features
sc3_x2_train_fs <- sc3_x2_train[, sc3_fs_idx[[idx]], drop = FALSE]
sc3_x_train <- cbind(sc3_x1_train, sc3_x2_train_fs)

# save the df for training
saveRDS(sc3_x_train, file = "data-fs/sc3_x_train.rds")
