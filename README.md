# Running Open-Source LLMs on Stanford GPU Clusters using Ollama

A hands-on guide and accompanying scripts for running Ollama (local LLM inference) on Stanford’s Yen, Sherlock, and Marlowe clusters.

 

Based on the blog post “[Running Ollama on Stanford Computing Clusters](https://rcpedia.stanford.edu/blog/2025/05/12/running-ollama-on-stanford-computing-clusters)” by the GSB DARC Team. 


## Overview

This repository contains:

- **`ollama.sh`**: helper function to launch and manage the Ollama server.  
- **`test.py`**: example Python script to verify your Ollama server.
- **`tutorial.ipynb`**: example notebook of various commands on the Ollama Server
- **`requirements.txt`**: libraries needed to run the full tutorial. To set up a virtual environment in Jupyter Notebooks, please see the [Python environments guide](https://rcpedia.stanford.edu/_user_guide/python_envs/?h=virtu#running-python-scripts-using-virtual-environment)
- **`joke_example.png`**: AI generated joke image to go with tutorial

Follow the steps below to get up and running.

## Prerequisites

- Access to Stanford HPC clusters (Yen, Sherlock, or Marlowe)  

## Installation
Clone this code repo:

```bash
cd </your/project/path>
git clone https://github.com/gsbdarc/ollama_helper.git
cd ollama_helper
```

## Getting the Notebook running on the yens

```bash
/usr/bin/python3  -m venv my_env

source my_env/bin/activate

pip install -r requirements.txt

python -m ipykernel install --user --name=<kernel-name>

```

