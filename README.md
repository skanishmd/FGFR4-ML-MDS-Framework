# A Novel Integrated ML-MDS Framework for the Discovery of FGFR4 Inhibitors for Hepatocellular Carcinoma

## Integrated Machine Learning, Deep Learning, Molecular Docking, ADMET, Molecular Dynamics, and MM-GBSA

---

## Overview

Our study:

> **“A Novel Integrated ML-MDS Framework for the Discovery of FGFR4 Inhibitors for Hepatocellular Carcinoma”** 

It combines:

* Classical machine learning (RF, XGBoost)
* Transfer learning-based graph neural networks (Chemprop D-MPNN)
* Structure-based virtual screening
* Molecular docking
* 100 ns all-atom molecular dynamics simulations
* MM-GBSA free energy decomposition
* ADMET profiling

to identify and prioritize selective FGFR4 inhibitor candidates for hepatocellular carcinoma (HCC).

---

# Biological Background

Fibroblast Growth Factor Receptor 4 (FGFR4) is a validated therapeutic target in hepatocellular carcinoma due to its critical role in the FGF19–FGFR4 signaling axis regulating tumor proliferation, survival, angiogenesis, and metabolic adaptation.

Although clinical FGFR4 inhibitors such as fisogatinib (BLU-554) and roblitinib (FGF401) have demonstrated therapeutic potential, major limitations remain:

* Poor isoform selectivity
* Off-target FGFR1–3 inhibition
* Drug resistance mechanisms
* Dose-limiting toxicities

This work presents a multi-stage AI-assisted computational framework for the discovery of potent and selective FGFR4 inhibitors with improved predicted pharmacological properties.

---

# Key Highlights

* First transfer learning-based multitask GNN framework for simultaneous FGFR1–4 prediction
* Chemprop D-MPNN pretrained on **348,209 pan-kinase compounds**
* Integration of RF, XGB, and multitask GNN screening
* Two-tier progressive activity threshold strategy
* Scaffold-aware validation to minimize information leakage
* Integration of ligand-based and structure-based drug discovery
* 100 ns all-atom molecular dynamics simulations with 8 descriptor analyses
* MM-GBSA hotspot decomposition identifying VAL51 and LEU189 as dominant stabilizing residues
* Ligand_66 identified as the top computational lead compound

---

# Repository Structure

```text
FGFR4-ML-MDS-Framework/
│
│
├── admet/
│   ├── processed_tables/
│   └── raw_results/
│
│
├── data/
│   ├── processed/
│   ├── raw/
│   └── structures/
│
│
├── docking/
│   ├── docking_results/
│   ├── ligands/
│   ├── original_ligand/
│   ├── pre_docking/
│   ├── receptor/
│   ├── reference_ligands/
│   └── vina_configs/
│
│
├── figures/
│   ├── chemical_space/
│   ├── docking/
│   │   ├── interaction_maps/
│   │   └── validation/
│   │ 
│   ├── graphical_abstract/
│   ├── ml and dl/
│   ├── mm_gbsa/
│   └── molecular_dynamics/
│
│ 
├── highlights/
│
│
├── manuscript/
│
│
├── ml and dl/
│   ├── configs/
│   ├── datasets/
│   ├── evaluation/
│   ├── pre_processing/
│   ├── predictions/
│   ├── results/
│   └── scripts/
│
│
├── mm-gbsa/
│   ├── configuration/
│   └── decomposition/
│
│
├── molecular_dynamics/
│   ├── analysis/
│   ├── mdp_files/
│   ├── topology/
│   └── trajectories/
│
│
├── supplementary_information/
│   └── raw/
│
│
├── tables/
│
│
├── .gitattributes
│
│
├── LICENSE
│
│
└── README.md
```

---

# Workflow Overview

## 1. Dataset Collection and Curation

* FGFR1–4 bioactivity datasets retrieved from ChEMBL v34
* Quantitative IC₅₀ binding assays retained
* Conversion of IC₅₀ to pIC₅₀
* RDKit standardization
* PAINS filtering and deduplication
* Scaffold-aware dataset splitting

### Dataset Statistics

| Stage                          | Compounds |
| ------------------------------ | --------- |
| Raw ChEMBL data                | 3,743     |
| After curation                 | 2,396     |
| Active compounds (pIC₅₀ ≥ 6.0) | 1,335     |
| GNN shortlisted compounds      | 162       |
| Docking candidates             | Top 100   |

Based on Table 1. 

---

# Molecular Representation

* ECFP4 fingerprints (1024-bit)
* Physicochemical descriptors
* ETKDG-generated 3D conformers
* UMAP chemical space visualization
* Pairwise Tanimoto similarity analysis

---

# Machine Learning and Deep Learning

## Classical Machine Learning Models

* Random Forest (RF)
* Extreme Gradient Boosting (XGB)

## Deep Learning

* Chemprop Directed Message Passing Neural Network (D-MPNN)
* Transfer learning from kinase-focused datasets
* Multitask FGFR1–4 prediction

## Validation Strategy

* Scaffold-based splitting
* Nested cross-validation
* Fixed random seeds
* Assay-aware validation

## Model Performance

| Model | R²    | RMSE | AUROC |
| ----- | ----- | ---- | ----- |
| RF    | 0.84  | 0.44 | 0.92  |
| XGB   | 0.90  | 0.55 | 0.98  |
| GNN   | 0.397 | 0.66 | 0.966 |

Based on Table 2. 

---

# Progressive Screening Strategy

A two-tier screening strategy was implemented:

## Tier 1 — Classical ML Screening

* RF and XGB models
* Activity threshold:

  * **pIC₅₀ ≥ 6.0**

## Tier 2 — GNN Refinement

* Multitask transfer learning GNN
* Higher confidence threshold:

  * **pIC₅₀ ≥ 6.5**

This approach reduced false-positive advancement while preserving chemical diversity.

---

# Molecular Docking

Docking studies were performed against the FGFR4 ATP-binding site using the crystal structure:

* **PDB ID:** 4QRC
* Resolution: 1.90 Å

## Docking Validation

The co-crystallized ligand reproduced the experimental binding pose with RMSD ≤ 2 Å, validating the docking protocol. 

## Docking Parameters

| Parameter      | Value           |
| -------------- | --------------- |
| Grid Size      | 24 × 22 × 24 Å³ |
| Center X       | 42.69           |
| Center Y       | 36.94           |
| Center Z       | 50.65           |
| Exhaustiveness | 8               |

## Top Candidate

### Ligand_66

* Predicted pIC₅₀: 6.94
* Docking score: −9.6 kcal/mol
* Stable binding interactions observed

Key interacting residues:

* VAL51
* LEU189
* ASN127
* LEU43

Based on Figure 4 and Table 3. 

---

# Molecular Dynamics Simulations

100 ns all-atom molecular dynamics simulations were performed using:

* **GROMACS 2023.3**
* CHARMM36 force field
* CGenFF ligand parameters
* TIP3P water model

## Analyses Performed

* RMSD
* RMSF
* Radius of gyration (Rg)
* SASA
* Hydrogen bond occupancy
* Principal component analysis (PCA)
* Free energy landscape (FEL)
* Dynamic cross-correlation matrix (DCCM)

## Key Findings

* Stable equilibration achieved within ~20 ns
* Compact receptor folding maintained throughout simulation
* Persistent protein-ligand interactions observed
* Single dominant thermodynamic energy basin identified

Based on Figures 5 and 6. 

---

# MM-GBSA Binding Free Energy Analysis

Per-residue MM-GBSA decomposition was performed using:

* **gmx_MMPBSA v1.6.4**
* OBC II GB model (igb = 5)
* 200 trajectory snapshots

## Total Binding Free Energy

| Complex         | ΔGbind (kcal/mol) |
| --------------- | ----------------- |
| FGFR4–Ligand_66 | −27.42 ± 0.86     |

## Dominant Binding Hotspots

| Residue | Contribution (kcal/mol) |
| ------- | ----------------------- |
| VAL51   | −2.349                  |
| LEU189  | −1.651                  |
| ASN127  | −1.601                  |
| LEU43   | −1.594                  |

Based on Figure 7 and Table S1.  

---

# ADMET Profiling

ADMET properties were evaluated using:

* SwissADME
* ADMETlab 3.0

The shortlisted compounds demonstrated:

* Favorable oral bioavailability
* Reduced lipophilicity
* Acceptable CYP450 interaction profiles
* Improved predicted pharmacokinetics relative to reference inhibitors

---

# Software and Tools

## Programming & Scripting

* Python
* R
* Shell Scripting

## Machine Learning & Deep Learning

* Scikit-learn
* XGBoost
* Chemprop
* PyTorch

## Cheminformatics & Molecular Data Processing

* RDKit
* Pandas
* NumPy

## Molecular Modeling & Simulation

* AutoDock Vina
* PyRx
* GROMACS 2023.3
* gmx_MMPBSA

## Visualization & Structural Analysis

* PyMOL
* BIOVIA Discovery Studio Visualizer
* Matplotlib

## Development Environment & Reproducibility

* Google Colab
* Git
* Git LFS
* Windows 11

## Hardware Acceleration

* NVIDIA CUDA
  
---

# Citation

If you use this repository, please cite:

```bibtex
@article{FGFR4_Discovery_2025,
  title={A Novel Integrated ML-MDS Framework for the Discovery of FGFR4 Inhibitors for Hepatocellular Carcinoma},
  author={Md, Sk Anish and Ghosh, Megha and Deb, Sayan and Pati, Soumen Kumar and Mandal, Manab},
  journal={Under Review},
  year={2026}
}
```

---

# Disclaimer

This repository is intended exclusively for computational hypothesis generation and methodological reproducibility.

All computational predictions require experimental validation prior to biological, pharmacological, or clinical interpretation.

---

# License

This project is distributed under the MIT License.
