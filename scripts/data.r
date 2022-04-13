## Author: Austin Stephen
## date: 4/12/2022

library(dplyr)
library(tidyverse)

data <- read.csv("data/SMP500.csv")

## discretize the data, date management 
data <- data %>% mutate(
    date = as.Date(Date,format ="%Y-%d-%m"),
    dateNumeric = as.numeric(date) + 36159,
    dateNumeric2 = dateNumeric**2,
    dateNumeric3 = dateNumeric**3,
    discrRes1 = as.factor(round(SP500, digits = 0)),
    discrRes2 = as.factor(round(SP500/10, digits = 0) *10),
    discrRes3 = as.factor(round(SP500/100, digits = 0) *100),
    discrRes4 = as.factor(round(SP500/200, digits = 0) * 200),
    discrRes5 = as.factor(round(SP500/350, digits = 0) * 350),
    discrRes6 = as.factor(round(SP500/400, digits = 0) * 400),
    discrRes7 = as.factor(round(SP500/1000, digits = 0) * 1000)
    ) %>%
  select(-Date)
#summary(data)

## building models to look at the residuals
mLinear <- lm(SP500 ~ dateNumeric, data=data)

mQuad <- lm(SP500 ~ dateNumeric + dateNumeric2, data=data)  

mCube <- lm(SP500 ~ dateNumeric + dateNumeric2 + dateNumeric3, data=data)  

data$residualsLinear <- mLinear$residuals
data$residualsQuad <- mQuad$residuals
data$residualsCube <- mCube$residuals

# plotting the data and looking at the residuals
data %>% ggplot(aes(x=dateNumeric, y=SP500))+
  geom_point()+
  geom_smooth(method = "lm")

data %>% ggplot(aes(x=dateNumeric, y=residualsLinear))+
  geom_point()+
  geom_smooth(method = )

data %>% ggplot(aes(x=dateNumeric, y=residualsQuad))+
  geom_point()+
  geom_smooth()

data %>% ggplot(aes(x=dateNumeric, y=residualsCube))+
  geom_point()+
  geom_smooth()

dataWrite <- data %>% select(-c(dateNumeric2,dateNumeric3))
## writting the data
write.csv(dataWrite,"data/SMP500_mod.csv", row.names = FALSE)
#tmp<- read.csv("data/SMP500_mod.csv")


# Repeating everything for post 1900 --------------------------------------

# remove observations pre 1900
data_1900 <- data %>% filter( dateNumeric > 10592)


# building models to get the residuals
mLinear <- lm(SP500 ~ dateNumeric, data=data_1900)

mQuad <- lm(SP500 ~ dateNumeric + dateNumeric2, data=data_1900)  

mCube <- lm(SP500 ~ dateNumeric + dateNumeric2 + dateNumeric3, data=data_1900)  

# summary(mLinear)
# summary(mQuad)
# summary(mCube)

data_1900$residualsLinear <- mLinear$residuals
data_1900$residualsQuad <- mQuad$residuals
data_1900$residualsCube <- mCube$residuals

# removing junk columns
dataWrite <-data_1900 %>% select(-c(dateNumeric2,dateNumeric3))

## writting the data
write.csv(dataWrite,"data/SMP500_post_1900.csv", row.names = FALSE)

# Repeating everything from 1950 on ---------------------------------------
# Repeating everything for post 1900 --------------------------------------

# remove observations pre 1900
data_1950 <- data %>% filter( dateNumeric > 28854)


# building models to get the residuals
mLinear <- lm(SP500 ~ dateNumeric, data=data_1950)

mQuad <- lm(SP500 ~ dateNumeric + dateNumeric2, data=data_1950)  

mCube <- lm(SP500 ~ dateNumeric + dateNumeric2 + dateNumeric3, data=data_1950)  

# summary(mLinear)
# summary(mQuad)
# summary(mCube)

data_1950$residualsLinear <- mLinear$residuals
data_1950$residualsQuad <- mQuad$residuals
data_1950$residualsCube <- mCube$residuals

# removing junk columns
dataWrite <-data_1950 %>% select(-c(dateNumeric2,dateNumeric3))

## writting the data
write.csv(dataWrite,"data/SMP500_post_1950.csv", row.names = FALSE)

