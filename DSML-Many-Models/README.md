# Many-Models
Implement many models for ML in Azure 

There are many scenarios where we need to build and run a large number of machine learning models. For examples: in Retail where a separate revenue forecast model is needed for each store and brand, in Supply Chain where Inventory Optimization is done for each warehouse and product, in Restaurant where demand forecasting models are needed across thousands of restaurants etc. This pattern is commonly referred to as Many Models. While Azure ML Platform team has published a popular [accelerator](https://github.com/microsoft/solution-accelerator-many-models/blob/master/Custom_Script/scripts/timeseries_utilities.py) using Azure Parallel Run Step (PRS) and AutoML, I’d like to expand it further with additional options to simplify the implementation and address more business technology scenarios such as option of using Spark in Databricks and Synapse or with AML PRS but with tabular data instead of file dataset.

Option 1: [Implementing Many Models using Spark 3.x in Azure Synapse Spark or Azure Databricks](./code/spark/many_models_spark.ipynb)

Option 2: [Implementing Many Models using Azure ML Parallel Run Step and Azure ML Pipeline](./code/aml_prs/prs_many_models.ipynb)

The two approaches share same [util file](./code/util/timeseries_utilities.py) which is copied from [Many Model Accelerator repo](https://github.com/microsoft/solution-accelerator-many-models/blob/master/Custom_Script/scripts/timeseries_utilities.py)