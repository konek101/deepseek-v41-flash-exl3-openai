# DeepSeek V4.1 Flash EXL3 OpenAI-compatible server

This image wraps the model-specific EXL3 runtime for
[`dealignai/DeepSeek-V4.1-Flash-UNCENSORED-EXL3-2.9bpw`](https://huggingface.co/dealignai/DeepSeek-V4.1-Flash-UNCENSORED-EXL3-2.9bpw).
It exposes the vLLM OpenAI-compatible API on port **3500**.

The checkpoint is approximately 197 GiB and the model card requires two NVIDIA GB10/DGX Spark nodes. The image does not contain the weights. Mount the EXL3 checkpoint at `/model` and the base-model Engram shards/index at `/engram-src`.

## Run

On the head node:

```bash
docker run --rm --gpus all --network host --ipc=host --shm-size 32g \
  -e MASTER_ADDR=10.0.0.1 -e NODE_RANK=0 \
  -v /path/to/DeepSeek-V4.1-Flash-UNCENSORED-EXL3-2.9bpw:/model:ro \
  -v /path/to/engram-src:/engram-src:ro \
  ghcr.io/konek101/deepseek-v41-flash-exl3-openai:latest
```

Start a second identical container on the worker node with `MASTER_ADDR` set to the head IP and `NODE_RANK=1`. The API is then available at `http://HEAD_IP:3500/v1`.

Example request:

```bash
curl http://127.0.0.1:3500/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d '{"model":"DeepSeek-v4.1-Flash-EXL3","messages":[{"role":"user","content":"Hello"}],"max_tokens":64}'
```

The model is uncensored. You are responsible for complying with applicable law and for securing this API before exposing it to a network.
