# Licensed under the MIT license.

import os
from azureml.core import Model,Workspace
import joblib
import sys
sys.path.append("..")
import util.timeseries_utilities
from inference_schema.schema_decorators import input_schema, output_schema
import pandas as pd
from inference_schema.parameter_types.standard_py_parameter_type import StandardPythonParameterType
from inference_schema.parameter_types.numpy_parameter_type import NumpyParameterType
from inference_schema.parameter_types.pandas_parameter_type import PandasParameterType
from azureml.core.authentication import MsiAuthentication,ServicePrincipalAuthentication,TokenAuthentication, Audience
import json
import ast
# def get_token_for_audience(audience):
#     from adal import AuthenticationContext
#     client_id = "df3335cd-b8e2-4de8-86c1-a834e51e9b94"
#     # client_secret = "my-client-secret"
#     msi_endpoint = os.environ.get("MSI_ENDPOINT", None)
#     client_secret = os.environ.get("MSI_SECRET", None)
#     print("the secret is ",client_secret)
#     print(" the endpoint is ", msi_endpoint)


#     tenant_id ='72f988bf-86f1-41af-91ab-2d7cd011db47' 
#     auth_context = AuthenticationContext("https://login.microsoftonline.com/{}".format(tenant_id))
#     resp = auth_context.acquire_token_with_client_credentials(audience,client_id,client_secret)
#     token = resp["accessToken"]
#     print("get token back, ", token)
#     return token

def init():
    global ws
    # tenant_id ='72f988bf-86f1-41af-91ab-2d7cd011db47' 
    # service_principal_id='af883abf-89dd-4889-bdb3-1ee84f68465e'
    # service_principal_password='QQ_w21c~7f.f41ir.9DbV.jDEpH4TouZ.0'
    subscription_id = '0e9bace8-7a81-4922-83b5-d995ff706507'
    # # Azure Machine Learning resource group NOT the managed resource group
    resource_group = 'azureml' 
    workspace_name = 'ws01ent'
    # sp_auth = ServicePrincipalAuthentication(tenant_id =tenant_id,
    #                                      service_principal_id=service_principal_id,
    #                                      service_principal_password=service_principal_password)


    # ws = Workspace.get(name=workspace_name,
    #                     subscription_id=subscription_id,
    #                     resource_group=resource_group,auth= sp_auth)


    try:
        msi_auth = MsiAuthentication()
        print("MSI is successful")
    except:
        print(" exception getting MSI")

    ws = Workspace(subscription_id=subscription_id,
                    resource_group=resource_group,
                    workspace_name=workspace_name,
                    auth=msi_auth)


    print("Found workspace {} at location {}".format(ws.name, ws.location))



sample_input_values ={"WeekStarting":{"0":"1991-01-24","1":"1991-01-31","2":"1991-02-07","3":"1991-02-14","4":"1991-02-21","5":"1991-02-28","6":"1991-03-07","7":"1991-03-14","8":"1991-03-21","9":"1991-03-28","10":"1991-04-04","11":"1991-04-11","12":"1991-04-18","13":"1991-04-25","14":"1991-05-02","15":"1991-05-09","16":"1991-05-16","17":"1991-05-23","18":"1991-05-30","19":"1991-06-06"},"Store":{"0":1002,"1":1002,"2":1002,"3":1002,"4":1002,"5":1002,"6":1002,"7":1002,"8":1002,"9":1002,"10":1002,"11":1002,"12":1002,"13":1002,"14":1002,"15":1002,"16":1002,"17":1002,"18":1002,"19":1002},"Brand":{"0":"tropicana","1":"tropicana","2":"tropicana","3":"tropicana","4":"tropicana","5":"tropicana","6":"tropicana","7":"tropicana","8":"tropicana","9":"tropicana","10":"tropicana","11":"tropicana","12":"tropicana","13":"tropicana","14":"tropicana","15":"tropicana","16":"tropicana","17":"tropicana","18":"tropicana","19":"tropicana"},"Quantity":{"0":9715,"1":18991,"2":13250,"3":11520,"4":16200,"5":19683,"6":11195,"7":16313,"8":9924,"9":11892,"10":9783,"11":14064,"12":12070,"13":12416,"14":11680,"15":17474,"16":19523,"17":14042,"18":13203,"19":13242},"Advert":{"0":1,"1":1,"2":1,"3":1,"4":1,"5":1,"6":1,"7":1,"8":1,"9":1,"10":1,"11":1,"12":1,"13":1,"14":1,"15":1,"16":1,"17":1,"18":1,"19":1},"Price":{"0":2.16,"1":2.27,"2":2.42,"3":2.6,"4":2.09,"5":2.63,"6":2.21,"7":2.38,"8":2.55,"9":2.19,"10":2.59,"11":2.06,"12":2.36,"13":2.08,"14":2.03,"15":2.25,"16":2.02,"17":2.16,"18":2.6,"19":1.94},"Revenue":{"0":20984.4,"1":43109.57,"2":32065.0,"3":29952.0,"4":33858.0,"5":51766.29,"6":24740.95,"7":38824.94,"8":25306.2,"9":26043.48,"10":25337.97,"11":28971.84,"12":28485.2,"13":25825.28,"14":23710.4,"15":39316.5,"16":39436.46,"17":30330.72,"18":34327.8,"19":25689.48}}
            
sample_output_values ={'WeekStarting':['1990-06-14','1990-06-21','1990-06-28','1990-07-05','1990-07-12'], 
                    'Store':['1000','1000','1000','1000','1000'],
                    'Brand':['dominicks','dominicks','dominicks','dominicks','dominicks'],
                    'Prediction':[10.2,10.3,10.2,10.3, 10.2]}
sample_input = PandasParameterType(pd.DataFrame(sample_input_values))
sample_output = PandasParameterType(pd.DataFrame(sample_output_values))

# @output_schema(sample_output)
# @input_schema('Inputs', sample_input) 
def run(raw_data):
    Inputs = pd.DataFrame(ast.literal_eval(json.loads(raw_data)['Inputs']))

    timestamp_column= 'WeekStarting'
    Inputs[timestamp_column]=pd.to_datetime(Inputs[timestamp_column])

    timeseries_id_columns= [ 'Store', 'Brand']
    data = Inputs \
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
  

    return prediction_df.to_json()
