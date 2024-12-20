## SemForms: An Introduction
SemForms is a system to extract data wrangling and data explorations from data science code.  
The goal of SemForms is to allow data scientists to collaborate with each other, to understand and 
re-use what other data scientists may have been performed on similar datasets.  

## Overview
SemForms has three components:
1.  A search for code module that fetches code relevant to a dataset (the search fetches code that may mention similar data by file name, or by columns in the dataset.  A semantic similarity step filters code that is relevant using neural embeddings of table and column names.
2.  An analysis component that re-uses the Graph4Code analysis, enhanced with reads and writes to data structures in Python, so we can track for instance reads or writes of a Pandas DataFrame, and extract data manipulations or explorations on it.
3.  An index that gathers up these data transforms/data exploratoratory in a re-usable way, so you can have code that is readily applicable to a new data frame.

## Installation of the elastic search index (Runs the elastic search service in a docker container)
1.  `export ELASTIC_PASSWORD=<PASSWORD>`
2.  `cd elastic`
3.  `bash init_elastic_search.sh`

## Installation of the analysis component (Runs the analysis/expression extraction service in a docker container)
1. `export ELASTIC_PASSWORD=<PASSWORD>`
3. `build_expression_server.sh`
4. `run_expression_server.sh`

## Installation of the search for code component (Runs the search for code service in a docker container)
1. `export GH_TOKEN=<github access token>` to access GitHub API
2. `cd github`
3. `build_gh_server.sh`
4. `run_gh_server.sh`
## An illustrative example
1.  For a notebook that shows the different components of SemForms look at [this notebook](https://github.com/wala/graph4code/blob/master/semForms/ExampleExpressions.ipynb)
2.  For a notebook that shows the analysis artifacts behind expression extractions look at [here](https://github.com/wala/graph4code/blob/master/semForms/ExampleAnalysis.ipynb)

## AutoML Evaluation
We also show how one can use SemForms to get a list of recommended expressions from SemForms [automl_eval/evaluate_openml_datasets.py](https://github.com/wala/graph4code/blob/master/semForms/automl_eval/evaluate_openml_datasets.py). For a given dataset (can be changed [here](https://github.com/wala/graph4code/blob/master/semForms/automl_eval/evaluate_openml_datasets.py#L250)), the code finds relevant expressions, evaluates and appends it to the input dataset. Then, it computes the correlation of the new expressions with the target column (retrieved from OpenML) and optionally train a simple model to test it. The code assumes an ES index running on port 9200 (can be changed here) and requires an `ES_PASSWORD` to be exported an environment variable. 
