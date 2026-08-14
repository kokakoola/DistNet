rm(list = ls())
graphics.off()


dat <- read.csv(
  "Data/AMF_DistNet_species(Data - colonisation).csv",
  header = T,
  sep = ";"
)
# dat[dat == ""] <- NA
dat$AMF.total <- as.numeric(dat$COLONISATION)
dat$HYP <- as.numeric(dat$HYP.)
dat$ARB <- as.numeric(dat$ARB.)
dat$VES <- as.numeric(dat$VES.)

dat$habitat <- factor(dat$habitat)
dat$treatment <- factor(dat$treatment)
dat$species <- factor(dat$species)


summary(dat$AMF.total)
hist(dat$AMF.total)

dat$logAMF <- log1p(dat$AMF.total)

m1 <- lm(logAMF ~ habitat * treatment + species, data = dat)
summary(m1)
# Call:
# lm(formula = logAMF ~ habitat * treatment + species, data = dat)

# Residuals:
#      Min       1Q   Median       3Q      Max
# -1.73336 -0.51825 -0.08566  0.33390  2.11125

# Coefficients:
#                                   Estimate Std. Error t value Pr(>|t|)
# (Intercept)                         2.2106     1.0104   2.188  0.04138 *
# habitatgrassland                    2.3687     0.6864   3.451  0.00268 **
# treatmentnetwork                   -1.2055     0.7034  -1.714  0.10280
# speciesDactylis glomerata          -0.4772     0.8637  -0.552  0.58705
# speciesLeontodon hispidus          -0.5120     1.4046  -0.365  0.71949
# speciesSilene nutans               -3.0406     0.9758  -3.116  0.00569 **
# habitatgrassland:treatmentnetwork   1.0896     0.9048   1.204  0.24327
# ---
# Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

# Residual standard error: 1.049 on 19 degrees of freedom
#   (44 observations deleted due to missingness)
# Multiple R-squared:  0.7416,	Adjusted R-squared:  0.6601
# F-statistic:  9.09 on 6 and 19 DF,  p-value: 9.248e-05
levels(dat$treatment)

# which(abs(rstandard(m1)) > 2)
# dat[c(17, 16, 13, 18, 20, 53, 12, 19, 31), ]

# m1_no_out <- lm(
#   logAMF ~ habitat * treatment + species,
#   data = dat[-c(16, 19), ]
# )
# summary(m1_no_out)

#Hüüfide kohta sama.
dat$logHYP <- log1p(dat$HYP)

m_hyp <- lm(logHYP ~ habitat * treatment + species, data = dat)
summary(m_hyp) #oliline ainult kasvukoht, silenel vähem HYP kui teistel

dat$logARB <- log1p(dat$ARB)
m_arb <- lm(logARB ~ habitat * treatment + species, data = dat)
summary(m_arb)

dat$logVES <- log1p(dat$VES)
m_ves <- lm(logVES ~ habitat * treatment + species, data = dat)
summary(m_ves)
plot(m_ves)

m_ves_no_out <- lm(
  logVES ~ habitat * treatment + species,
  data = dat[-which.min(residuals(m_ves)), ]
)
summary(m_ves_no_out)

# kas metsas/rohumaal treatmenti mõju erinev?
m_forest <- lm(
  logAMF ~ treatment + species,
  data = subset(dat, habitat == "forest")
)

m_grass <- lm(
  logAMF ~ treatment + species,
  data = subset(dat, habitat == "grassland")
)

summary(m_forest)
summary(m_grass)

boxplot(AMF.total ~ habitat:treatment, data = dat)
boxplot(logAMF ~ habitat:treatment, data = dat)

dat$colonized <- dat$BOTH + dat$ARB + dat$VES + dat$HYP + dat$COIL

dat$not_colonized <- dat$NO.


# Kadri glm binominaliga (Fisher). Ei tööta - andmeid vähe, Habitat efekt liiga suur.
# dat_no_out <- dat[-which.min(residuals(m1)), ]
dat$colonized <- ifelse(dat$AMF.total > 0, 1, 0)
model_glm <- glm(
  colonized ~ habitat * treatment,
  family = binomial(link = "logit"),
  data = dat
)

summary(model_glm)

# Call:
# glm(formula = colonized ~ habitat * treatment, family = binomial(link = "logit"),
#     data = dat)

# Coefficients:
#                                     Estimate Std. Error z value Pr(>|z|)
# (Intercept)                       -2.458e-17  1.000e+00   0.000    1.000
# habitatgrassland                   2.057e+01  5.910e+03   0.003    0.997
# treatmentnetwork                  -1.386e+00  1.500e+00  -0.924    0.355
# habitatgrassland:treatmentnetwork  1.386e+00  8.615e+03   0.000    1.000

# (Dispersion parameter for binomial family taken to be 1)

#     Null deviance: 28.091  on 25  degrees of freedom
# Residual deviance: 10.549  on 22  degrees of freedom
#   (44 observations deleted due to missingness)
# AIC: 18.549

# Number of Fisher Scoring iterations: 19

tapply(dat$AMF.total, dat$treatment, mean)

table(dat$colonized, dat$habitat)

table(dat$colonized, dat$treatment)
fisher.test(table(dat$colonized, dat$habitat))
# Fisher's Exact Test for Count Data

# data:  table(dat$colonized, dat$habitat)
# p-value = 0.0003649
# alternative hypothesis: true odds ratio is not equal to 1
# 95 percent confidence interval:
#  3.800321      Inf
# sample estimates:
# odds ratio
#        Inf

fisher.test(table(dat$colonized, dat$treatment))
# Fisher's Exact Test for Count Data

# data:  table(dat$colonized, dat$treatment)
# p-value = 0.6447
# alternative hypothesis: true odds ratio is not equal to 1
# 95 percent confidence interval:
#  0.03136315 3.77530945
# sample estimates:
# odds ratio
#  0.4234035

tapply(dat$AMF.total, dat$species, median, na.rm = TRUE)
# Achillea millefolium    Chicorium intybus   Dactylis glomerata   Leontodon hispidus        Silene nutans
#                   NA                 96.5                 38.0                 51.0                  2.0

tapply(dat$AMF.total, list(dat$species, dat$habitat), mean, na.rm = TRUE)
#  forest grassland
# Achillea millefolium      NaN       NaN
# Chicorium intybus         NaN 96.500000
# Dactylis glomerata   8.444444 58.363636
# Leontodon hispidus        NaN 51.000000
# Silene nutans             NaN  5.666667
