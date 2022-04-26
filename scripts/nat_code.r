#Pattern forcasting on financial data, Natalie Foss

library(PSF)
library(dplyr)
library(tidyr)
library(tidyverse)

# reading in data and generating train and test split
post_1950 <- read.csv("~/Documents/ml/finalProject/repo/data/SMP500_post_1950.csv")

# making a month col
post_1950 <- post_1950 %>%
  dplyr::mutate(month = lubridate::day(date),
                year = lubridate::year(date))
post_1950 <- select(post_1950, c("month", "year", "date", "residualsCube"))

summary(post_1950)

# train set
train <- post_1950[post_1950$date >= "1951-01-01" & post_1950$date < "2005-01-01", ]
train <- select(train, c("month", "year", "residualsCube"))
train <- train %>% pivot_wider(
  names_from = month, 
  values_from = residualsCube
)
trainYearVec <- train$year
train <- select(train, c("1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"))
rownames(train) <- trainYearVec

# test set
test <- post_1950[post_1950$date >= "2005-01-01", ]
test <- select(test, c("month", "year", "residualsCube", "date"))


# building model using psf() function
model <- psf(train, cycle = 12)
model


# performing predictions:
smp_preds <- predict(model, n.ahead = 160)
smp_preds <- smp_preds[1:160]
smp_preds

test["preds"] <- smp_preds
rmse <- sum(sqrt((test$residualsCube - test$preds)**2))



# plots
test %>% ggplot(aes(x=date,y=residualsCube))+
  geom_point()+
  geom_point(aes(y = test$preds, color = "red"), size = .5)+
  theme_classic()


tmp <- select(test, c("preds"))

write.csv(tmp,"~/Documents/ml/finalProject/repo/data/nat_predictions.csv", row.names = TRUE)

