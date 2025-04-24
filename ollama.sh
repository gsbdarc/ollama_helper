#!/usr/bin/env bash
# Defines a single `ollama()` wrapper for running Ollama on HPC with scratch‑backed state.

ollama() {
  local LOWERPORT=32768 UPPERPORT=60999
  local S PORT_FILE HOST_FILE PORT HOST ENV_HOST BIND

  # 1) Require SCRATCH_BASE
  if [ -z "$SCRATCH_BASE" ]; then
    echo "ERROR: please export SCRATCH_BASE" >&2
    return 1
  fi

  # 2) Prepare your scratch tree for keys, models, host & port
  S="${SCRATCH_BASE}/ollama"
  mkdir -p "${S}"/{.ollama,models}
  PORT_FILE="${S}/port.txt"
  HOST_FILE="${S}/host.txt"

  # 3) Helper to pick an unused TCP port
  find_available_port() {
    local p
    while :; do
      p=$(shuf -i "${LOWERPORT}-${UPPERPORT}" -n1)
      if ! ss -tuln | grep -q ":${p} "; then
        echo "$p"
        return
      fi
    done
  }

  # 4) If first‐time or explicitly "serve", pick & record port+host, then start server
  if [ "$1" = "serve" ] || [ ! -f "$PORT_FILE" ] || [ ! -f "$HOST_FILE" ]; then
    PORT=$(find_available_port)
    echo "$PORT" > "$PORT_FILE"

    # record the short hostname 
    hostname -s > "$HOST_FILE"

    # bind on all interfaces
    BIND="0.0.0.0:${PORT}"
    ENV_HOST="http://$(<"$HOST_FILE"):${PORT}"

    echo "Starting Ollama server binding to ${BIND}"
    echo "Advertising server to clients at ${ENV_HOST}"

    # drop the "serve" arg so it isn't passed twice
    shift

    exec apptainer run \
      --nv \
      --contain \
      --home "${S}:/root" \
      --env OLLAMA_MODELS="/root/models" \
      --env OLLAMA_HOST="http://${BIND}" \
      --env OLLAMA_PORT="${PORT}" \
      ollama.sif serve "$@"
  fi

  # 5) Otherwise, act as a client: read recorded host+port and forward command
  PORT=$(<"$PORT_FILE")
  HOST=$(<"$HOST_FILE")
  ENV_HOST="http://${HOST}:${PORT}"

  echo "Forwarding 'ollama $*' to ${ENV_HOST}"

  apptainer run \
    --nv \
    --contain \
    --home "${S}:/root" \
    --env OLLAMA_MODELS="/root/models" \
    --env OLLAMA_HOST="${ENV_HOST}" \
    --env OLLAMA_PORT="${PORT}" \
    ollama.sif "$@"
}

# Export so that subshells (e.g. slurm scripts) will inherit it
export -f ollama

