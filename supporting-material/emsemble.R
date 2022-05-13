## Author: Austin Stephen
## date: 4/22/2022

library(tidyverse)

# Read in the data --------------------------------------------------------
data <- read_csv("data/SMP500_post_1950.csv")

# 1950
data_1950 <- data %>% filter( dateNumeric > 28854)

# get the training data
training_data <- data_1950 %>% filter(dateNumeric < 48943)
test_data <- data_1950 %>% filter(dateNumeric >= 48943)


# Read and transform model results ----------------------------------------

# my model
Austin <- read.csv("data/AustinModel1.csv")

# Natalie's
Natalie <- read.csv("data/NatModel1.csv") %>%
  rename(predictions = "preds") %>%
  mutate(rmse = 296.95) %>%
  select(-c(X))

# Nate's
Nathan <- read.csv("data/futurepredictionsNate.csv")%>%
  rename(predictions = "prediction",
         rmse = "RMSE")

# Collin's  
Colin <- read.csv("data/ColinModel1.csv", col.names = FALSE)%>%
  mutate( rmse = 76.5998 ) %>%
  rename( predictions = "FALSE." )

Colin <- rbind(Colin,c(33.661,76.5998))

# computing how bad the models all are
total_errors <- Austin$rmse[1] + Natalie$rmse[1] + Nathan$rmse[1] + Colin$rmse[1] 

# Compute the weighted sum
stationary_prediction <- (Austin$predictions * (Austin$rmse/total_errors)) + 
  (Natalie$predictions * (Natalie$rmse/total_errors)) +
  (Nathan$predictions * (Nathan$rmse/total_errors)) +
  (Colin$predictions* (Colin$rmse/total_errors))

# Add back in the model predictions
# building the model to get the residuals
mCube <- lm(SP500 ~ dateNumeric + dateNumeric2 + dateNumeric3, data=training_data) 
test_data$prediction <- stationary_prediction + predict(mCube,test_data)

# plotting out predictions
test_data %>% ggplot(aes(x=dateNumeric, y= prediction))+ 
    geom_point()+
    geom_smooth()
  

# plotting the real world
test_data %>% ggplot(aes(x=dateNumeric, y= SP500))+ 
  geom_point()

# plotting them together 
test_data %>% ggplot(aes(x=dateNumeric,y=prediction))+
  geom_point()+
  geom_point(aes(y = SP500, color = "red"),size = .75)+
  theme_classic()+
  labs(title = "Harmonic Regression Final Predictions (Red)",
       legend.position = "none")+
  ylab("Market Residual")+
  xlab("Date")+
  theme_classic() +
  theme(axis.text.x = element_blank())

