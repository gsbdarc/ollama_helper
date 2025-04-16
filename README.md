# Running Ollama on Stanford computing clusters
This guide walks you through setting up and running the Ollama server on Stanford's Yen, Sherlock and Marlowe GPU computing clusters, allowing you to efficiently run large language models (LLMs).

## Quickstart 

### Ollama on the Yens

#### Step 1. Request a GPU node

Use `srun` to request an interactive GPU session:

```
srun -p gpu -G 1  -C "GPU_MODEL:A40" --ntasks=1 --time=12:00:00 --pty /bin/bash
```
This command requests one NVIDIA A40 GPU for up to 12 hours.

#### Step 2: Clone This Ollama Repository

Once you're logged into your GPU node, navigate to your project space and clone this Ollama repo:

```
cd /zfs/<your-project-space>/
git clone https://github.com/gsbdarc/ollama.git
cd ollama
```
Replace `<your-project-space>` with your actual project directory on the Yens.


#### Step 3: Load Apptainer and Configure Environment
Load the `apptainer` module and configure a cache and model storage location. 
```
ml apptainer
export SCRATCH_BASE=/scratch/shared/$USER
export APPTAINER_CACHEDIR=$SCRATCH_BASE/.apptainer_cache
mkdir -p $SCRATCH_BASE/ollama/models
export APPTAINER_BIND="$SCRATCH_BASE/ollama:/root/ollama"
```
⚠️ This uses `/scratch` and avoids storing models in your `$HOME`. 

#### Step 4: Pull Ollama Container Image
Download the official Ollama image from DockerHub:

```
apptainer pull ollama.sif docker://ollama/ollama
```

#### Step 5: Define the Ollama Helper Function

To conveniently launch Ollama servers with random available ports, define this helper function:

```
ollama() {
  LOWERPORT=32768
  UPPERPORT=60999

  find_available_port() {
    while true; do
      local port=$(shuf -i ${LOWERPORT}-${UPPERPORT} -n 1)
      if ! ss -tuln | grep -q ":${port} "; then
        echo "$port"
        return
      fi
    done
  }

  OLLAMA_PORT=$(find_available_port)
  echo "Starting Ollama server on port: ${OLLAMA_PORT}"

  apptainer run \
    --nv \
    --writable-tmpfs \
    --no-home \
    --env OLLAMA_MODELS=/root/ollama/models \
    --env OLLAMA_HOST="http://0.0.0.0:${OLLAMA_PORT}" \
    --env OLLAMA_PORT="${OLLAMA_PORT}" \
    ollama.sif \
    "$@"
}

```

#### Step 6: Start the Ollama Server

Launch Ollama server:

```
ollama serve &
```

You'll see output similar to:

```
Starting Ollama server on port: <port>
```
Make a note of this port number.

#### Step 7. Pull a model

Download a specific LLM model for inference. Example:
```
ollama pull deepseek-r1:70b
```

#### Step 8: Run Inference
Test inference directly:
```
ollama run deepseek-r1:70b "Hello, Ollama!"
```

#### Step 9: Check Server Status from Interactive Node

From an interactive Yen node, verify the server is running::

```
curl http://<hostname>:<port>
```
Replace `<hostname>` with your GPU node's hostname (e.g., `yen-gpu3`) and `<port>` with your Ollama server's port number.

Expected output:

```
Ollama is running
``` 

#### Step 10: Run a Python Script to Test Server

Use a provided test script (`test.py`) from an interactive node:
```
python3 test.py <hostname> --port <port>
```
Example:
```
python3 test.py yen-gpu3 --port 11434
```

You’re now set up and ready to explore powerful language models on Stanford's Yen GPU cluster!

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
python3 test.py n09 --port 11434
```

