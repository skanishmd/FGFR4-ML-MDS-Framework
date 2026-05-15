import os
import sys
import subprocess

# ---------- Config ----------
PRETRAIN_MODEL_DIR = "model_output/classification"
FGFR_DATA = "gnn_data/fgfr_all.csv"
OUTPUT_DIR = "model_output/fgfr_finetune"
EPOCHS = 20  # Fine-tuning for fewer epochs

os.makedirs(OUTPUT_DIR, exist_ok=True)

# ---------- Fine-tune Command ----------
cmd = [
    "chemprop", "train",
    "-i", FGFR_DATA,
    "-o", OUTPUT_DIR,
    "--task-type", "classification",   # change to "regression" if target numeric
    "--num-workers", "0",
    "--batch-size", "50",
    "--epochs", str(EPOCHS),
    "--metrics", "accuracy,f1,roc,prc",
    "--show-individual-scores",
    "--tracking-metric", "roc",
    "--class-balance",
    "--checkpoint", os.path.join(PRETRAIN_MODEL_DIR, "model_0/best.pt")
]

print("🚀 Running fine-tuning on FGFR dataset...")
subprocess.run(cmd, check=True)
print(f"✅ Fine-tuning complete. Outputs saved to {OUTPUT_DIR}")