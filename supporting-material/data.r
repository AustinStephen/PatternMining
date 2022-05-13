## Author: Austin Stephen
## date: 4/12/2022

library(dplyr)
library(tidyverse)

data <- read.csv("data/SMP500.csv")

## date to numeric so models can be built 
data <- data %>% mutate(
  date = as.Date(Date,format ="%Y-%d-%m"),
  dateNumeric = as.numeric(date) + 36159,
  dateNumeric2 = dateNumeric**2,
  dateNumeric3 = dateNumeric**3)


## building models to look at the residuals
mLinear <- lm(SP500 ~ dateNumeric, data=data)

mQuad <- lm(SP500 ~ dateNumeric + dateNumeric2, data=data)  

mCube <- lm(SP500 ~ dateNumeric + dateNumeric2 + dateNumeric3, data=data)  

data$residualsLinear <- mLinear$residuals
data$residualsQuad <- mQuad$residuals
data$residualsCube <- mCube$residuals

# plotting the data and looking at the residuals
data %>% ggplot(aes(x=dateNumeric, y=SP500))+
  theme_classic()+
  geom_point()+
  xlab("Date")+
  ylab("Value")+
  labs(title ="SMP500")+
  geom_vline(xintercept = 48943, size = 1.25, color= "darkblue")+
  geom_vline(xintercept = 28855, size = 1.25, color= "darkgreen")+
  theme(axis.text.x = element_blank())
  
  
  geom_smooth(method = "lm")

data %>% ggplot(aes(x=dateNumeric, y=residualsLinear))+
  geom_point()+
  geom_smooth(method = )

data %>% ggplot(aes(x=dateNumeric, y=residualsQuad))+
  geom_point()+
  geom_smooth()

data %>% ggplot(aes(x=dateNumeric, y=residualsCube))+
  theme_classic()+
  geom_point()+
  xlab("Date")+
  ylab("Residaul")+
  labs(title ="SMP500 Residuals")+
  theme(axis.text.x = element_blank())


## discretize the data for Natalie's work
data <- data %>% mutate(
  discrRes1 = as.factor(round(residualsCube/80, digits = 0)*80),
  discrRes2 = as.factor(round(residualsCube/110, digits = 0) *110),
  discrRes3 = as.factor(round(residualsCube/140, digits = 0) *140),
  discrRes4 = as.factor(round(residualsCube/150, digits = 0) * 150),
  discrRes5 = as.factor(round(residualsCube/175, digits = 0) * 175),
  discrRes6 = as.factor(round(residualsCube/200, digits = 0) * 200),
  discrRes7 = as.factor(round(residualsCube/250, digits = 0) * 250)
) %>%
  select(-Date)
#summary(data)

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

# remove observations pre 1950
data_1950 <- data %>% filter( dateNumeric > 28854)

data_1950$year <- format(data_1950$date, format="%Y")

# get the training data
training_data <- data_1950 %>% filter(dateNumeric < 48943)
test_data <- data_1950 %>% filter(dateNumeric >= 48943)

# building the model to get the residuals
mCube <- lm(SP500 ~ dateNumeric + dateNumeric2 + dateNumeric3, data=training_data)  

summary(mCube)
## residuals on the train data
resid <- mCube$residuals

## predicting on the test data
resid2 <- test_data$SP500 - predict(mCube,test_data)

# joining the residuals
full <- c(resid, resid2)

data_1950$residualsCube <- full

data_1950 %>% ggplot(aes(x=dateNumeric, y=residualsCube))+
  theme_classic()+
  geom_point()+
  xlab("Date")+
  ylab("Residaul")+
  labs(title ="SMP500 Residuals")+
  theme(axis.text.x = element_blank())

## writing the data
write.csv(data_1950,"data/SMP500_post_1950.csv", row.names = FALSE)

