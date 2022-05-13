import pandas as pd
import os.path
import numpy as np
import matplotlib.pyplot as plt
from sklearn import linear_model
from sklearn import preprocessing
from sklearn import metrics
from sklearn.linear_model import LinearRegression
from sklearn.linear_model import LogisticRegression
from sklearn.preprocessing import PolynomialFeatures
from sklearn.metrics import mean_squared_error, r2_score

rmse =0 # Global RMSE value to be added into prediction.csv
data = pd.read_csv("SMP500_post_1950.csv")

# lets me change the range of data to train on
start = 0 
drops=np.arange(0,start,1)
data= data.drop(drops,axis=0)

# creates year and month features from date
data['date'] = pd.to_datetime(data['date'])
year = data['date'].dt.year
month = data['date'].dt.day
data.insert(10,"year",year)
data.insert(11,"month",month)

#calculates EMA for the training set
train=data.iloc[0:659-start,:]
print(train)
Ema=np.zeros(train.shape[0])
Ema[0]=train.iloc[0,train.shape[1]-1]
#calculates EMA for each row in training set
for i in range(1,train.shape[0]):
  a=2/(train.shape[0]+1)
  Ema[i]=a*train.iloc[i,train.shape[1]-1]+(1-a)*Ema[i-1] # equation based off EMA(t)=(1/(n+1))*currentprice+(1-(1/(n+1))) * EMA(t-1)
train.insert(12,"EMA",Ema)

# inserts place holder EMA for test data
test=data.iloc[659-start:,:]
EMAtest=np.full(test.shape[0],Ema[train.shape[0]-1])
test.insert(12,"EMA",EMAtest)


#splits into train data pre 2005, test data = 2005 and above
xtrain= train.iloc[:,10:13]
ytrain= train['residualsCube']
xtest= test.iloc[:,10:13]
ytest= test['residualsCube']
print(xtrain)
print(ytrain)

def Learn(x,y):
  x=x.values
  y=y.values
  #transforms the features into ones with multiple degrees
  polynomial = PolynomialFeatures(degree=2, include_bias=False)
  polyx = polynomial.fit_transform(x)
  # creates a model using lasso Regression
  reg = linear_model.Lasso()
  # fit the model
  model = reg.fit(polyx, y)
  # get predictions for the test set
  predictions = model.predict(polyx)
  #calculates r2 and rmse, this rmse will be passed to the enseemble 
  r2 = r2_score(y, predictions)
  rmse = mean_squared_error(y, predictions, squared=False)
  print ("Scores and coef for the test set")
  print('The r2 is: ', r2)
  print('The rmse is: ', rmse)
  print("coef are ",model.coef_)
  print("intercept is " , model.intercept_)
  
  #plots actual test data vs predicted
  months = np.arange(1,x.shape[0]+1,1)
  plt.plot(months, y, color='black', label='HousVacant')
  plt.plot(months, predictions, color='r', label='HousVacant')
  plt.show()
  return model, rmse

def stageredtest(model,xdata,y,trainx):
  #creates array to store predictions
  predictions = np.zeros(y.shape[0])
  #iterates over the time series we want to predict, one month at a time
  for i in range (0,xdata.shape[0]):
    # gets a single row of data
    x=xdata.iloc[i,:]
    x=x.values
    x=x.reshape(1, -1)
    # polynomializes that row
    polynomial = PolynomialFeatures(degree=2, include_bias=False)
    polyx = polynomial.fit_transform(x)

    # creates a prediction using the model for one row of data
    predictions[i] = model.predict(polyx)

    #calculates the EMA for the next months prediction, using the same formula as above
    a=2/(xtrain.shape[0]+i)
    if ( i < xdata.shape[0]-1): # doesnt calculate next EMA if we are predicting the last value
      xdata.iloc[i+1,2]=a*predictions[i]+(1-a)*xdata.iloc[i,2]

  r2 = r2_score(y, predictions)
  rmsepr = mean_squared_error(y, predictions, squared=False)
  print("model preformance of the test set")
  print('The r2 is: ', r2)
  print('The rmse is: ', rmsepr)

  #displays actual test data vs predicted
  months = np.arange(1,xdata.shape[0]+1,1)
  plt.plot(months, y, color='black', label='HousVacant')
  plt.plot(months, predictions, color='r', label='HousVacant')
  plt.show()

  #saves prediction to be used by ensemble
  future = pd.DataFrame(predictions, columns=['prediction'])
  future.insert(1,"RMSE",np.full(future.shape[0],rmse))
  future.to_csv('futurepredictionsNate.csv',index=False) 


model,rmse = Learn(xtrain,ytrain)
#test(model,xtest,ytest,scaler)
stageredtest(model,xtest,ytest,xtrain)