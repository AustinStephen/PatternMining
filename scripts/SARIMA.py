import statsmodels.api as sm
import csv
from statsmodels.graphics.tsaplots import plot_pacf
from statsmodels.graphics.tsaplots import plot_acf
from statsmodels.tsa.statespace.sarimax import SARIMAX
from statsmodels.tsa.holtwinters import ExponentialSmoothing
from statsmodels.tsa.stattools import adfuller
import matplotlib.pyplot as plt
from tqdm import tqdm_notebook
import numpy as np
import pandas as pd
import scipy
from patsy import dmatrices
import statsmodels
import math
from itertools import product
import warnings
import seaborn as sns
sns.set(style='ticks', context='poster')
from statsmodels.tsa.seasonal import seasonal_decompose
#plt.style.use("ggplot")

warnings.filterwarnings('ignore')



data = pd.read_csv('SMP500.csv')

data2 = pd.read_csv('SMP500_post_1950.csv')

data3 = pd.read_csv('SMP500_mod.csv')

resCubed= data3['residualsCube'].iloc[950:1610]

preddates = data['Date'].iloc[1609:]

fig = plt.figure(figsize=[30, 7.5]); # Set dimensions for figure

TrueRes = data3.iloc[950:1610, [13]]

dates = data['Date'].iloc[950::4]
dates = dates.iloc[:1610]
score = data['SP500'].iloc[950::4]
score = score.iloc[:1610]
data = pd.DataFrame(dates)
data = data.insert(1, "SP500", score, True)
plt.plot(dates, score)
plt.title('Yearly SP500')
plt.ylabel('Score')
plt.xlabel('Date')
plt.xticks(rotation=90)
spacing = 0.500
fig.subplots_adjust(bottom=spacing)
plt.grid(True)
plt.show()

#PACF and ACF with raw data

plot_pacf(score)
plt.show()
plot_acf(score)
plt.show()

ad_fuller_result = adfuller(score)
print(f'ADF Statistic: {ad_fuller_result[0]}')
print(f'p-value: {ad_fuller_result[1]}')

logscore = np.log(score)
logscore = logscore.diff()
logscore = logscore.drop(score.index[0])

plt.figure(figsize=[30, 7.5]); # Set dimensions for figure
plt.plot(logscore)
plt.title("Log Difference of Quarterly Score for SP500")
plt.show()

#ad-fuller test

ad_fuller_result = adfuller(logscore)
print(f'ADF Statistic: {ad_fuller_result[0]}')
print(f'p-value: {ad_fuller_result[1]}')

#new PACF and ACF with log data

plot_pacf(logscore);
plot_acf(logscore);
plt.show();

def optimize_SARIMA(parameters_list, d, D, s, exog):
    """
        Return dataframe with parameters, corresponding AIC and SSE
        
        parameters_list - list with (p, q, P, Q) tuples
        d - integration order
        D - seasonal integration order
        s - length of season
        exog - the exogenous variable
    """
    
    results = []
    
    for param in tqdm_notebook(parameters_list):
        try: 
            model = SARIMAX(exog, order=(param[0], d, param[1]), seasonal_order=(param[2], D, param[3], s)).fit(disp=-1)
        except:
            continue
            
        aic = model.aic
        results.append([param, aic])
        
    result_df = pd.DataFrame(results)
    result_df.columns = ['(p,q)x(P,Q)', 'AIC']
    #Sort in ascending order, lower AIC is better
    result_df = result_df.sort_values(by='AIC', ascending=True).reset_index(drop=True)
    
    return result_df

# test to select order with lowest AIC

p = range(0, 4, 1)
d = 1
q = range(0, 4, 1)
P = range(0, 4, 1)
D = 1
Q = range(0, 4, 1)
s = 12
parameters = product(p, q, P, Q)
parameters_list = list(parameters)
print(len(parameters_list))
#result_df = optimize_SARIMA(parameters_list, 1, 1, 12, resCubed)
#print(result_df)

best_model = statsmodels.tsa.statespace.sarimax.SARIMAX(resCubed, order=(0, 0, 0), seasonal_order=(1, 1, 0, 12))


TrueRes.to_numpy()


model_fit = best_model.fit()

residuals = model_fit.resid

print("These are the residuals here:")
print(residuals)
print("residuals stop")

square = np.square(residuals)

sum = sum(square)

RMSE = (sum/660) ** 0.5

print("This is the RMSE:")
print(RMSE)



yhat = model_fit.forecast(159)
plt.plot(preddates, yhat)
plt.show()

print(yhat)

with open('PLEASESARIMA.csv', 'w', encoding='UTF8', newline='') as f:
    writer = csv.writer(f)

    # write multiple rows
    writer.writerows(map(lambda x: [x], yhat))



