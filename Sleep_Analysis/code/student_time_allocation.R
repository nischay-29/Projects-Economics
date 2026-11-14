# ============================================================================
# Time Allocation, Sleep & Career Signalling Among Delhi College Students
# PART 1: Import & clean
# PART 2: Basic descriptives (Section 1-2 of your sheet)
# PART 3: Cross-tabs + Chi-square tests
# PART 4: Spearman correlations + Kruskal-Wallis / Mann-Whitney
#
# NOTE ON Q-NUMBERS: In your Question Mapping sheet, "Q2" = Gender, but in
# the actual Google Form export Gender ended up as the LAST column, not the
# 2nd. I matched every Qn to its ACTUAL column below by content, not by
# position in the mapping sheet. Comments throughout reference both the
# short variable name and the Qn label from your mapping sheet so you can
# cross-check against it.
# ============================================================================

# ---- 0. Packages ----------------------------------------------------------
required_pkgs <- c("readxl", "dplyr", "stringr", "forcats")
new_pkgs <- required_pkgs[!(required_pkgs %in% installed.packages()[, "Package"])]
if (length(new_pkgs)) install.packages(new_pkgs)

library(readxl)
library(dplyr)
library(stringr)
library(forcats)

# ============================================================================
# PART 1: IMPORT & CLEAN
# ============================================================================

# --- 1.1 Read the raw file ---
# Change the path below if your file lives somewhere else / has a different name
raw <- read_excel("Time Allocation, Sleep, and Career Signalling Among Students in Delhi Colleges (Responses).xlsx")
# --- 1.2 Rename columns to short names ---
# Column order in the export is fixed (it's a Google Form response sheet), so we
# rename by POSITION rather than by matching the long question text exactly
# (the long headers have inconsistent leading/trailing spaces that are easy to
# mistype). If you added/removed/reordered questions in the form, re-check this.
stopifnot(ncol(raw) == 24)

names(raw) <- c(
  "timestamp",            # -
  "age",                   # Q1  - Age
  "year",                  # Q3  - Year of Study
  "du_status",             # Q4  - DU / Non-DU
  "hometown_tier",         # Q5  - Hometown Tier
  "drop_year",             # Q6  - Drop Year
  "stream",                # Q7  - Stream
  "employment",            # Q8  - Internship/employment status
  "sleep_weekday",         # Q9  - Weekday sleep hours
  "sleep_weekend",         # Q10 - Weekend sleep hours
  "sleep_quality",         # Q11 - Sleep quality
  "sleep_sacrifice",       # Q12 - Sleep sacrifice frequency
  "stimulant_use",         # Q13 - Stimulant use frequency
  "societies_count_raw",   # Q14 - # societies/clubs (numeric, but messy - see 1.4)
  "extracurricular_hrs",   # Q15 - Extracurricular hours/week
  "internship_hrs",        # Q16 - Internship/work hours/week
  "academic_hrs",          # Q17 - Academic coursework hours/week
  "sacrificed_activity",   # Q18 - Activity sacrificed most often
  "screen_time",           # Q19 - Leisure screen time hours/week
  "peer_pressure",         # Q20 - Pressure to appear busy/productive
  "redesign_week",         # Q21 - Would sleep more if redesigning week
  "productivity_loss",     # Q22 - Next-day productivity after <6h sleep
  "sacrifice_driver",      # Q23 - Perceived biggest driver of sleep sacrifice
  "gender"                 # Q2  - Gender (NOTE: ~134/219 blank in raw data)
)

df <- raw

# --- 1.3 Nominal categorical columns -> factor() ---
df <- df %>%
  mutate(
    du_status           = factor(str_trim(du_status)),
    stream               = factor(str_trim(stream)),
    employment           = factor(str_trim(employment)),
    sacrificed_activity  = factor(str_trim(sacrificed_activity)),
    sacrifice_driver     = factor(str_trim(sacrifice_driver)),
    gender               = factor(str_trim(gender))   # NA stays NA
  )

# stream has many rare write-in categories (Law, Fashion, Design, etc. with n=1).
# For cross-tabs/chi-square these sparse cells will break tests, so we also
# make a COLLAPSED version. Use `stream` for descriptives, `stream_grp` for
# chi-square/KW tests unless your sheet specifically wants the fine-grained one.
rare_streams <- names(which(table(df$stream) < 5))
df$stream_grp <- forcats::fct_collapse(
  df$stream,
  Other = rare_streams
)
df$stream_grp <- factor(df$stream_grp)

# --- 1.4 Ordinal columns -> ordered factor() ---
df <- df %>%
  mutate(
    age = factor(age,
                  levels = c("17–19", "20–22", "23–25", "26 and above"),
                  ordered = TRUE),

    year = factor(year,
                   levels = c("1st year UG", "2nd year UG", "3rd year UG",
                              "4th year UG", "Post Graduate (PG)"),
                   ordered = TRUE),

    hometown_tier = factor(hometown_tier,
                             levels = c("Tier 1", "Tier 2", "Tier 3"),
                             ordered = TRUE),

    drop_year = factor(drop_year,
                         levels = c("No", "Yes, 1 year", "Yes, 2 years",
                                    "Yes, more than 2 years"),
                         ordered = TRUE),

    sleep_weekday = factor(sleep_weekday,
                             levels = c("Less than 4 hrs", "4–5 hrs", "6 hrs",
                                        "7 hrs", "8 or more hrs"),
                             ordered = TRUE),

    sleep_weekend = factor(sleep_weekend,
                             levels = c("Less than 4 hrs", "4–5 hrs", "6 hrs",
                                        "7 hrs", "8 or more hrs"),
                             ordered = TRUE),

    sleep_quality = factor(sleep_quality,
                             levels = c("Very poor", "Poor", "Average",
                                        "Good", "Very good"),
                             ordered = TRUE),

    sleep_sacrifice = factor(sleep_sacrifice,
                               levels = c("Never", "Rarely", "Sometimes",
                                          "Often", "Almost every day"),
                               ordered = TRUE),

    stimulant_use = factor(stimulant_use,
                             levels = c("Never", "Rarely", "Sometimes",
                                        "Often", "Daily"),
                             ordered = TRUE),

    extracurricular_hrs = factor(extracurricular_hrs,
                                   levels = c("0 hrs", "1–5 hrs", "6–10 hrs",
                                              "11–15 hrs", "More than 15 hrs"),
                                   ordered = TRUE),

    internship_hrs = factor(internship_hrs,
                              levels = c("0 hrs", "1–10 hrs", "11–20 hrs",
                                         "21–30 hrs", "More than 30 hrs"),
                              ordered = TRUE),

    academic_hrs = factor(academic_hrs,
                            levels = c("Less than 10 hrs", "10–20 hrs",
                                       "21–30 hrs", "31–40 hrs",
                                       "More than 40 hrs"),
                            ordered = TRUE),

    screen_time = factor(screen_time,
                           levels = c("Less than 5 hrs", "5–10 hrs",
                                      "11–20 hrs", "21–30 hrs",
                                      "More than 30 hrs"),
                           ordered = TRUE),

    peer_pressure = factor(peer_pressure,
                             levels = c("Strongly Disagree", "Disagree",
                                        "Neutral", "Agree", "Strongly Agree"),
                             ordered = TRUE),

    redesign_week = factor(redesign_week,
                             levels = c("Definitely not", "Probably not",
                                        "Unsure", "Probably yes",
                                        "Definitely yes"),
                             ordered = TRUE),

    productivity_loss = factor(productivity_loss,
                                 levels = c("Much worse", "Somewhat worse",
                                            "No difference", "Somewhat better",
                                            "Much better"),
                                 ordered = TRUE)
  )

# --- 1.5 Clean the messy numeric "societies_count" column ---
# Raw values include things like "6", "4-5", "No", "None", "O", "Vice president",
# "I was in 5 in UG1. In 2 in UG2. In 1 in UG3." -> we extract the LAST number
# mentioned (most recent / current count) where possible, else NA.
extract_societies_n <- function(x) {
  x <- as.character(x)
  x_lower <- str_to_lower(str_trim(x))
  out <- suppressWarnings(as.numeric(x))
  needs_parse <- is.na(out) & !is.na(x)
  # "No" / "None" / "O" (typo for 0) -> 0
  out[needs_parse & x_lower %in% c("no", "none", "o")] <- 0
  # anything else with digits in it -> take the LAST number mentioned
  still_na <- is.na(out) & !is.na(x)
  nums <- str_extract_all(x[still_na], "\\d+")
  out[still_na] <- sapply(nums, function(n) if (length(n) == 0) NA else as.numeric(tail(n, 1)))
  out
}
df$societies_count <- extract_societies_n(df$societies_count_raw)

# Flag rows that still couldn't be parsed (e.g. "Vice president") for manual review
cat("Rows where societies_count could not be parsed (now NA):\n")
print(df %>% filter(!is.na(societies_count_raw) & is.na(societies_count)) %>%
        select(societies_count_raw))

# --- 1.6 Quick structure check ---
glimpse(df)


install.packages("class")
library(class)
table(df$gender, useNA = "ifany")
df$gender_imputed <- df$gender
# =========================
# IMPROVED KNN FOR GENDER
# =========================

library(class)

# 1. Variables used to find similar students
knn_vars <- c(
  "age",
  "year",
  "du_status",
  "hometown_tier",
  "drop_year",
  "stream",
  "employment"
)

# 2. Keep only variables needed
knn_data <- df[, c(knn_vars, "gender")]

# 3. Convert categorical variables to factors
for (v in knn_vars) {
  knn_data[[v]] <- as.factor(knn_data[[v]])
}

knn_data$gender <- as.factor(knn_data$gender)

# 4. Keep students whose gender is known
known <- knn_data[!is.na(knn_data$gender), ]

# 5. Remove rows with missing predictor information
known <- known[complete.cases(known), ]

# 6. Create dummy variables properly
x_known <- model.matrix(
  ~ . - gender - 1,
  data = known
)

# 7. Remove variables with zero variance
keep <- apply(x_known, 2, function(x) sd(x) > 0)

x_known <- x_known[, keep, drop = FALSE]

# 8. Scale the predictors
x_known <- scale(x_known)

# 9. Gender labels
y_known <- droplevels(known$gender)

# 10. Use only Female and Male for KNN validation
use <- y_known %in% c("Female", "Male")

x_known <- x_known[use, , drop = FALSE]
y_known <- droplevels(y_known[use])

# 11. Split into training and testing data
set.seed(123)

train_index <- sample(
  1:length(y_known),
  size = round(0.80 * length(y_known))
)

test_index <- setdiff(
  1:length(y_known),
  train_index
)

# 12. Test different K values
k_values <- c(3, 5, 7, 9, 11)

results <- data.frame(
  K = k_values,
  Accuracy = NA
)

for (i in seq_along(k_values)) {
  
  pred <- knn(
    train = x_known[train_index, , drop = FALSE],
    test = x_known[test_index, , drop = FALSE],
    cl = y_known[train_index],
    k = k_values[i]
  )
  
  results$Accuracy[i] <- mean(
    pred == y_known[test_index]
  )
}

# 13. Show results
print(results)


# ================================
# KNN GENDER IMPUTATION
# ================================

library(class)

# Variables used to find similar students
knn_vars <- c(
  "age",
  "year",
  "du_status",
  "hometown_tier",
  "drop_year",
  "stream",
  "employment"
)

# Keep students whose gender is known
known <- df[!is.na(df$gender), c(knn_vars, "gender")]

# Only Female and Male for KNN
known <- known[known$gender %in% c("Female", "Male"), ]

# Remove students with missing predictor information
known <- known[complete.cases(known), ]

# Convert categorical variables to factors
known$year <- as.factor(known$year)
known$du_status <- as.factor(known$du_status)
known$hometown_tier <- as.factor(known$hometown_tier)
known$drop_year <- as.factor(known$drop_year)
known$stream <- as.factor(known$stream)
known$employment <- as.factor(known$employment)

# Convert categories into dummy variables
x <- model.matrix(~ . - gender - 1, data = known)

# Remove variables with zero variation
keep <- apply(x, 2, function(z) sd(z) > 0)
x <- x[, keep, drop = FALSE]

# Scale variables
x <- scale(x)

# Gender
y <- droplevels(known$gender)

# Split Female and Male
set.seed(123)

female <- which(y == "Female")
male <- which(y == "Male")

female_train <- sample(female, floor(0.8 * length(female)))
male_train <- sample(male, floor(0.8 * length(male)))

train_index <- c(female_train, male_train)
test_index <- setdiff(1:length(y), train_index)

# Balance the training data
set.seed(123)

female_balanced <- sample(
  female_train,
  length(male_train)
)

balanced_train <- c(
  female_balanced,
  male_train
)

# Test different K values
k_values <- c(3, 5, 7, 9, 11)

results <- data.frame(
  K = k_values,
  Accuracy = NA,
  Female_Accuracy = NA,
  Male_Accuracy = NA
)

for (i in seq_along(k_values)) {
  
  pred <- knn(
    train = x[balanced_train, , drop = FALSE],
    test = x[test_index, , drop = FALSE],
    cl = y[balanced_train],
    k = k_values[i]
  )
  
  actual <- y[test_index]
  
  results$Accuracy[i] <- mean(pred == actual)
  
  results$Female_Accuracy[i] <-
    mean(pred[actual == "Female"] == "Female")
  
  results$Male_Accuracy[i] <-
    mean(pred[actual == "Male"] == "Male")
}

print(results)
names(df)
k = k_values[i]
k = 9
# FINAL KNN IMPUTATION - K = 9

# Students with missing gender
missing <- df[is.na(df$gender), knn_vars]

# Convert categorical variables exactly like the known data
for (v in knn_vars) {
  missing[[v]] <- as.factor(missing[[v]])
}

# Keep only students whose predictor information is complete
complete_missing <- complete.cases(missing)

# Create dummy variables
x_missing <- model.matrix(~ . - 1, data = missing)

# Make sure missing data has exactly the same columns as training data
x_missing <- x_missing[, colnames(x), drop = FALSE]

# Scale using the same scaling as training data
x_missing <- scale(
  x_missing,
  center = attr(x, "scaled:center"),
  scale = attr(x, "scaled:scale")
)

# Predict gender using K = 9
predicted_gender <- knn(
  train = x[balanced_train, , drop = FALSE],
  test = x_missing[complete_missing, , drop = FALSE],
  cl = y[balanced_train],
  k = 9
)

# Put predictions into gender_imputed
df$gender_imputed <- df$gender

missing_rows <- which(is.na(df$gender))

df$gender_imputed[missing_rows[complete_missing]] <- predicted_gender

# Check result
table(df$gender_imputed, useNA = "ifany")
table(predicted_gender)
table(y[balanced_train])
table(df$stream_grp, df$gender, useNA = "ifany")

df$gender_final <- factor(df$gender_imputed)


# ============================================================
# TASK 2: BASIC DESCRIPTIVES
# ============================================================

# Function to show frequency and percentage
freq_percent <- function(x) {
  tab <- table(x, useNA = "ifany")
  pct <- prop.table(tab) * 100
  
  result <- data.frame(
    Frequency = as.vector(tab),
    Percentage = round(as.vector(pct), 2)
  )
  
  rownames(result) <- names(tab)
  return(result)
}

# ------------------------------------------------------------
# 2.1 DEMOGRAPHICS
# ------------------------------------------------------------

cat("\n===== AGE =====\n")
print(freq_percent(df$age))

cat("\n===== GENDER =====\n")
print(freq_percent(df$gender))

cat("\n===== YEAR =====\n")
print(freq_percent(df$year))

cat("\n===== DU STATUS =====\n")
print(freq_percent(df$du_status))

cat("\n===== HOMETOWN TIER =====\n")
print(freq_percent(df$hometown_tier))

cat("\n===== DROP YEAR =====\n")
print(freq_percent(df$drop_year))

cat("\n===== STREAM =====\n")
print(freq_percent(df$stream))


# ------------------------------------------------------------
# 2.2 INTERNSHIP / WORK PARTICIPATION
# ------------------------------------------------------------

cat("\n===== EMPLOYMENT / INTERNSHIP STATUS =====\n")
print(freq_percent(df$employment))

cat("\n===== INTERNSHIP HOURS =====\n")
print(freq_percent(df$internship_hrs))


# ------------------------------------------------------------
# 2.3 SLEEP PATTERNS
# ------------------------------------------------------------

cat("\n===== WEEKDAY SLEEP =====\n")
print(freq_percent(df$sleep_weekday))

cat("\n===== WEEKEND SLEEP =====\n")
print(freq_percent(df$sleep_weekend))

cat("\n===== SLEEP QUALITY =====\n")
print(freq_percent(df$sleep_quality))


# ------------------------------------------------------------
# 2.4 NUMERIC / ORDINAL SUMMARY
# ------------------------------------------------------------

cat("\n===== NUMERIC SUMMARY =====\n")

sleep_summary <- data.frame(
  Variable = c(
    "Weekday Sleep",
    "Weekend Sleep",
    "Sleep Quality",
    "Societies Count"
  ),
  
  Mean = c(
    mean(as.numeric(df$sleep_weekday), na.rm = TRUE),
    mean(as.numeric(df$sleep_weekend), na.rm = TRUE),
    mean(as.numeric(df$sleep_quality), na.rm = TRUE),
    mean(df$societies_count, na.rm = TRUE)
  ),
  
  Median = c(
    median(as.numeric(df$sleep_weekday), na.rm = TRUE),
    median(as.numeric(df$sleep_weekend), na.rm = TRUE),
    median(as.numeric(df$sleep_quality), na.rm = TRUE),
    median(df$societies_count, na.rm = TRUE)
  )
)

sleep_summary$Mean <- round(sleep_summary$Mean, 2)
sleep_summary$Median <- round(sleep_summary$Median, 2)

print(sleep_summary)


# ------------------------------------------------------------
# 2.5 OTHER DESCRIPTIVES
# ------------------------------------------------------------

cat("\n===== SOCIETIES COUNT =====\n")
print(summary(df$societies_count))

cat("\n===== EXTRACURRICULAR HOURS =====\n")
print(freq_percent(df$extracurricular_hrs))

cat("\n===== ACADEMIC HOURS =====\n")
print(freq_percent(df$academic_hrs))

cat("\n===== SACRIFICED ACTIVITY =====\n")
print(freq_percent(df$sacrificed_activity))

cat("\n===== SCREEN TIME =====\n")
print(freq_percent(df$screen_time))

cat("\n===== PEER PRESSURE =====\n")
print(freq_percent(df$peer_pressure))

cat("\n===== REDESIGN WEEK =====\n")
print(freq_percent(df$redesign_week))

cat("\n===== PRODUCTIVITY LOSS =====\n")
print(freq_percent(df$productivity_loss))

cat("\n===== SACRIFICE DRIVER =====\n")
print(freq_percent(df$sacrifice_driver))

cat("\n===== STIMULANT USE =====\n")
print(freq_percent(df$stimulant_use))

cat("\n===== SLEEP SACRIFICE =====\n")
print(freq_percent(df$sleep_sacrifice))



# ============================================================
# TASK 3 - CROSS-TABS + CHI-SQUARE TESTS
# ============================================================

# Function for cross-tab + percentages + Chi-square
chi_test <- function(var1, var2) {
  
  cat("\n============================================\n")
  cat(var1, " X ", var2, "\n")
  cat("============================================\n")
  
  # Remove missing observations
  d <- df[!is.na(df[[var1]]) & !is.na(df[[var2]]), ]
  
  # Cross-tabulation
  tab <- table(d[[var1]], d[[var2]])
  
  cat("\nCross-tabulation:\n")
  print(tab)
  
  # Row percentages
  cat("\nRow percentages:\n")
  print(round(prop.table(tab, 1) * 100, 2))
  
  # Chi-square test
  cat("\nChi-square test:\n")
  print(chisq.test(tab))
}


# Q12 Sleep Sacrifice
chi_test("sleep_sacrifice", "stream_grp")
chi_test("sleep_sacrifice", "gender_imputed")
chi_test("sleep_sacrifice", "employment")

# Q13 Stimulant Use
chi_test("stimulant_use", "stream_grp")
chi_test("stimulant_use", "gender_imputed")
chi_test("stimulant_use", "employment")

# Q18 Sacrificed Activity
chi_test("sacrificed_activity", "stream_grp")
chi_test("sacrificed_activity", "gender_imputed")
chi_test("sacrificed_activity", "employment")

# Q20 Peer Pressure
chi_test("peer_pressure", "stream_grp")
chi_test("peer_pressure", "gender_imputed")
chi_test("peer_pressure", "employment")

# Q21 Redesign Week
chi_test("redesign_week", "stream_grp")
chi_test("redesign_week", "gender_imputed")

# Q23 Sacrifice Driver
chi_test("sacrifice_driver", "stream_grp")
chi_test("sacrifice_driver", "gender_imputed")
chi_test("sacrifice_driver", "employment")


# ============================================================
# TASK 4 - SPEARMAN + GROUP COMPARISONS
# ============================================================

# Function for Spearman correlation
spearman_test <- function(var1, var2) {
  
  cat("\n============================================\n")
  cat("SPEARMAN:", var1, "vs", var2, "\n")
  cat("============================================\n")
  
  d <- df[!is.na(df[[var1]]) & !is.na(df[[var2]]), ]
  
  x <- as.numeric(d[[var1]])
  y <- as.numeric(d[[var2]])
  
  print(
    cor.test(
      x,
      y,
      method = "spearman",
      exact = FALSE
    )
  )
}


# Function for Mann-Whitney / Kruskal-Wallis
group_test <- function(outcome, group) {
  
  cat("\n============================================\n")
  cat(outcome, " BY ", group, "\n")
  cat("============================================\n")
  
  d <- df[
    !is.na(df[[outcome]]) &
      !is.na(df[[group]]),
  ]
  
  y <- as.numeric(d[[outcome]])
  g <- factor(d[[group]])
  
  # Remove groups with zero observations
  g <- droplevels(g)
  
  if (nlevels(g) == 2) {
    
    cat("\nMann-Whitney U test:\n")
    
    print(
      wilcox.test(
        y ~ g,
        exact = FALSE
      )
    )
    
  } else if (nlevels(g) >= 3) {
    
    cat("\nKruskal-Wallis test:\n")
    
    print(
      kruskal.test(
        y ~ g
      )
    )
    
  } else {
    
    cat("\nNot enough groups for this test.\n")
  }
}


# ============================================================
# SLEEP
# ============================================================

spearman_test("sleep_weekday", "sleep_weekend")

spearman_test("sleep_weekday", "sleep_quality")

spearman_test("sleep_sacrifice", "sleep_weekday")

spearman_test("sleep_sacrifice", "sleep_weekend")


# ============================================================
# SLEEP SACRIFICE & WORKLOAD
# ============================================================

spearman_test("sleep_sacrifice", "extracurricular_hrs")

spearman_test("sleep_sacrifice", "internship_hrs")

spearman_test("sleep_sacrifice", "academic_hrs")

spearman_test("sleep_sacrifice", "screen_time")


# ============================================================
# STIMULANT USE
# ============================================================

spearman_test("stimulant_use", "sleep_weekday")

spearman_test("stimulant_use", "sleep_sacrifice")


# ============================================================
# EXTRACURRICULARS
# ============================================================

spearman_test("societies_count", "sleep_weekday")

spearman_test("extracurricular_hrs", "sleep_sacrifice")

group_test("sleep_sacrifice", "stream_grp")

group_test("sleep_sacrifice", "year")


# ============================================================
# ACADEMIC WORKLOAD
# ============================================================

spearman_test("academic_hrs", "sleep_weekday")

spearman_test("academic_hrs", "sleep_quality")

group_test("academic_hrs", "stream_grp")

group_test("academic_hrs", "employment")


# ============================================================
# SCREEN TIME
# ============================================================

spearman_test("screen_time", "sleep_weekday")

spearman_test("screen_time", "sleep_quality")

spearman_test("screen_time", "sleep_sacrifice")

group_test("screen_time", "stream_grp")

group_test("screen_time", "year")

group_test("screen_time", "gender_imputed")


# ============================================================
# PEER PRESSURE
# ============================================================

group_test("peer_pressure", "gender_imputed")

group_test("peer_pressure", "stream_grp")

group_test("peer_pressure", "year")

spearman_test("peer_pressure", "sleep_sacrifice")


# ============================================================
# PRODUCTIVITY LOSS
# ============================================================

spearman_test("productivity_loss", "sleep_weekday")

spearman_test("productivity_loss", "sleep_quality")

spearman_test("productivity_loss", "sleep_sacrifice")

group_test("productivity_loss", "stream_grp")















































