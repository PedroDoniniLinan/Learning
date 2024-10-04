library(tidyverse)
library(caret)
library(dslabs)

# set.seed(2) #if you are using R 3.5 or earlier
set.seed(2, sample.kind="Rounding") #if you are using R 3.6 or later
make_data <- function(n = 1000, p = 0.5, 
				mu_0 = 0, mu_1 = 2, 
				sigma_0 = 1,  sigma_1 = 1){

y <- rbinom(n, 1, p)
f_0 <- rnorm(n, mu_0, sigma_0)
f_1 <- rnorm(n, mu_1, sigma_1)
x <- ifelse(y == 1, f_1, f_0)
  
test_index <- createDataPartition(y, times = 1, p = 0.5, list = FALSE)

list(train = data.frame(x = x, y = as.factor(y)) %>% slice(-test_index),
	test = data.frame(x = x, y = as.factor(y)) %>% slice(test_index))
}

calculate_res <- function(d) {
    set.seed(1, sample.kind="Rounding") #if you are using R 3.6 or later
    dat <- make_data(mu_1 = d)
    fit_glm <- glm(dat$train$y ~ dat$train$x, data=dat$train, family = "binomial")
    p_hat_glm <- predict(fit_glm, dat$test)
    # if p^(7) > 50% then 7 else 2
    y_hat_glm <- factor(ifelse(p_hat_glm > 0.5, 1, 0))
    acc <- confusionMatrix(data = y_hat_glm, reference = dat$test$y)$overall["Accuracy"][1]
    list(res = acc, delta = d)
}

delta <- seq(0, 3, len=25)
ans <- lapply(delta, calculate_res)
typeof(ans[1])
ans

