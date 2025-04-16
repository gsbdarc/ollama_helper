# Running Ollama on Stanford computing clusters

## Quickstart 

### Ollama on the Yens

Request a GPU node:

```
srun -p gpu -G 1  -C "GPU_MODEL:A40" --ntasks=1 --time=12:00:00 --pty /bin/bash
```

On the GPU node:

```
cd /zfs/<your-project-space>/
git clone https://github.com/gsbdarc/ollama.git
cd ollama
```

Load `apptainer` module and set environment variables:

```
ml apptainer
export SCRATCH_BASE=/scratch/shared/$USER
export APPTAINER_CACHEDIR=$SCRATCH_BASE/.apptainer_cache
mkdir -p $SCRATCH_BASE/ollama/models
export APPTAINER_BIND="$SCRATCH_BASE/ollama:/root/ollama"
```

Pull Ollama image from DockerHub:
```
apptainer pull ollama.sif docker://ollama/ollama
```

Define a helper function:

```
ollama() {
  apptainer run \
    --nv \
    --writable-tmpfs \
    --no-home \
    --bind "$APPTAINER_BIND" \
    --env  OLLAMA_MODELS=/root/ollama/models \
    --env  OLLAMA_HOST=http://0.0.0.0:11434 \
    --env  OLLAMA_PORT=11434 \
    ollama.sif \
    "$@"
}
```

Start Ollama server:

```
ollama serve &
```

Pull a model:
```
ollama pull deepseek-r1:70b
```

Run inference:

```
ollama run deepseek-r1:70b "Hello, Ollama!"
```

From an interactive yen node, try:

```
curl http://<hostname>:<port>
```
where `<hostname>` and `port` are the node name and the port Ollama server is listening on. 
For example, `yen-gpu3` and `11434`.
 
You should see:

```
Ollama is running
```

Run a test python script from an interactive yen:
```
python3 test.py <hostname> --port <port>
```

For example, if the server is running on `yen-gpu3`:
```
python3 test.py yen-gpu3 --port 11434
```


### Ollama on Sherlock 

Request a GPU node:
```
srun -p gpu --gres=gpu:1 --ntasks=1 --time=8:00:00 --constraint="GPU_MEM:80GB"  --mem=50G -c 16 --pty /bin/bash
```

On the GPU node:

```
cd /zfs/<your-project-space>/
git clone https://github.com/gsbdarc/ollama.git
cd ollama
```

Set environment variables:

```
export SCRATCH_BASE=/<group-scratch>/$USER
export APPTAINER_CACHEDIR=$SCRATCH_BASE/.apptainer_cache
mkdir -p $SCRATCH_BASE/ollama/models
export APPTAINER_BIND="$SCRATCH_BASE/ollama:/root/ollama"
```

Pull Ollama image from DockerHub:
```
apptainer pull ollama.sif docker://ollama/ollama
```

Define a helper function:

```
ollama() {
  apptainer run \
    --nv \
    --writable-tmpfs \
    --no-home \
    --bind "$APPTAINER_BIND" \
    --env  OLLAMA_MODELS=/root/ollama/models \
    --env  OLLAMA_HOST=http://0.0.0.0:11434 \
    --env  OLLAMA_PORT=11434 \
    ollama.sif \
    "$@"
}
```
Start Ollama server:

```
ollama serve &
```

Pull a model:
```
ollama pull deepseek-r1:70b
```

Run inference:

```
ollama run deepseek-r1:70b "Hello, Ollama!"
```

From a login node, try:

```
curl http://<hostname>:<port>
```

where `<hostname>` and `port` are the node name and the port Ollama server is listening on.
For example, `sh04-01n05` and `11434`.

You should see:

```
Ollama is running
```

Run a test python script from an interactive yen:
```
python3 test.py <hostname> --port <port>
```

For example, if the server is running on `sh04-01n05`:
```
python3 test.py sh04-01n05 --port 11434
```

### Ollama on Marlowe

Request a GPU node:
```
srun -p preempt -A marlowe-<your-project> --gres=gpu:1 --ntasks=1 --time=4:00:00 --pty /bin/bash
```

On the GPU node:

```
cd /zfs/<your-project-space>/
git clone https://github.com/gsbdarc/ollama.git
cd ollama
```

Set environment variables:

```
export SCRATCH_BASE=/scratch/<your-project>/$USER
export APPTAINER_CACHEDIR=$SCRATCH_BASE/.apptainer_cache
mkdir -p $SCRATCH_BASE/ollama/models
export APPTAINER_BIND="$SCRATCH_BASE/ollama:/root/ollama"
```

Pull Ollama image from DockerHub:
```
apptainer pull ollama.sif docker://ollama/ollama
```

Define a helper function:

```
ollama() {
  apptainer run \
    --nv \
    --writable-tmpfs \
    --no-home \
    --bind "$APPTAINER_BIND" \
    --env  OLLAMA_MODELS=/root/ollama/models \
    --env  OLLAMA_HOST=http://0.0.0.0:11434 \
    --env  OLLAMA_PORT=11434 \
    ollama.sif \
    "$@"
}
```
Start Ollama server:

```
ollama serve &
```

Pull a model:
```
ollama pull deepseek-r1:70b
```

Run inference:

```
ollama run deepseek-r1:70b "Hello, Ollama!"
```

From a login node, try:

```
curl http://<hostname>:<port>
```

where `<hostname>` and `port` are the node name and the port Ollama server is listening on.
For example, `n09` and `11434`.

You should see:

```
Ollama is running
```

Run a test python script from an interactive yen:
```
python3 test.py <hostname> --port <port>
```

For example, if the server is running on `n09` and port 11434, run:
```
python3 test.py n05 --port 11434
```

