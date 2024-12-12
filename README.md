# Setup

To build the graph, first create a new conda environmet using:
   `conda create -n graph1 python=3.8 openjdk=8`
   
and install Ruby:

   `conda install ruby`
# load the graphdatabase:
in the scripts directory run the load_graph4code script:

   `./load_graph4code.sh`
  

# Create your own graph

### GraphGen4Code Pipeline<a name="pipeline"></a>

The figure below shows the overall pipeline of steps followed by GraphGen4Code to generate large-scale code knowledge graphs. 

<!---![](./docs/figures//graph4code_pipeline2.png)-->
<p align="center">
<img align="center" src="./docs/figures//graph4code_pipeline.png" width="90%"/>
</p>
<br><br>

We used the above pipeline to demonstrate the scalability of GraphGen4Code by creating a code knowledge graph of 2 billion facts about code. This graph was created using 1.3 million Python program and 47 million forum posts. The graph files are available [here](https://archive.org/download/graph4codev1). To load and query this data, please follow the instructions here: https://github.com/wala/graph4code/blob/master/docs/load_graph.md. We also provide scripts for creating a docker image with the graph database ready to use. 

We list below the steps needed to create your own graph.

## Requirements

1.  For this, create a conda environment with `conda create --name g4c python=3.9`. 
 
     `pip install bs4 rdflib validators torch xmltodict numpy`
 
     `pip install elasticsearch`
 
 
 2. Install ElasticSearch (tested with 8.2.1).  

     `wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.2.1-linux-x86_64.tar.gz`
 
     `tar -xzf elasticsearch-8.2.1-linux-x86_64.tar.gz` 
 
     `export ES_HOME=/data/graph4code/elasticsearch-8.2.1/config/certs/` 
 
     `cd elasticsearch-8.2.1/` 
 
     `./bin/elasticsearch`
 
     Elastic search now starts with a bunch of security features enabled.  Make sure to find the elastic search user password in its display when you start: `Password for the elastic user (reset with `bin/elasticsearch-reset-password -u elastic`):<password>`.  Export the password as an environment variable.  
     `export ES_PASSWORD=<password>`
     
You will also need an installation of `Java JDK 11` for running the jars of code analysis (next step).

## Code Analysis Graph

If you have a new script (code file), run the following command in the jars directory.  Please ensure you have Java 11 before you run.  Note that the last two arguments are to create a unique graph URI for each script that gets analyzed, where the graph URI is made up of <graph prefix> + '/' + <graph qualifier> for a single file.  Note also that we have migrated the RDF store model to RDF* to make it a more compact, easier to understand representation.  We have also added more information about each node.  Model definition will be updated soon.

We provide analysis for both Python 2 and Python 3.  Python 3 is the supported version of Python, but, while Python 2 is no longer supported, many existing datasets have significant quantities it.  Since the two languages have different syntax in some cases, we need two different analyses that rely on diffferent parsers, and hence we have two analysis jars.  ** All source code for the files that perform operations on the analysis graphs is now included - see directories that start with the string codebreaker. **

#### Build the code analysis libraries
Fetch these jars from [https://archive.org/download/graph4code_prereq_jars/graph4code_prereq_jars.tar](https://archive.org/download/graph4code_prereq_jars/graph4code_prereq_jars.tar).  In graph4code, untar.

```
 cd scripts
 bash setup.sh
```


#### Usage:
 
     java -DoutputDir=<output dir to store JSON representation of graph> -DquadFile=<file name to write quads to - this file gets appended to, so all analyzed scripts end up in a single file> -cp <absolute path of codebreaker*n*.jar> util.RunTurtleSingleAnalysis <python script to run on> <graph prefix> <graph qualifier> 
 
  where *n* is either 2 or 3 depending on the desired version of Python.  
 
#### Example
 
     java -DoutputDir=<output dir to store JSON representation of graph> -cp ../code_breaker_py3/target/CodeBreaker_py3-0.0.1-SNAPSHOT.jar util.RunTurtleSingleAnalysis <python script to run on> null null` to run on a Python 3 file, with an output of the graph on JSON. 
 
 So to run on an example script provided from the `main` directory, use 
 ```
     mkdir -p ./output/static_analysis/ 
     java -DoutputDir=./output/static_analysis/ -cp ../code_breaker_py3/target/CodeBreaker_py3-0.0.1-SNAPSHOT.jar  util.RunTurtleSingleAnalysis ./example_scripts/test1.py null null
  ```
 ./output/static_analysis should have a JSON file and an NQ file for the same information.  Please note that as the project has moved on to different applications, we have focused more on the JSON representation which is up to date.  The NQ is less what we use and test - so it may be out of date.

## Collecting documentation (docstrings) for your scripts
 
 
 3. Run `python generate_top_modules.py <DIR containing all analysis output>/*.json <OUTPUT_TOP_MODULES_PATH> <number for top K modules by count>. ` 
 
     **Example**: to run on the example script provided, run in the `src` dir: 
      
         python generate_top_modules.py '../output/static_analysis/*.json.bz2' ../output/top_modules.json 1
 
 4. From the `scripts` dir, run: 
 
     `sh inspect_modules_for_docstrings.sh <OUTPUT_TOP_MODULES_PATH> <OUTPUT_TO_WRITE_EXTRACTED_DOCSTRINGS> <ANACONDA_HOME>`
 
     **Example**: 
 ```
     mkdir ../output/modules_out/    
     sh inspect_modules_for_docstrings.sh ../output/top_modules.json ../output/modules_out/ ~/anaconda3/
 ```
 
You should see each package being inspected, and some output that looks like this: `Number of documents stored in index:docstrings_index
{'count': <xxx>, '_shards': {'total': 1, 'successful': 1, 'skipped': 0, 'failed': 0}}`
 
 5. Remember to delete the index if you are recreating it for the same packages.

 
## Creating docstrings graph
Using the output of the above step, run the following from inside the `src` directory 
 
     python create_docstrings_graph.py --docstring_dir <directory where docstrings from above directory are saved> --class_map_file ../resources/classes.map --out_dir <where nq files will be saved
     
     
  **Example**: 
  
         mkdir ../output/docstrings_graph/    
         python create_docstrings_graph.py --docstring_dir ../output/modules_out/ --class_map_file ../resources/classes.map --out_dir ../output/docstrings_graph/
 
 ## Creating Forums graph
# Additional requirements:
1. `pip install xmltodict`
2. `pip install rdflib`
3. `pip install validators`
4. Install pytorch using instructions for your OS. E.g.: `conda install pytorch torchvision torchaudio cpuonly -c pytorch`.

To create a forum graph, first download the corresponding data dump from StackOverflow or StackExchange from https://archive.org/details/stackexchange. You then need to extract the zipped file into a folder <stackoverflow_in_dir> and run the following: 

`python -u create_forum_graph.py --stackoverflow_in_dir <stackoverflow_in_dir> --docstring_dir <directory where docstrings from above directory are saved> --graph_output_dir <where graph nq files will be saved> --pickled_files_out <intermediate directory for saving stackoverflow dumps> --index_name <elastic search index name> --graph_main_prefix <prefix used for graph generation>`

As an example, to create a graph from https://ai.stackexchange.com/ and link it to docstrings and code analysis graphs, one can run the following: 

         mkdir ../output/ai_stackexchange_dump/
         mkdir ../output/ai_stackexchange_graph/
         cd output/ai_stackexchange_dump/
         wget https://archive.org/download/stackexchange/ai.stackexchange.com.7z
         7za x ai.stackexchange.com.7z
         cd ../../src 
         python -u create_forum_graph.py --stackoverflow_in_dir ../output/ai_stackexchange_dump/ --docstring_dir ../output/modules_out/ --graph_output_dir ../output/ai_stackexchange_graph/ --pickled_files_out ../output/ai_stackexchange_dump/ --index_name ai_stackexchange --graph_main_prefix  ai_stackexchange

Current accepted prefixes are ai_stackexchange, math_stackexchange, datascience_stackexchange, stats_stackexchange, and stackoverflow3. 

# Publications<a name="papers"></a>
* If you use Graph4CodeGen in your research, please cite our work:

```
@inproceedings{abdelaziz2023datarinse,
author = {Abdelaziz, Ibrahim and Dolby, Julian and Khurana, Udayan and Samulowitz, Horst and Srinivas, Kavitha},
title = {DataRinse: Semantic Transforms for Data Preparation Based on Code Mining},
year = {2023},
booktitle={Proceedings of the Very Large Data bases (VLDB 2022)}
}
@inproceedings{abdelaziz2023semforms,
      title={ SemFORMS: Automatic Generation of Semantic Transforms By Mining Data Science Code }, 
      author={Ibrahim Abdelaziz, Julian Dolby, Udayan Khurana, Horst Samulowitz, Kavitha Srinivas,
      booktitle={The 32nd International Joint Conference on Artificial Intelligence (IJCAI-23) (demo)},
      year={2023}
}
@inproceedings{helali2022,
      title={A Scalable AutoML Approach Based on Graph Neural Networks}, 
      author={Mossad Helali and Essam Mansour and Ibrahim Abdelaziz and Julian Dolby and Kavitha Srinivas},
      booktitle={Proceedings of the Very Large Data bases (VLDB 2022)},
      year={2022}
}
@inproceedings{abdelaziz2022blanca,
      title={Can Machines Read Coding Manuals Yet? -- A Benchmark for Building Better Language Models for Code Understanding}, 
      author={Ibrahim Abdelaziz and Julian Dolby and Jamie McCusker and Kavitha Srinivas},
      booktitle={Proceedings of the AAAI Conference on Artificial Intelligence (AAAI 2022)},
      year={2022}
}
@article{abdelaziz2021graph4code,
     title={A Toolkit for Generating Code Knowledge Graphs},
     author={Abdelaziz, Ibrahim and Dolby, Julian and  McCusker, James P and Srinivas, Kavitha},
     journal={The Eleventh International Conference on Knowledge Capture (K-CAP)},
     year={2021}
}
@article{abdelaziz2020codebreaker,
     title={A Demonstration of CodeBreaker: A Machine Interpretable Knowledge Graph for Code},
     author={Abdelaziz, Ibrahim and Srinivas, Kavitha and Dolby, Julian and  McCusker, James P},
     journal={International Semantic Web Conference (ISWC) (Demonstration Track)},
     year={2020}
}
```

  
# Questions
For any question, please contact us via email: ibrahim.abdelaziz1@ibm.com, kavitha.srinivas@ibm.com, dolby@us.ibm.com
  


