#!/bin/bash

set -e

echo "Setting up OpenFlow development environment..."

MODEL_DIR="$HOME/Library/Application Support/OpenFlow/Models"
mkdir -p "$MODEL_DIR"

echo "Model directory created at: $MODEL_DIR"

echo ""
echo "=========================================="
echo "Development environment setup complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Download Whisper models to: $MODEL_DIR"
echo "2. Build the project: swift build"
echo "3. Run the app: swift run"
echo ""
echo "Model download URLs:"
echo "- Base English: https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin"
echo "- Small English: https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-small.en.bin"
