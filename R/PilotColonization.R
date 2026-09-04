library(readr)

if (!file.exists("data/processed/colonization.csv")) {
  source("R/helpers/clean_data.R") # create csv if it is missing - call fetch from sharepoint, clean and save.
}

colonization$log_total <- log1p(colonization$total)

m1 <- lm(log_total ~ habitat * treatment + species, data = colonization)
summary(m1) # only habitat is significant

# Ma ei tea enam milleks see sellisel kujul hea on. Mõtleme.
m_forest <- lm(
  log_total ~ treatment + species,
  data = subset(colonization, habitat == "forest")
)
summary(m_forest)

m_grassland <- lm(
  log_total ~ treatment + species,
  data = subset(colonization, habitat == "grassland")
)
summary(m_grassland)
