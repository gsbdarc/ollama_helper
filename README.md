# Running Ollama on Stanford computing clusters
## Ollama on Sherlock

We will use a container similar to this [guide](https://github.com/uw-psych/ollama-container/tree/main).

Request a big GPU:
```
srun -p gpu --gres=gpu:1 --ntasks=1 --time=8:00:00 --constraint="GPU_MEM:80GB"  --mem=50G -c 16 --pty /bin/bash
```

Once allocated, clone this repo, build Ollama container and launch the Ollama server:

```
cd <project-space>
git clone https://github.com/gsbdarc/ollama.git
cd ollama
apptainer build ollama.sif ollama.def
```

To launch the server, run:
```
export OLLAMA_MODELS=/scratch/groups/fmcnich/nrapstin/ollama_data/models
mkdir -p "${OLLAMA_MODELS}"
apptainer instance start --nv --writable-tmpfs --bind /scratch ollama.sif ollama-$USER
```

If the `ollama` server has started correctly, you should see something like:

```
level=INFO source=routes.go:1298 msg="Listening on 0.0.0.0:11434 (version 0.6.5)"
```

To pull a model in this case, DeepSeek-r1 70b, run :
```
apptainer run instance://ollama-$USER ollama pull deepseek-r1:70b
```

Now we can connect to the `ollama` server from other nodes. 

From a login node, try:

```
curl http://<hostname>:11434
```
where `hostname` is the GPU node hostname such as `sh04-01n05`.

```
python3 test.py <hostname>
```
where `hostname` is the GPU node hostname such as `sh04-01n05`.

To stop the server:
```
apptainer instance stop ollama-$USER
```


