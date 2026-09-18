# Thin, reproducible wrapper around the model-specific EXL3 runtime.
# The upstream image contains the SM121 kernels and vLLM/ExLlamaV3 overlay.
FROM ghcr.io/miaai-lab/deepseek-v4.1-flash-exl3-2x-dgx-sparks:2.9bpw

COPY serve.sh /usr/local/bin/serve.sh
RUN chmod 0755 /usr/local/bin/serve.sh

ENV PORT=3500 \
    MODEL_DIR=/model \
    ENGRAM_DIR=/engram-src \
    SERVED_MODEL_NAME=DeepSeek-v4.1-Flash-EXL3 \
    TP=2 \
    NNODES=2 \
    NODE_RANK=0 \
    MASTER_PORT=29521 \
    SPEC_METHOD=dspark \
    DSPARK_TOKENS=3 \
    MAX_MODEL_LEN=262144 \
    MAX_NUM_BATCHED_TOKENS=2048 \
    GPU_MEM_UTIL=0.85 \
    LANGUAGE_MODEL_ONLY=0

EXPOSE 3500
ENTRYPOINT ["/usr/local/bin/serve.sh"]
