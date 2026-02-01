#!/bin/bash

set -e

MODEL_DIR="$HOME/Library/Application Support/OpenFlow/Models"
mkdir -p "$MODEL_DIR"

BASE_URL="https://huggingface.co/ggerganov/whisper.cpp/resolve/main"

MODELS=(
    "ggml-tiny.en.bin"
    "ggml-tiny.bin"
    "ggml-base.en.bin"
    "ggml-base.bin"
    "ggml-small.en.bin"
    "ggml-small.bin"
)

if [ "$1" == "--list" ]; then
    echo "Available models:"
    for model in "${MODELS[@]}"; do
        echo "  - $model"
    done
    exit 0
fi

MODEL="${1:-ggml-base.en.bin}"

if [[ ! " ${MODELS[@]} " =~ " ${MODEL} " ]]; then
    echo "Error: Unknown model '$MODEL'"
    echo "Run with --list to see available models"
    exit 1
fi

OUTPUT_FILE="$MODEL_DIR/$MODEL"

if [ -f "$OUTPUT_FILE" ]; then
    echo "Model already exists: $OUTPUT_FILE"
    read -p "Re-download? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
fi

echo "Downloading $MODEL..."
curl -L --progress-bar "$BASE_URL/$MODEL" -o "$OUTPUT_FILE"

echo ""
echo "Download complete: $OUTPUT_FILE"
echo "File size: $(du -h \"$OUTPUT_FILE\" | cut -f1)"
