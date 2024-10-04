# Case study
# MNIST mini case
# Determine if number is a 7 or a 2 using 2 features
# * proportion of dark pixels in the upper left quadrant (x1) and lower right (x2)


library(tidyverse)
library(caret)
library(dslabs)

data("mnist_27")

# plots digits with smallest and largest x1
mnist <- read_mnist()
is <- mnist_27$index_train[c(which.min(mnist_27$train$x_1), which.max(mnist_27$train$x_1))]
titles <- c("smallest","largest")
tmp <- lapply(1:2, function(i){
    expand.grid(Row=1:28, Column=1:28) %>%
        mutate(label=titles[i],
               value = mnist$train$images[is[i],])
})
tmp <- Reduce(rbind, tmp)
tmp %>% ggplot(aes(Row, Column, fill=value)) +
    geom_raster() +
    scale_y_reverse() +
    scale_fill_gradient(low="white", high="black") +
    facet_grid(.~label) +
    geom_vline(xintercept = 14.5) +
    geom_hline(yintercept = 14.5)

mnist_27$train %>% ggplot(aes(x_1, x_2, color = y)) + geom_point()

# plots digits with smallest and largest x2
is <- mnist_27$index_train[c(which.min(mnist_27$train$x_2), which.max(mnist_27$train$x_2))]
titles <- c("smallest","largest")
tmp <- lapply(1:2, function(i){
    expand.grid(Row=1:28, Column=1:28) %>%
        mutate(label=titles[i],
               value = mnist$train$images[is[i],])
})
tmp <- Reduce(rbind, tmp)
tmp %>% ggplot(aes(Row, Column, fill=value)) +
    geom_raster() +
    scale_y_reverse() +
    scale_fill_gradient(low="white", high="black") +
    facet_grid(.~label) +
    geom_vline(xintercept = 14.5) +
    geom_hline(yintercept = 14.5)

# fits a logistics regression with x_1 and x_2 as feat
fit_glm <- glm(y ~ x_1 + x_2, data=mnist_27$train, family = "binomial")
p_hat_glm <- predict(fit_glm, mnist_27$test)
# if p^(7) > 50% then 7 else 2
y_hat_glm <- factor(ifelse(p_hat_glm > 0.5, 7, 2))
confusionMatrix(data = y_hat_glm, reference = mnist_27$test$y)
confusionMatrix(data = y_hat_glm, reference = mnist_27$test$y)$overall["Accuracy"]

# plots the true conditional prob P(Y = 1 | X1 = x1, X2 = x2)
# we see that p = 0.5 in a parabola of x1 = f(x2)
mnist_27$true_p %>% ggplot(aes(x_1, x_2, fill=p)) +
    geom_raster()

mnist_27$true_p %>% ggplot(aes(x_1, x_2, z=p, fill=p)) +
    geom_raster() +
    scale_fill_gradientn(colors=c("#F8766D","white","#00BFC4")) +
    stat_contour(breaks=c(0.5), color="black") 

# plots the estimated conditional prob P^(Y = 1 | X1 = x1, X2 = x2)
# we see that p = 0.5 as a linear function of x1 = f(x2)
# p = g^-1(X) = 0.5 => X = g(0.5) = 0 => x2 = -B0/B2 - B1/B2 * x1
# => the bounndary for a logistic regression is always a line
p_hat <- predict(fit_glm, newdata = mnist_27$true_p)
mnist_27$true_p %>%
    mutate(p_hat = p_hat) %>%
    ggplot(aes(x_1, x_2,  z=p_hat, fill=p_hat)) +
    geom_raster() +
    scale_fill_gradientn(colors=c("#F8766D","white","#00BFC4")) +
    stat_contour(breaks=c(0.5),color="black") 

p_hat <- predict(fit_glm, newdata = mnist_27$true_p)
mnist_27$true_p %>%
    mutate(p_hat = p_hat) %>%
    ggplot() +
    stat_contour(aes(x_1, x_2, z=p_hat), breaks=c(0.5), color="black") +
    geom_point(mapping = aes(x_1, x_2, color=y), data = mnist_27$test)