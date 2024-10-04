library(tidyverse)
library(caret)
library(dslabs)
data(iris)
iris <- iris[-which(iris$Species=='setosa'),]
y <- iris$Species

# set.seed(2) # if using R 3.5 or earlier
set.seed(2, sample.kind="Rounding") # if using R 3.6 or later
test_index <- createDataPartition(y, times = 1, p = 0.5, list = FALSE)
test <- iris[test_index,]
train <- iris[-test_index,]

iris %>% group_by(Species) %>% summarize(mean(Sepal.Length), sd(Sepal.Length), )
iris %>% group_by(Species) %>% summarize(mean(Sepal.Width), sd(Sepal.Width), )
iris %>% group_by(Species) %>% summarize(mean(Petal.Length), sd(Petal.Length), )
iris %>% group_by(Species) %>% summarize(mean(Petal.Width), sd(Petal.Width), )

calculate_max_acc <- function(c, col) {
    accuracy <- map_dbl(c, function(x){
    y_hat <- ifelse(col > x, "virginica", "versicolor") %>% 
        factor(levels = levels(test$Species))
    mean(y_hat == train$Species)
    })

    best_cutoff <- cutoff[which.max(accuracy)]

    c(max(accuracy)[1], best_cutoff[1])
}

cutoff <- seq(4.9, 6.9, by=0.2)
res <- calculate_max_acc(cutoff, train$Sepal.Length)
res

cutoff <- seq(2.1, 3.3, by=0.2)
res <- calculate_max_acc(cutoff, train$Sepal.Width)
res

cutoff <- seq(0.9, 1.7, by=0.2)
res <- calculate_max_acc(cutoff, train$Petal.Width)
res

cutoff <- seq(3.2, 5.2, by=0.01)
res <- calculate_max_acc(cutoff, train$Petal.Length)
res

y_hat <- ifelse(test$Petal.Length > res[2], "virginica", "versicolor") %>% 
  factor(levels = levels(test$Species))
mean(y_hat == test$Species)

calculate_max_test_acc <- function(c, col) {
    accuracy <- map_dbl(c, function(x){
    y_hat <- ifelse(col > x, "virginica", "versicolor") %>% 
        factor(levels = levels(test$Species))
    mean(y_hat == test$Species)
    })

    best_cutoff <- cutoff[which.max(accuracy)]

    c(max(accuracy)[1], best_cutoff[1])
}

cutoff <- seq(4.9, 6.9, by=0.2)
res <- calculate_max_test_acc(cutoff, test$Sepal.Length)
res

cutoff <- seq(2.1, 3.3, by=0.2)
res <- calculate_max_test_acc(cutoff, test$Sepal.Width)
res

cutoff <- seq(0.9, 1.7, by=0.2)
res <- calculate_max_test_acc(cutoff, test$Petal.Width)
res

cutoff <- seq(3.2, 5.2, by=0.01)
res <- calculate_max_test_acc(cutoff, test$Petal.Length)
res

plot(iris,pch=21,bg=iris$Species)

cutoff <- seq(0.9, 1.7, by=0.2)
wid <- calculate_max_acc(cutoff, train$Petal.Width)
wid

cutoff <- seq(3.2, 5.2, by=0.01)
len <- calculate_max_acc(cutoff, train$Petal.Length)
len

y_hat <- ifelse(test$Petal.Length > len[2] | test$Petal.Width > wid[2], "virginica", "versicolor") %>% 
  factor(levels = levels(test$Species))
mean(y_hat == test$Species)