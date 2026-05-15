#!/bin/bash
set -euo pipefail

# ============================================================
# CONFIGURATION
# ============================================================
INPUT_CSV="gnn_data/kinase_clean.csv"
MODEL_DIR="model_output"
mkdir -p "$MODEL_DIR"
mkdir -p logs

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
LOG_DIR="logs/run_classification_$TIMESTAMP"
mkdir -p "$LOG_DIR"

# Optional: increase open file limit (Mac default is low)
ulimit -n 4096

# Activate Chemprop environment
eval "$(conda shell.bash hook)"
conda activate chemprop

# ============================================================
# CLASSIFICATION TASK (Active vs Inactive)
# ============================================================
echo "🧹 Preprocessing CSV for classification..."
python Python/preprocess_chemprop.py "$INPUT_CSV" "gnn_data/chemprop_ready_classification.csv" "classification"

if [ ! -f "gnn_data/chemprop_ready_classification.csv" ]; then
  echo "❌ Classification preprocessing failed: CSV not created."
  exit 1
fi

echo "🚀 Training classification model..."
chemprop train \
  -i "gnn_data/chemprop_ready_classification.csv" \
  -o "$MODEL_DIR/classification" \
  --task-type classification \
  --num-workers 0 \
  --batch-size 50 \
  --epochs 30 \
  --class-balance \
  --metrics accuracy f1 roc prc \
  --show-individual-scores \
  --tracking-metric roc || { echo "❌ Classification training failed"; exit 1; }

# Copy training metrics to log folder
cp "$MODEL_DIR/classification"/*.csv "$LOG_DIR"/ 2>/dev/null || true

echo "🔮 Predicting classification..."
chemprop predict \
  -i "gnn_data/chemprop_ready_classification.csv" \
  -o "$LOG_DIR/predictions_classification.csv" \
  --model-paths "$MODEL_DIR/classification/model_0/best.pt" || { echo "❌ Classification prediction failed"; exit 1; }

echo "✅ Classification complete."
echo ""
echo "📦 All outputs and logs saved to: $LOG_DIR"
echo "🎯 Classification predictions: $LOG_DIR/predictions_classification.csv"
echo "🎉 Classification-only Chemprop pipeline finished successfully!"