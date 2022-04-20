## Author: Austin Stephen
## Date: 4/13/2022

# get the data
data <- read_csv("data/SMP500_post_1900.csv")


# Build the model ---------------------------------------------------------
# Note:
# Building a harmonic regression model that allows for noise but not trend.
# As a result, it will be trained on the residuals of the model used to subtract
# out the trend in the data.


## The

