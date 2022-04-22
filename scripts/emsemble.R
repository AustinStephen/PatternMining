## Author: Austin Stephen
## date: 4/22/2022


# Read in the data --------------------------------------------------------

Austin <- read.csv("data/AustinModel1.csv")
Natalie <- read.csv("data/AustinModel1.csv")
Nathan <- read.csv("data/AustinModel1.csv")
Colin <- read.csv("data/AustinModel1.csv")

# Compute the weighted sum
prediction <- (Austin$predictions * (1/Austin$rmse)) + 
  (Natalie$predictions * (1/Natalie$rmse)) +
  (Nathan$predictions * (1/Nathan$rmse)) +
  (Colin$predictions * (1/Colin$rmse))

# Add back in the model predictions