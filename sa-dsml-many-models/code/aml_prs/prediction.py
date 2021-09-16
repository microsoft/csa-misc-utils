# Licensed under the MIT license.

import os
from azureml.core import Run, Model
import joblib
import util.timeseries_utilities

def init():
    global ws
    current_run = Run.get_context()
    ws = current_run.experiment.workspace

    print("Init complete")


def run(mini_batch):
    print(f'run method start: {__file__}, run({mini_batch})')

    timestamp_column= 'WeekStarting'

    timeseries_id_columns= [ 'Store', 'Brand']
    data = mini_batch \
            .set_index(timestamp_column) \
            .sort_index(ascending=True)
    #Prepare loading model from Azure ML, get the latest model by default
    model_name="prs_"+str(data['Store'].iloc[0])+"_"+str(data['Brand'].iloc[0])
    model = Model(ws, model_name)
    model.download(exist_ok =True)
    forecaster = joblib.load(model_name)

    #   Get predictions 
    #This is to append the store and brand column to the result
    ts_id_dict = {id_col: str(data[id_col].iloc[0]) for id_col in timeseries_id_columns}
    forecasts=forecaster.forecast(data)
    prediction_df = forecasts.to_frame(name='Prediction')
    prediction_df =prediction_df.reset_index().assign(**ts_id_dict)
  

    return prediction_df
