library(tidyverse)
library(caret)
library(dslabs)
        
# set.seed(1) # if using R 3.5 or earlier
set.seed(1, sample.kind="Rounding") # if using R 3.6 or later

rmse <- function(n) {
      # Sigma <- 9*matrix(c(1.0, 0.5, 0.5, 1.0), 2, 2)
      Sigma <- 9*matrix(c(1.0, 0.95, 0.95, 1.0), 2, 2)
      dat <- MASS::mvrnorm(n, c(69, 69), Sigma) %>%
            data.frame() %>% setNames(c("x", "y"))
      # set.seed(1, sample.kind="Rounding") # if using R 3.6 or later
      rmse <- replicate(100, {
            test_index <- createDataPartition(dat$y, times = 1, p = 0.5, list = FALSE);
            test <- dat %>% slice(test_index);
            train <- dat %>% slice(-test_index);
            fit <- lm(y ~ x, data = train);
            y_hat <- predict(fit, newdata=test);
            rmse <- sqrt(mean((y_hat - test$y)^2));
            rmse
      })
      list("mean" = mean(rmse), "sd" = sd(rmse))
}

set.seed(1, sample.kind="Rounding") # if using R 3.6 or later
res <- sapply(c(100, 500, 1000, 5000, 10000), rmse)
res

# set.seed(1) # if using R 3.5 or earlier
set.seed(1, sample.kind="Rounding") # if using R 3.6 or later


# Sigma <- matrix(c(1.0, 0.75, 0.75, 0.75, 1.0, 0.25, 0.75, 0.25, 1.0), 3, 3)
Sigma <- matrix(c(1.0, 0.75, 0.75, 0.75, 1.0, 0.95, 0.75, 0.95, 1.0), 3, 3)
dat <- MASS::mvrnorm(n = 100, c(0, 0, 0), Sigma) %>%
      data.frame() %>% setNames(c("y", "x_1", "x_2"))
cor(dat)
    
test_index <- createDataPartition(dat$y, times = 1, p = 0.5, list = FALSE);
test <- dat %>% slice(test_index);
train <- dat %>% slice(-test_index);

fit <- lm(y ~ x_1, data = train);
y_hat <- predict(fit, newdata=test);
rmse <- sqrt(mean((y_hat - test$y)^2));
rmse

fit <- lm(y ~ x_2, data = train);
y_hat <- predict(fit, newdata=test);
rmse <- sqrt(mean((y_hat - test$y)^2));
rmse

fit <- lm(y ~ x_1 + x_2, data = train);
y_hat <- predict(fit, newdata=test);
rmse <- sqrt(mean((y_hat - test$y)^2));
rmse