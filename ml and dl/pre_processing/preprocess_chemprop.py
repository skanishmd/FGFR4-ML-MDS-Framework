import pandas as pd
import sys, os

input_csv = sys.argv[1]
output_csv = sys.argv[2]
target_column = sys.argv[3]  # e.g., "FGFR1"

df = pd.read_csv(input_csv)
smiles_col = "Smiles"

if smiles_col not in df.columns or target_column not in df.columns:
    raise ValueError(f"❌ Could not find required columns: {smiles_col}, {target_column}")

df = df[[smiles_col, target_column]].copy()

# If numeric pIC50 → convert to Active/Inactive
THRESHOLD = 6.0
if df[target_column].dtype != 'object':
    df['label'] = (df[target_column] >= THRESHOLD).astype(int)
else:
    df['label'] = df[target_column]  # already categorical

df = df[[smiles_col, 'label']]

os.makedirs(os.path.dirname(output_csv), exist_ok=True)
df.to_csv(output_csv, index=False)
print(f"✅ Saved preprocessed CSV for {target_column}: {output_csv}")