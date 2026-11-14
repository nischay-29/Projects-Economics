library(MASS)
library(car)
library(psych)
library(dplyr)

df <- readRDS("cleaned_df.rds")

# ---- PART 5: ordinal logistic regressions ----

# 5.1 sleep sacrifice ~ time use + demographics
m1 <- polr(sleep_sacrifice ~ extracurricular_hrs + internship_hrs + academic_hrs +
             screen_time + employment + stream_grp + gender_final + year,
           data = df, Hess = TRUE)
summary(m1)
exp(cbind(OR = coef(m1), confint(m1)))
Anova(m1, type = "II")

# 5.2 productivity loss ~ sleep + demographics
m2 <- polr(productivity_loss ~ sleep_weekday + sleep_sacrifice + stream_grp + gender_final,
           data = df, Hess = TRUE)
summary(m2)
exp(cbind(OR = coef(m2), confint(m2)))
Anova(m2, type = "II")

# 5.3 stimulant use ~ sleep + screen time
m3 <- polr(stimulant_use ~ sleep_weekday + sleep_sacrifice + screen_time,
           data = df, Hess = TRUE)
summary(m3)
exp(cbind(OR = coef(m3), confint(m3)))
Anova(m3, type = "II")

# 5.4 sleep quality ~ sleep + workload + peer pressure
m4 <- polr(sleep_quality ~ sleep_weekday + academic_hrs + peer_pressure + gender_final,
           data = df, Hess = TRUE)
summary(m4)
exp(cbind(OR = coef(m4), confint(m4)))
Anova(m4, type = "II")

# optional: check proportional odds assumption
# install.packages("brant")
# brant::brant(m1)


# ---- PART 6: interactions ----
# using numeric versions of the ordinal predictors here, full factor x factor
# interactions blew up (rank-deficient, empty cells at n=219)

df$extracurricular_hrs_n <- as.numeric(df$extracurricular_hrs)
df$academic_hrs_n <- as.numeric(df$academic_hrs)
df$screen_time_n <- as.numeric(df$screen_time)

m5 <- polr(sleep_sacrifice ~ extracurricular_hrs_n * stream_grp, data = df, Hess = TRUE)
Anova(m5, type = "II")

m6 <- polr(sleep_sacrifice ~ academic_hrs_n * employment, data = df, Hess = TRUE)
Anova(m6, type = "II")

m7 <- polr(sleep_quality ~ screen_time_n * gender_final, data = df, Hess = TRUE)
summary(m7)   # check this one carefully, gender_final "Others" only has n=2
Anova(m7, type = "II")


# ---- PART 7: linear vs quadratic (non-linear check) ----

check_nonlinear <- function(outcome, pred_ordered, data) {
  d <- data
  d$pred_n <- as.numeric(d[[pred_ordered]])
  lin <- polr(reformulate("pred_n", response = outcome), data = d, Hess = TRUE)
  quad <- polr(reformulate("poly(pred_n, 2)", response = outcome), data = d, Hess = TRUE)
  cat(outcome, "~", pred_ordered, "\n")
  cat("linear AIC:", AIC(lin), " | quadratic AIC:", AIC(quad), "\n\n")
  list(lin = lin, quad = quad)
}

nl1 <- check_nonlinear("sleep_sacrifice", "extracurricular_hrs", df)
nl2 <- check_nonlinear("sleep_sacrifice", "academic_hrs", df)
nl3 <- check_nonlinear("productivity_loss", "sleep_weekday", df)
summary(nl3$quad)  # this one actually curves, check the poly() term p-value


# ---- PART 8: composite pressure index ----

items <- df %>%
  transmute(
    sleep_sacrifice_n = as.numeric(sleep_sacrifice),
    peer_pressure_n = as.numeric(peer_pressure),
    redesign_week_n = as.numeric(redesign_week)
  )

psych::alpha(items)   # check raw_alpha before trusting this index at all

df$pressure_index <- rowMeans(items, na.rm = TRUE)
summary(df$pressure_index)

df$pressure_tertile <- cut(df$pressure_index,
                            breaks = quantile(df$pressure_index, c(0, 1/3, 2/3, 1), na.rm = TRUE),
                            labels = c("Low", "Medium", "High"),
                            include.lowest = TRUE)

tab <- table(df$pressure_tertile, df$sacrifice_driver)
tab
chisq.test(tab)
