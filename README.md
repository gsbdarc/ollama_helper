# Running Open-Source LLMs on Stanford GPU Clusters using Ollama

A hands-on guide and accompanying scripts for running Ollama (local LLM inference) on Stanford’s Yen, Sherlock, and Marlowe clusters.

Based on the blog post “[Running Ollama on Stanford Computing Clusters](https://rcpedia.stanford.edu/blog/2025/05/12/running-ollama-on-stanford-computing-clusters)” by the GSB DARC Team. 

## Overview

This repository contains:

- **`ollama.sh`**: helper function to launch and manage the Ollama server.  
- **`test.py`**: example Python script to verify your Ollama server.  

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
