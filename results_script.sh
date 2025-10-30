library(tidyverse)
library(RColorBrewer)
library(paletteer)
library(extrafont)

# Load the data
full_bracken_data <- read.delim("D:/Bioinformatics/combined_bracken.tsv", stringsAsFactors = FALSE)

# Select only the fraction columns
frac_cols <- grep("bracken_frac$", names(full_bracken_data), value = TRUE)

# Reshape to long format
long_data <- full_bracken_data %>%
  select(name, all_of(frac_cols)) %>%
  pivot_longer(cols = -name, names_to = "Sample", values_to = "Fraction")

# Identify top 10 taxa by total abundance
top_taxa <- long_data %>%
  group_by(name) %>%
  summarise(total_fraction = sum(Fraction)) %>%
  top_n(10, total_fraction) %>%
  pull(name)

# Replace non-top taxa with "Other Families"
long_data_grouped <- long_data %>%
  mutate(name = if_else(name %in% top_taxa, name, "Other Families")) %>%
  group_by(Sample, name) %>%
  summarise(Fraction = sum(Fraction), .groups = "drop")


# Reorder factor levels so "Other Families" is first (bottom of stack)
long_data_grouped$name <- factor(long_data_grouped$name,
                                 levels = c(setdiff(unique(long_data_grouped$name), "Other Families"), "Other Families"))

long_data_grouped <- long_data_grouped %>%
  mutate(Sample = recode(Sample,
                         "ctrl1_0_boutput.bracken_frac" = "Ctrl 1 (wk0)",
                         "ctrl1_3_boutput.bracken_frac" = "Ctrl 1 (wk3)",
                         "ctrl2_0_boutput.bracken_frac" = "Ctrl 2 (wk0)",
                         "ctrl2_3_boutput.bracken_frac" = "Ctrl 2 (wk3)",
                         "ctrl3_0_boutput.bracken_frac" = "Ctrl 3 (wk0)",
                         "ctrl3_3_boutput.bracken_frac" = "Ctrl 3 (wk3)",
                         "ctrl4_0_boutput.bracken_frac" = "Ctrl 4 (wk0)",
                         "ctrl4_3_boutput.bracken_frac" = "Ctrl 4 (wk3)",
                         "oa1_0_boutput.bracken_frac" = "OA 1 (wk0)",
                         "oa1_3_boutput.bracken_frac" = "OA 1 (wk3)",
                         "oa2_0_boutput.bracken_frac" = "OA 2 (wk0)",
                         "oa2_3_boutput.bracken_frac" = "OA 2 (wk3)",
                         "oa3_0_boutput.bracken_frac" = "OA 3 (wk0)",
                         "oa3_3_boutput.bracken_frac" = "OA 3 (wk3)",
                         "oa4_0_boutput.bracken_frac" = "OA 4 (wk0)",
                         "oa4_3_boutput.bracken_frac" = "OA 4 (wk3)",
                         # Add more mappings as needed
  ))

# Plot
ggplot(long_data_grouped, aes(x = Sample, y = Fraction, fill = name)) +
  geom_bar(stat = "identity") +
  labs(title = "Top 10 Families by Relative Abundance",
       x = "Sample",
       y = "Relative Abundance",
       fill = "Family") +
  theme_classic() +
  scale_fill_paletteer_d("colorBlindness::ModifiedSpectralScheme11Steps") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
