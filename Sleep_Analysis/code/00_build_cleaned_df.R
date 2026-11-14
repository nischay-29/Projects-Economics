# Rebuilds cleaned_df.rds from Cleaned_Student_Time_Allocation_Data.xlsx, using the
# same factor definitions as part 1 of the original script. part5to8_plain.R reads
# the .rds file this script writes.
# Usage: Rscript 00_build_cleaned_df.R Cleaned_Student_Time_Allocation_Data.xlsx cleaned_df.rds
args <- commandArgs(trailingOnly = TRUE)
library(readxl)
df <- as.data.frame(read_excel(args[1], sheet = "Cleaned Data"))
ord <- list(
  age = c("17–19", "20–22", "23–25", "26 and above"),
  year = c("1st year UG", "2nd year UG", "3rd year UG", "4th year UG", "Post Graduate (PG)"),
  hometown_tier = c("Tier 1", "Tier 2", "Tier 3"),
  drop_year = c("No", "Yes, 1 year", "Yes, 2 years", "Yes, more than 2 years"),
  sleep_weekday = c("Less than 4 hrs", "4–5 hrs", "6 hrs", "7 hrs", "8 or more hrs"),
  sleep_weekend = c("Less than 4 hrs", "4–5 hrs", "6 hrs", "7 hrs", "8 or more hrs"),
  sleep_quality = c("Very poor", "Poor", "Average", "Good", "Very good"),
  sleep_sacrifice = c("Never", "Rarely", "Sometimes", "Often", "Almost every day"),
  stimulant_use = c("Never", "Rarely", "Sometimes", "Often", "Daily"),
  extracurricular_hrs = c("0 hrs", "1–5 hrs", "6–10 hrs", "11–15 hrs", "More than 15 hrs"),
  internship_hrs = c("0 hrs", "1–10 hrs", "11–20 hrs", "21–30 hrs", "More than 30 hrs"),
  academic_hrs = c("Less than 10 hrs", "10–20 hrs", "21–30 hrs", "31–40 hrs", "More than 40 hrs"),
  screen_time = c("Less than 5 hrs", "5–10 hrs", "11–20 hrs", "21–30 hrs", "More than 30 hrs"),
  peer_pressure = c("Strongly Disagree", "Disagree", "Neutral", "Agree", "Strongly Agree"),
  redesign_week = c("Definitely not", "Probably not", "Unsure", "Probably yes", "Definitely yes"),
  productivity_loss = c("Much worse", "Somewhat worse", "No difference", "Somewhat better", "Much better")
)
for (v in names(ord)) {
  raw <- trimws(as.character(df[[v]]))
  bad <- setdiff(unique(raw[!is.na(raw)]), ord[[v]])
  if (length(bad)) cat("UNMATCHED in", v, ":", paste(bad, collapse = " | "), "\n")
  df[[v]] <- factor(raw, levels = ord[[v]], ordered = TRUE)
}
for (v in c("du_status", "stream", "employment", "sacrificed_activity", "sacrifice_driver",
            "gender", "stream_grp", "gender_imputed", "gender_final"))
  df[[v]] <- factor(trimws(as.character(df[[v]])))
for (v in c(names(ord), "stream_grp", "employment", "gender", "gender_imputed", "gender_final")) {
  cat("\n", v, "\n"); print(table(df[[v]], useNA = "ifany"))
}
saveRDS(df, args[2])
