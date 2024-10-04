library(tidyverse)
library(caret)
library(dslabs)
data("heights")

# group by height and check prob of being male
# small samples for some specific heights causa high variability
heights %>% 
	mutate(height = round(height)) %>%
	group_by(height) %>%
	summarize(p = mean(sex == "Male")) %>%
    qplot(height, p, data =.)

# group by quartiles of heights and check prob of being male
# check the mean height of the quartile and prob of being male
# solves variability
ps <- seq(0, 1, 0.1)
heights %>% 
	mutate(g = cut(height, quantile(height, ps), include.lowest = TRUE)) %>%
	group_by(g) %>%
	summarize(p = mean(sex == "Male"), height = mean(height)) %>%
	qplot(height, p, data =.)

sigma <- 9*matrix(c(1,0.5,0.5,1), 2, 2)
dat <- MASS::mvrnorm(n = 10000, c(69, 69), sigma) %>%
	data.frame() %>% setNames(c("x", "y"))


# conditional expection of a bivariate normal distribution
# E[Y|X=x]
ps <- seq(0, 1, 0.1)
dat %>% 
    mutate(g = cut(x, quantile(x, ps), include.lowest = TRUE)) %>%
	group_by(g) %>%
	summarize(y = mean(y), x = mean(x)) %>%
	qplot(x, y, data =.)