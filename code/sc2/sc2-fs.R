source("code/include/l0learn.R")

fit <- L0Learn.fit(
  sc2_x2_train, sc2_y_train,
  loss = "Logistic", penalty = "L0", maxSuppSize = 20,
  intercept = TRUE
)

sc2_fs_idx <- l0learn.nzv(fit)
sapply(sc2_fs_idx, length)

# names of the selected features
idx <- 3
cat(colnames(sc2_x2_train)[sc2_fs_idx[[idx]]], sep = ", ")

# selected features
sc2_x2_train_fs <- sc2_x2_train[, sc2_fs_idx[[idx]], drop = FALSE]
sc2_x_train <- cbind(sc2_x1_train, sc2_x2_train_fs)

# save the df for training
saveRDS(sc2_x_train, file = "data-fs/sc2_x_train.rds")
