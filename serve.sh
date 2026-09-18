#!/usr/bin/env bash
set -euo pipefail

: "${MODEL_DIR:=/model}"
: "${ENGRAM_DIR:=/engram-src}"
: "${PORT:=3500}"
: "${SERVED_MODEL_NAME:=DeepSeek-v4.1-Flash-EXL3}"
: "${TP:=2}"
: "${NNODES:=2}"
: "${NODE_RANK:=0}"
: "${MASTER_ADDR:=127.0.0.1}"
: "${MASTER_PORT:=29521}"
: "${SPEC_METHOD:=dspark}"
: "${DSPARK_TOKENS:=3}"
: "${MAX_MODEL_LEN:=262144}"
: "${MAX_NUM_BATCHED_TOKENS:=2048}"
: "${GPU_MEM_UTIL:=0.85}"
: "${LANGUAGE_MODEL_ONLY:=0}"

if [[ ! -f "${MODEL_DIR}/config.json" ]]; then
  echo "ERROR: ${MODEL_DIR}/config.json is missing; mount the EXL3 checkpoint at /model" >&2
  exit 1
fi
if [[ ! -d "${ENGRAM_DIR}" ]]; then
  echo "ERROR: ${ENGRAM_DIR} is missing; mount the base-model Engram shards at /engram-src" >&2
  exit 1
fi

args=(
  "${MODEL_DIR}"
  --served-model-name "${SERVED_MODEL_NAME}"
  --host 0.0.0.0
  --port "${PORT}"
  --tensor-parallel-size "${TP}"
  --nnodes "${NNODES}"
  --node-rank "${NODE_RANK}"
  --master-addr "${MASTER_ADDR}"
  --master-port "${MASTER_PORT}"
  --distributed-executor-backend mp
  --tokenizer-mode deepseek_v41
  --tool-call-parser deepseek_v41
  --reasoning-parser deepseek_v41
  --enable-auto-tool-choice
  --enable-prefix-caching
  --quantization exl3
  --max-model-len "${MAX_MODEL_LEN}"
  --max-num-batched-tokens "${MAX_NUM_BATCHED_TOKENS}"
  --gpu-memory-utilization "${GPU_MEM_UTIL}"
  --hf-overrides "{\"engram_table_dir\":\"${ENGRAM_DIR}\"}"
)

if [[ "${LANGUAGE_MODEL_ONLY}" == "1" ]]; then
  args+=(--limit-mm-per-prompt '{"image":0}')
else
  args+=(--limit-mm-per-prompt '{"image":100}')
fi

if [[ "${SPEC_METHOD}" != "none" ]]; then
  args+=(--speculative-config "{\"method\":\"${SPEC_METHOD}\",\"num_speculative_tokens\":${DSPARK_TOKENS}}")
fi

if [[ -n "${EXTRA_ARGS:-}" ]]; then
  # EXTRA_ARGS is intentionally opt-in for advanced deployment tuning.
  read -r -a extra <<< "${EXTRA_ARGS}"
  args+=("${extra[@]}")
fi

exec vllm serve "${args[@]}"
