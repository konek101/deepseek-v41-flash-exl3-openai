# DeepSeek V4.1 Flash EXL3 OpenAI-compatible server

This image targets Linux x86_64 systems with NVIDIA Blackwell GPUs and wraps the model-specific EXL3 runtime for
[`dealignai/DeepSeek-V4.1-Flash-UNCENSORED-EXL3-2.9bpw`](https://huggingface.co/dealignai/DeepSeek-V4.1-Flash-UNCENSORED-EXL3-2.9bpw).
It exposes the vLLM OpenAI-compatible API on port **3500**.

The checkpoint is approximately 197 GiB. The default deployment is one host with four 96-GB-class Blackwell GPUs (`TP=4`, `NNODES=1`). On first start, the container downloads the EXL3 checkpoint and the two required Engram shards into its internal `/opt/dsv41` volume. Set `HF_TOKEN` if your Hugging Face account requires authentication.

## Run

On the head node:

```bash
docker run --rm --gpus all --network host --ipc=host --shm-size 32g \
  -e MASTER_ADDR=127.0.0.1 -e NODE_RANK=0 \
  -e HF_TOKEN=your_huggingface_token \
  ghcr.io/konek101/deepseek-v41-flash-exl3-openai:latest
```

The API is available at `http://127.0.0.1:3500/v1`.

The startup check expects four visible NVIDIA GPUs. Set `SKIP_GPU_CHECK=1` only when intentionally using a different topology. The model’s EXL3 quantization is hardware/runtime-sensitive; the image uses current vLLM nightly support for the DeepSeek V4.1 architecture.

Example request:

```bash
curl http://127.0.0.1:3500/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d '{"model":"DeepSeek-v4.1-Flash-EXL3","messages":[{"role":"user","content":"Hello"}],"max_tokens":64}'
```

The model is uncensored. You are responsible for complying with applicable law and for securing this API before exposing it to a network.
