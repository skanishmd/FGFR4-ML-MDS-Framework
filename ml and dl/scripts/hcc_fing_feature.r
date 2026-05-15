library(tidyverse)
library(umap)
library(caret)
library(xgboost)
library(pROC)
library(PRROC)

# Load ChEMBL activity data
df_raw <- read_delim("~/Downloads/3743.csv.csv", delim = ";")

df_activity <- df_activity %>%
  rename(smiles = Smiles)

# Keep IC50s and convert to pIC50
df_activity <- df_raw %>%
  filter(`Standard Type` == "IC50", !is.na(`Standard Value`)) %>%
  mutate(pIC50 = 9 - log10(`Standard Value`),   # IC50 in nM
         Label = ifelse(pIC50 >= 7, "Active", "Inactive"))

# Load fingerprints
fp_df <- read_csv("fgfr4_ecfp4.csv")

# Merge on molecule ID (not SMILES!)
df_merged <- df_activity %>%
  inner_join(fp_df, by = "Smiles")

cat("Merged dataset:", nrow(df_merged), "molecules\n")

#Dimensionality reduction 
fp_matrix <- as.matrix(df_merged %>% select(starts_with("fp_")))

umap_coords <- umap(fp_matrix, n_neighbors = 15, min_dist = 0.1)
umap_df <- as.data.frame(umap_coords$layout) %>%
  setNames(c("UMAP1", "UMAP2")) %>%
  mutate(Label = df_merged$Label)

ggplot(umap_df, aes(UMAP1, UMAP2, color = Label)) +
  geom_point(alpha = 0.7) +
  theme_minimal()

library(caret)
library(ranger)       # faster RF backend
library(xgboost)
library(pROC)
library(PRROC)
library(doParallel)

# --------------------------
# Parallel setup
# --------------------------
cl <- makeCluster(parallel::detectCores() - 1)
registerDoParallel(cl)

# --------------------------
# Cross-validation control
# --------------------------
ctrl <- trainControl(
  method = "cv",
  number = 5,
  classProbs = TRUE,
  summaryFunction = twoClassSummary,
  sampling = "smotefilter"  # alternative since DMwR::SMOTE is retired
)
# Install smotefamily if missing
library(smotefamily)
library(dplyr)

# Combine fingerprints + label
df_smote_input <- df_merged %>%
  select(Label, starts_with("fp_"))

# Convert label to numeric (SMOTE needs 0/1)
df_smote_input$Label_num <- ifelse(df_smote_input$Label == "Active", 1, 0)

# Run SMOTE
smote_out <- SMOTE(df_smote_input %>% select(-Label), 
                   df_smote_input$Label_num, 
                   K = 5, dup_size = 0)

# Extract balanced dataset
df_smote <- as.data.frame(smote_out$data)
colnames(df_smote)[ncol(df_smote)] <- "Label_num"

# Convert back to factor
df_smote$Label <- factor(ifelse(df_smote$Label_num == 1, "Active", "Inactive"))

# Drop helper column
df_smote <- df_smote %>% select(-Label_num)

cat("Original:", table(df_merged$Label), "\n")
cat("After SMOTE:", table(df_smote$Label), "\n")

# Train RF on balanced data
ctrl <- trainControl(
  method = "cv",
  number = 5,
  classProbs = TRUE,
  summaryFunction = twoClassSummary
)

rf_fit <- train(
  Label ~ ., 
  data = df_smote,
  method = "ranger",
  metric = "ROC",
  trControl = ctrl,
  tuneLength = 2,
  importance = "impurity"
)

print(rf_fit)

saveRDS(rf_fit, "rf_fit_smote.rds")

varImpPlot <- varImp(rf_fit, scale = FALSE)
print(varImpPlot)

# --------------------------
# XGBoost
# --------------------------
dtrain <- xgb.DMatrix(
  data = as.matrix(df_merged %>% select(starts_with("fp_"))),
  label = as.numeric(df_merged$Label == "Active")
)

params <- list(
  objective = "binary:logistic",
  eval_metric = "auc",
  max_depth = 5,
  eta = 0.1,
  subsample = 0.8,
  colsample_bytree = 0.8
)

xgb_fit <- xgb.train(
  params = params,
  data = dtrain,
  nrounds = 200,
  verbose = 0
)

# --------------------------
# Predictions + Metrics
# --------------------------
pred <- predict(xgb_fit, dtrain)

roc_obj <- roc(df_merged$Label, pred)
pr_obj  <- pr.curve(
  scores.class0 = pred,
  weights.class0 = as.numeric(df_merged$Label == "Active")
)

metrics <- list(
  ROC_AUC  = auc(roc_obj),
  PR_AUC   = pr_obj$auc.integral
)

print(metrics)

# --------------------------
# Cleanup parallel
# --------------------------
stopCluster(cl)
registerDoSEQ()