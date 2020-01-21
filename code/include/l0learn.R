library("L0Learn")

l0learn.nzv <- function(fit) {
  df <- print(fit)

  # filter out zero sets, and remove redudancy by unique support set size
  df <- df[!duplicated(df$suppSize), ]
  df <- df[df$suppSize != 0, ]

  # contains intercepts or not
  intercept <- rownames(coef(fit, lambda = df[1, "lambda"], gamma = df[1, "gamma"]))[1] == "Intercept"

  k <- nrow(df)
  lst <- vector("list", k)

  for (i in 1:k) {
    if (intercept) {
      beta <- coef(fit, lambda = df[i, "lambda"], gamma = df[i, "gamma"])[-1, , drop = FALSE]
    } else {
      beta <- coef(fit, lambda = df[i, "lambda"], gamma = df[i, "gamma"])
    }
    lst[[i]] <- which(abs(as.vector(beta)) > .Machine$double.eps)
  }
  lst
}
