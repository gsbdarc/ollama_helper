# Running Ollama on Stanford computing clusters
We will use a container similar to this [guide](https://github.com/uw-psych/ollama-container/tree/main).

We will build Ollama container once using Sherlock GPU node but this can also be done locally with Docker.

## Build Ollama on Sherlock

Request a big GPU:
```
srun -p gpu --gres=gpu:1 --ntasks=1 --time=8:00:00 --constraint="GPU_MEM:80GB"  --mem=50G -c 16 --pty /bin/bash
```

Once allocated, clone this repo and build Ollama container:

```
cd <project-space>
git clone https://github.com/gsbdarc/ollama.git
cd ollama
export OLLAMA_MODELS=/scratch/<your-scratch-space>/ollama_data/models
mkdir -p "${OLLAMA_MODELS}"
export SCRATCH_BASE=/scratch/<your-scratch-space>
export APPTAINER_CACHEDIR==/scratch/<your-scratch-space>/.apptainer_cache
apptainer build --build-arg SCRATCH_BASE=$SCRATCH_BASE ollama.sif ollama.def
```

where `<your-scratch-space>` is your GROUP scratch directory / SUNet. 

To launch the server, run:
```
SCRATCH_BASE=$SCRATCH_BASE apptainer instance start --nv --writable-tmpfs --bind $SCRATCH_BASE ollama.sif ollama-$USER
```
where `$USER` is your SUNet.

If the `ollama` server has started correctly, you should see something like:

```
level=INFO source=routes.go:1298 msg="Listening on 10.20.1.7:36125 (version 0.6.5)"
```

Note that the node and port will be different for your run.

See what port was assigned to the server:
```
cat $SCRATCH_BASE/instance_start.log
```

From a login node, try:

```
curl http://<hostname>:<port>
```
where `<hostname>` and `port` are the node name and the random port Ollama server is listening on.

You should see:

```
Ollama is running
```

To pull a model in this case, DeepSeek-r1 70b, run:
```
SCRATCH_BASE=$SCRATCH_BASE apptainer run instance://ollama-$USER ollama pull deepseek-r1:70b
```

Now we can connect to the `ollama` server from other nodes. 

From a login node, try:

```
curl http://<hostname>:<port>
```
where `hostname` is the GPU node hostname such as `sh04-01n05` and `port` is the port number of Ollama server.


Run a test Python script that looks like so:
```py title="test.py"
import argparse
import requests

def main():
    # Set up argument parsing.
    parser = argparse.ArgumentParser(
        description="Send a request to an Ollama API endpoint on a given node hostname and port."
    )
    parser.add_argument("hostname", type=str, help="The hostname of the node (e.g., sh04-01n07)")
    parser.add_argument("--port", type=str, default="11434", help="The port number for the API (default: 11434)")

    args = parser.parse_args()

    # Construct the URL using the provided hostname and port.
    url = f"http://{args.hostname}:{args.port}/api/generate"
    print(f"Sending request to URL: {url}")

    payload = {
        "model": "deepseek-r1:70b",
        "prompt": (
            "With the upcoming 100-year celebration this fall, how do you envision Stanford GSB using "
            "this milestone to inspire the next generation of business leaders? Identify two specific "
            "initiatives or themes that should be highlighted during the celebration, and discuss how "
            "these can both honor the school’s century-long legacy and shape innovative approaches to business "
            "education going forward. Provide examples to support your recommendations."
        ),
        "stream": False  # Disable streaming to get one complete response
    }
    headers = {"Content-Type": "application/json"}

    try:
        # Make the POST request.
        response = requests.post(url, json=payload, headers=headers)
        response.raise_for_status()
        # Assuming the API returns a JSON response, print the result.
        data = response.json()
        print(data)
    except requests.exceptions.RequestException as e:
        print(f"An error occurred: {e}")

if __name__ == '__main__':
    main()
```
The script accepts a hostname as an argument where the Ollama server is running.


Run the script from the login node:
```
python3 test.py <hostname> --port <port>
```
where `hostname` and `port` are the GPU node and the port that the `ollama` server is running on.

To stop Ollama server:
```
apptainer instance stop ollama-$USER
```


### Transfer Built Container to Marlowe and Yens
```
scp ollama.sif $USER@login.marlowe.stanford.edu:<your-project-space-on-Marlowe>
scp ollama.sif $USER@yen.stanford.edu:<your-project-space-on-yens>
```

## Run Ollama on Marlowe

Check out a GPU node:

```
srun -p preempt -A marlowe-<your-project> --gres=gpu:1 --ntasks=1 --time=4:00:00 --pty /bin/bash
```

After allocation:

```
cd <your-project-space>
export APPTAINER_CACHEDIR=/scratch/<your-project>/<$USER>/.apptainer_cache
export OLLAMA_MODELS=/scratch/<your-project>/<$USER>/ollama_data/models
mkdir -p "${OLLAMA_MODELS}"
export SCRATCH_BASE=/scratch/<your-project>/<$USER>
SCRATCH_BASE=$SCRATCH_BASE apptainer instance start --nv --writable-tmpfs --bind $SCRATCH_BASE ollama.sif ollama-$USER
SCRATCH_BASE=$SCRATCH_BASE apptainer run instance://ollama-$USER ollama pull deepseek-r1:70b
```

To see what port the server is running on :
```
cat $SCRATCH_BASE/instance_start.log
```

Test from a login node:

```
curl http://<hostname>:<port>
```
where `hostname` is the GPU node that is running the server and `port` is the port number where server is listening.

Run the script from the login node:
```
python3 test.py <hostname> --port <port>
```
where `hostname` is the GPU node that is running the server.


To stop:
```
apptainer instance stop ollama-$USER
```


## Ollama on the Yens

Request an allocation on a bigger GPU node:
```
srun -p gpu -G 1  -C "GPU_MODEL:A40" --ntasks=1 --time=12:00:00 --pty /bin/bash
```

On the GPU node:

```
cd /zfs/projects/<your-project>

ml apptainer
export APPTAINER_CACHEDIR=/scratch/shared/<$USER>/.apptainer_cache
export OLLAMA_MODELS=/scratch/shared/<$USER>/ollama_data/models
mkdir -p "${OLLAMA_MODELS}"
export SCRATCH_BASE=/scratch/shared/<$USER>
SCRATCH_BASE=$SCRATCH_BASE apptainer instance start --nv --writable-tmpfs --bind $SCRATCH_BASE ollama.sif ollama-$USER
SCRATCH_BASE=$SCRATCH_BASE apptainer run instance://ollama-$USER ollama pull deepseek-r1:70b
```

Test from an interactive Yen:
```
curl http://<hostname>:<port>
```

where `hostname` is the GPU node that is running the server and `<port>` is the port where server is listening.

You should see:

```
Ollama is running
```

Run a test Python script: 

```
python3 test.py <hostname> --port <port>
```
The script accepts a hostname and a port as an argument where the Ollama server is running.


To stop the server:
```
apptainer instance stop ollama-$USER
```
