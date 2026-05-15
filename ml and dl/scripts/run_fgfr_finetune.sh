#!/bin/bash
set -euo pipefail

# ============================================================
# CONFIGURATION
# ============================================================
FGFR_CSV="gnn_data/fgfr_all.csv"
PRETRAIN_MODEL_DIR="model_output/classification"
OUTPUT_BASE_DIR="model_output/fgfr_finetune_seq_safe"
mkdir -p "$OUTPUT_BASE_DIR"
mkdir -p logs

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
LOG_DIR="logs/run_fgfr_seq_safe_$TIMESTAMP"
mkdir -p "$LOG_DIR"

ulimit -n 4096  # macOS file limit

# Activate Chemprop environment
eval "$(conda shell.bash hook)"
conda activate chemprop

# ============================================================
# FGFR TARGETS
# ============================================================
FGFR_TARGETS=("FGFR1" "FGFR2" "FGFR3" "FGFR4")

# Fast testing configuration
EPOCHS=3       # Must be > warmup_epochs
BATCH_SIZE=64
NUM_WORKERS=4

# ============================================================
# MAIN LOOP
# ============================================================
for TARGET in "${FGFR_TARGETS[@]}"; do
    echo
    echo "=============================="
    echo "🧬 Fine-Tuning: $TARGET"
    echo "=============================="

    OUTPUT_CSV="gnn_data/chemprop_ready_${TARGET}.csv"
    python Python/preprocess_chemprop.py "$FGFR_CSV" "$OUTPUT_CSV" "$TARGET"

    if [ ! -f "$OUTPUT_CSV" ]; then
        echo "❌ Preprocessing failed for $TARGET"
        continue
    fi

    OUTPUT_DIR="$OUTPUT_BASE_DIR/$TARGET"
    mkdir -p "$OUTPUT_DIR"

    echo "🚀 Starting fine-tuning for $TARGET..."
    chemprop train \
        -i "$OUTPUT_CSV" \
        -o "$OUTPUT_DIR" \
        --task-type classification \
        --checkpoint "$PRETRAIN_MODEL_DIR/model_0/best.pt" \
        --freeze-encoder \
        --num-workers $NUM_WORKERS \
        --batch-size $BATCH_SIZE \
        --epochs $EPOCHS \
        --class-balance \
        --metrics accuracy f1 roc prc \
        --show-individual-scores \
        --tracking-metric roc \
        --dropout 0.1 \
        --init-lr 5e-4 \
        --max-lr 1e-3 \
        --final-lr 5e-4 \
        --save-smiles-splits || { echo "❌ Fine-tuning failed for $TARGET"; continue; }

    echo "🔮 Predicting for $TARGET..."
    chemprop predict \
        -i "$OUTPUT_CSV" \
        -o "$LOG_DIR/predictions_${TARGET}.csv" \
        --model-paths "$OUTPUT_DIR/model_0/best.pt" || { echo "❌ Prediction failed for $TARGET"; continue; }

    echo "✅ Completed fine-tuning for $TARGET"
done

echo
echo "🎉 Sequential FGFR1 → FGFR4 fine-tuning complete!"
echo "📁 Logs and predictions saved to: $LOG_DIR"