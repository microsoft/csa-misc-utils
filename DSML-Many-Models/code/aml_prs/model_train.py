# Licensed under the MIT license.

import os
from azureml.core import Run, Model
import joblib
from util.timeseries_utilities import ColumnDropper, SimpleLagger, SimpleCalendarFeaturizer, SimpleForecaster
from sklearn.metrics import mean_squared_error, mean_absolute_error
from sklearn.linear_model import LinearRegression
import numpy as np
import pandas as pd
def init():
    global ws
    current_run = Run.get_context()
    ws = current_run.experiment.workspace

    print("Init complete")


def run(mini_batch):
    print(f'run method start: {__file__}, run({mini_batch})')
    target_column= 'Quantity'
    timestamp_column= 'WeekStarting'
    drop_columns=['Revenue', 'Store', 'Brand']
    #Get the store and brand. They are unique from the group so just the first value is sufficient
    store = str(mini_batch['Store'].iloc[0])
    brand = str(mini_batch['Brand'].iloc[0])

    model_name="prs_"+store+"_"+brand
    test_size=20
    # 1.0 Format the input data from group by, put the time in the index
    data = mini_batch \
            .set_index('WeekStarting') \
            .sort_index(ascending=True)

    # 2.0 Split the data into train and test sets
    train = data[:-test_size]
    test = data[-test_size:]

    # 3.0 Create and fit the forecasting pipeline
    # The pipeline will drop unhelpful features, make a calendar feature, and make lag features
    lagger = SimpleLagger(target_column, lag_orders=[1, 2, 3, 4])
    transform_steps = [('column_dropper', ColumnDropper(drop_columns)),
                        ('calendar_featurizer', SimpleCalendarFeaturizer()), ('lagger', lagger)]
    forecaster = SimpleForecaster(transform_steps, LinearRegression(), target_column, timestamp_column)
    forecaster.fit(train)

    # 4.0 Get predictions on test set
    forecasts = forecaster.forecast(test)
    compare_data = test.assign(forecasts=forecasts).dropna()

    # 5.0 Calculate accuracy metrics for the fit
    mse = mean_squared_error(compare_data[target_column], compare_data['forecasts'])
    rmse = np.sqrt(mse)
    mae = mean_absolute_error(compare_data[target_column], compare_data['forecasts'])
    actuals = compare_data[target_column].values
    preds = compare_data['forecasts'].values
    mape = np.mean(np.abs((actuals - preds) / actuals) * 100)

    # 7.0 Train model with full dataset
    forecaster.fit(data)

    # 8.0 Save the pipeline and register model to AML
    joblib.dump(forecaster, model_name)#   
    model = Model.register(workspace=ws, model_name=model_name, model_path=model_name, tags={'mse':str(mse), 'mape': str(mape), 'rmse': str(rmse)})
    result =pd.DataFrame({'Store':[store],'Brand':[brand], 'mse':[mse], 'mape': [mape], 'rmse': [rmse], 'model_name':[model_name]})

    return result

