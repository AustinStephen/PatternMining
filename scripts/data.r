## Author: Austin Stephen
## date: 4/12/2022

library(dplyr)
library(tidyverse)

data <- read.csv("data/SMP500.csv")

## discretize the data, date management 
data <- data %>% mutate(
    date = as.Date(Date,format ="%Y-%d-%m"),
    dateNumeric = as.numeric(date),
    discrRes1 = as.factor(round(SP500, digits = 0)),
    discrRes2 = as.factor(round(SP500/10, digits = 0) *10),
    discrRes3 = as.factor(round(SP500/100, digits = 0) *100),
    discrRes4 = as.factor(round(SP500/200, digits = 0) * 200),
    discrRes5 = as.factor(round(SP500/350, digits = 0) * 350),
    discrRes6 = as.factor(round(SP500/400, digits = 0) * 400),
    discrRes7 = as.factor(round(SP500/1000, digits = 0) * 1000)
    ) %>%
  select(-Date)

summary(data)
## getting the residuals
model <- lm(SP500 ~ dateNumeric, data=data)

summary(model)

data$residuals <- model$residuals

write.csv(data,"data/SMP500_mod.csv")

tmp<- read.csv("data/SMP500_mod.csv")
