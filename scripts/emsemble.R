## Author: Austin Stephen
## date: 4/22/2022


# Read in the data --------------------------------------------------------
data <- read_csv("data/SMP500_post_1950.csv")

# 1950
data_1950 <- data %>% filter( dateNumeric > 28854)

# get the training data
training_data <- data_1950 %>% filter(dateNumeric < 48943)
test_data <- data_1950 %>% filter(dateNumeric >= 48943)

# read in every individual model results
Austin <- read.csv("data/AustinModel1.csv")
Natalie <- read.csv("data/AustinModel1.csv")
Nathan <- read.csv("data/AustinModel1.csv")
Colin <- read.csv("data/AustinModel1.csv")

# computing how bad the models all are
total_errors <- Austin$rmse*5 + Natalie$rmse*2 + Nathan$rmse + Colin$rmse 

# Compute the weighted sum
stationary_prediction <- (Austin$predictions * (Austin$rmse/total_errors)) + 
  (Natalie$predictions+15 * (Natalie$rmse/total_errors)) +
  (Nathan$predictions+20 * (Nathan$rmse/total_errors)) +
  (Colin$predictions*2 * (Colin$rmse/total_errors))

# Add back in the model predictions
# building the model to get the residuals
mCube <- lm(SP500 ~ dateNumeric + dateNumeric2 + dateNumeric3, data=training_data) 
test_data$prediction <- stationary_prediction + predict(mCube,test_data)

test_data %>% ggplot(aes(x=dateNumeric, y= prediction))+ 
                       geom_point()

test_data %>% ggplot(aes(x=dateNumeric, y= SP500))+ 
  geom_point()
