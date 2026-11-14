# Robustness checks on the four ordinal logistic models in part5to8_plain.R.
# Run after 00_build_cleaned_df.R, from the folder that holds cleaned_df.rds.
#   A. Stimulant use and sleep sacrifice: odds ratio per one-step change, with and
#      without controls, plus linearity and proportional-odds checks.
#   B. Sleep sacrifice by stream: with Commerce/Economics as the reference group,
#      without the imputed gender variable, and without the Engineering group.
#   C. Productivity after a short night and weekday sleep: direction of the coding,
#      linear against quadratic, and which sleep group produces the curvature.
#   D. Sleep quality and weekday sleep: odds ratio per one-step change.
#   E. Headline tests without the imputed gender variable.
#   F. Employment status and sleep sacrifice: small expected counts.
suppressMessages({library(MASS); library(car); library(nnet)})
options(width = 170)
df <- readRDS("cleaned_df.rds")
num <- function(x) as.numeric(x)
df$ss_n <- num(df$sleep_sacrifice); df$sw_n <- num(df$sleep_weekday); df$st_n <- num(df$screen_time)
df$stim_n <- num(df$stimulant_use); df$pl_n <- num(df$productivity_loss); df$sq_n <- num(df$sleep_quality)
orci <- function(m, pat) { ci <- suppressMessages(confint(m)); if (is.null(dim(ci))) ci <- matrix(ci, nrow = 1, dimnames = list(names(coef(m)), names(ci))); k <- grep(pat, names(coef(m)));
  out <- cbind(OR = exp(coef(m))[k], exp(ci[k, , drop = FALSE])); print(round(out, 2)) }
lrp <- function(a, b) { x <- anova(a, b); print(x[, c("Resid. df", "Resid. Dev", "LR stat.", "Pr(Chi)")]) }

cat("\n===== A. STIMULANT USE ~ SLEEP SACRIFICE =====\n")
cat("crosstab (rows: sleep sacrifice, cols: stimulant use), row %\n")
t <- table(df$sleep_sacrifice, df$stimulant_use); print(t); print(round(prop.table(t, 1) * 100, 0))
cat("mean stimulant score (1-5) by sleep sacrifice level:\n"); print(round(tapply(df$stim_n, df$sleep_sacrifice, mean), 2))
a1 <- polr(stimulant_use ~ ss_n, data = df, Hess = TRUE)
cat("bivariate, sleep sacrifice numeric 1-5: OR per one step\n"); orci(a1, "ss_n")
a2 <- polr(stimulant_use ~ ss_n + sw_n + st_n, data = df, Hess = TRUE)
cat("with weekday sleep and screen time (numeric): OR per one step\n"); orci(a2, ".")
a3 <- polr(stimulant_use ~ ss_n + sleep_weekday + screen_time, data = df, Hess = TRUE)
cat("with weekday sleep and screen time as factors (as in model 3): OR per step for ss_n\n"); orci(a3, "ss_n")
cat("p-value for ss_n in a3 (LR):\n"); print(Anova(a3, type = "II"))
a4 <- polr(stimulant_use ~ ss_n + sleep_weekday + screen_time + stream_grp + employment + year, data = df, Hess = TRUE)
cat("adding stream, employment, year: OR per step for ss_n\n"); orci(a4, "ss_n")
cat("is the step effect linear? numeric vs factor coding of sleep sacrifice (LR test)\n")
m3 <- polr(stimulant_use ~ sleep_weekday + sleep_sacrifice + screen_time, data = df, Hess = TRUE)
lrp(a3, m3)
cat("treatment-coded ORs vs 'Sometimes' (largest group):\n")
df$ss_t <- relevel(factor(df$sleep_sacrifice, ordered = FALSE), ref = "Sometimes")
a5 <- polr(stimulant_use ~ ss_t + sleep_weekday + screen_time, data = df, Hess = TRUE); orci(a5, "ss_t")
cat("collapsed: Never/Rarely vs Sometimes vs Often/Almost every day\n")
df$ss_3 <- cut(df$ss_n, c(0, 2, 3, 5), labels = c("Never/Rarely", "Sometimes", "Often/Daily"))
print(table(df$ss_3)); a6 <- polr(stimulant_use ~ ss_3 + sleep_weekday + screen_time, data = df, Hess = TRUE); orci(a6, "ss_3")
cat("proportional odds check: polr vs multinomial logit (bivariate numeric)\n")
mn <- multinom(stimulant_use ~ ss_n, data = df, trace = FALSE)
d <- deviance(a1) - deviance(mn); dfx <- mn$edf - a1$edf; cat("LR =", round(d, 2), "df =", dfx, "p =", round(pchisq(d, dfx, lower.tail = FALSE), 3), "\n")
cat("Spearman:\n"); print(cor.test(df$ss_n, df$stim_n, method = "spearman", exact = FALSE)[c("estimate", "p.value")])

cat("\n===== B. SLEEP SACRIFICE ~ STREAM (model 1) =====\n")
t <- table(df$stream_grp, df$sleep_sacrifice); print(t); print(round(prop.table(t, 1) * 100, 0))
cat("share Often/Almost every day by stream:\n"); print(round(tapply(df$ss_n >= 4, df$stream_grp, mean) * 100, 0))
df$stream_c <- relevel(df$stream_grp, ref = "Commerce / Economics")
f_full <- sleep_sacrifice ~ extracurricular_hrs + internship_hrs + academic_hrs + screen_time + employment + stream_c + gender_final + year
b1 <- polr(f_full, data = df, Hess = TRUE)
cat("m1 with Commerce/Economics as reference: stream ORs\n"); orci(b1, "stream_c")
b2 <- polr(update(f_full, . ~ . - gender_final), data = df, Hess = TRUE)
cat("m1 without imputed gender: Type II tests and stream ORs\n"); print(Anova(b2, type = "II")); orci(b2, "stream_c")
b3 <- polr(sleep_sacrifice ~ stream_c, data = df, Hess = TRUE)
cat("stream only: \n"); print(Anova(b3, type = "II")); orci(b3, "stream_c")
d2 <- droplevels(subset(df, stream_grp != "Engineering"))
b4 <- polr(update(f_full, . ~ . - gender_final), data = d2, Hess = TRUE)
cat("without Engineering (n=14) and without gender: is stream still significant?\n"); print(Anova(b4, type = "II"))
cat("Kruskal-Wallis sleep sacrifice by stream, with and without Engineering\n")
print(kruskal.test(ss_n ~ stream_grp, data = df)$p.value); print(kruskal.test(ss_n ~ stream_grp, data = d2)$p.value)
cat("Engineering vs all others, Wilcoxon:\n"); print(wilcox.test(ss_n ~ I(stream_grp == "Engineering"), data = df, exact = FALSE)$p.value)

cat("\n===== C. PRODUCTIVITY AFTER SHORT SLEEP ~ WEEKDAY SLEEP (model 2 and the non-linearity check) =====\n")
cat("NOTE coding: 1 = Much worse ... 5 = Much better, so HIGHER = LESS loss\n")
t <- table(df$sleep_weekday, df$productivity_loss); print(t); print(round(prop.table(t, 1) * 100, 0))
cat("mean score by weekday sleep (higher = less loss):\n"); print(round(tapply(df$pl_n, df$sleep_weekday, mean), 2))
cat("share reporting worse (Much/Somewhat worse) by weekday sleep:\n"); print(round(tapply(df$pl_n <= 2, df$sleep_weekday, mean) * 100, 0))
c1 <- polr(productivity_loss ~ sw_n, data = df, Hess = TRUE)
c2 <- polr(productivity_loss ~ sw_n + I(sw_n^2), data = df, Hess = TRUE)
c3 <- polr(productivity_loss ~ sleep_weekday, data = df, Hess = TRUE)
cat("linear vs quadratic (LR):\n"); lrp(c1, c2)
cat("AIC lin/quad/factor:", round(AIC(c1), 2), round(AIC(c2), 2), round(AIC(c3), 2), "\n")
cat("linear term alone: OR per step and LR p\n"); orci(c1, "sw_n"); print(Anova(c1, type = "II"))
cat("quadratic without the <4 hrs group (n=10):\n")
d3 <- subset(df, sw_n > 1); c4 <- polr(productivity_loss ~ sw_n, data = d3, Hess = TRUE); c5 <- polr(productivity_loss ~ sw_n + I(sw_n^2), data = d3, Hess = TRUE); lrp(c4, c5)
cat("quadratic without the 8+ hrs group (n=22):\n")
d4 <- subset(df, sw_n < 5); c6 <- polr(productivity_loss ~ sw_n, data = d4, Hess = TRUE); c7 <- polr(productivity_loss ~ sw_n + I(sw_n^2), data = d4, Hess = TRUE); lrp(c6, c7)
cat("m2 stream ORs with Commerce/Economics reference, no gender (OR>1 = LESS loss than Commerce):\n")
c8 <- polr(productivity_loss ~ sleep_weekday + sleep_sacrifice + stream_c, data = df, Hess = TRUE); print(Anova(c8, type = "II")); orci(c8, "stream_c")
cat("mean productivity score by stream (higher = less loss), n:\n"); print(round(tapply(df$pl_n, df$stream_grp, mean), 2)); print(table(df$stream_grp))
cat("Spearman productivity score vs sleep sacrifice (reported rho = 0.14):\n"); print(cor.test(df$pl_n, df$ss_n, method = "spearman", exact = FALSE)[c("estimate", "p.value")])

cat("\n===== D. SLEEP QUALITY ~ WEEKDAY SLEEP (model 4) =====\n")
e1 <- polr(sleep_quality ~ sw_n + academic_hrs + peer_pressure, data = df, Hess = TRUE)
cat("OR per one step of weekday sleep, no gender:\n"); orci(e1, "sw_n"); print(Anova(e1, type = "II"))

cat("\n===== E. MODELS WITHOUT IMPUTED GENDER: do headline tests change? =====\n")
print(Anova(polr(productivity_loss ~ sleep_weekday + sleep_sacrifice + stream_grp, data = df, Hess = TRUE), type = "II"))
cat("gender observed only (n):", sum(!is.na(df$gender)), " imputed:", sum(is.na(df$gender)), "\n")
print(table(observed = df$gender, final = df$gender_final, useNA = "ifany"))

cat("\n===== F. employment x sleep sacrifice (the one significant chi-square test) =====\n")
t <- table(df$employment, df$sleep_sacrifice); print(t); x <- suppressWarnings(chisq.test(t)); print(x); cat("expected counts < 5:", sum(x$expected < 5), "of", length(x$expected), "\n")
set.seed(1); print(chisq.test(t, simulate.p.value = TRUE, B = 20000)$p.value); print(kruskal.test(ss_n ~ employment, data = df)$p.value)
