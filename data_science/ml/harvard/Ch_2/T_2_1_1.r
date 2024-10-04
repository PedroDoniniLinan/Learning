library(tidyverse)
library(dslabs)
library(caret)
library(dplyr)
library(lubridate)
data(reported_heights)

dat <- mutate(reported_heights, date_time = ymd_hms(time_stamp)) %>%
  filter(date_time >= make_date(2016, 01, 25) & date_time < make_date(2016, 02, 1)) %>%
  mutate(type = ifelse(day(date_time) == 25 & hour(date_time) == 8 & between(minute(date_time), 15, 30), "inclass","online")) %>%
  select(sex, type)

y <- factor(dat$sex, c("Female", "Male"))
x <- dat$type

df <- dat %>% group_by(type) %>% count(sex)
df

types <- c("inclass", "online")
prevalence <- map_chr(types, function(x){
  type_summary <- df[which(df$type == x), ]
  type_summary$sex[which.max(type_summary$n)]
})
prevalence

y_hat <- ifelse(dat$type == "inclass", prevalence[1], prevalence[2]) %>% 
  factor(levels = levels(y))
mean(y_hat == y)

table(y_hat, y)
sensitivity(data = y_hat, reference = y)
specificity(data = y_hat, reference = y)

dat %>% count(sex)