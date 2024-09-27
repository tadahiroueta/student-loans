library(dplyr)
library(tidyverse)
library(readxl)
library(zipcodeR)

school_loans <- read_excel("FL_Dashboard_AY2009_2010_Q1.xls", skip = 5)
school_codes <- read_excel("ichi.xlsx")
us <- map_data("state")

schools <- full_join(school_codes, school_loans, by = c("SchoolName" = "School"))
schools <- full_join(schools, zip_code_db, by = c("ZipCode" = "zipcode")) %>%
  filter(StateCode != "HI" & StateCode != "AK" & StateCode != "PR" &
           `School Type` != "FOREIGN PRIVATE" & 
           `School Type` != "FOREIGN PUBLIC" & 
           `School Type` != "NA") %>%
  mutate(`School Type` = case_when(`School Type` == "PROPRIETARY" ~ "PRIVATE",
                                   TRUE ~ `School Type`),
         number_of_loans = `# of Loans Originated...7` +
           `# of Loans Originated...12` + `# of Loans Originated...17` +
           `# of Loans Originated...22`,
         loan_debt = `$ of Loans Originated...8` +
           `$ of Loans Originated...13` + `$ of Loans Originated...18` +
           `$ of Loans Originated...23`) %>%
  mutate(mean_debt = loan_debt / number_of_loans)

ggplot() +
  # US map
  geom_polygon(data = us, mapping = aes(long, lat, group = region), 
               fill = "grey", colour = "#ebebeb") +
  coord_map("mollweide") +
  # universities
  geom_point(data = schools, mapping = aes(lng, lat, shape = `School Type`,
                                           size = number_of_loans,
                                           colour = mean_debt)) +
  scale_size(range = c(0, 16)) +
  scale_color_gradient(low = "blue", high = "red", limits = c(2500, 7000)) +
  labs(title = "Federal Student Loans by University",
       size = "Number of Students Loaning",
       colour = "Mean Student Debt") +
  theme_minimal() +
  theme(axis.line = element_blank(),      # Remove axis lines
        axis.ticks = element_blank(),     # Remove tick marks
        axis.text.x = element_blank(),    # Remove x-axis labels
        axis.text.y = element_blank(),    # Remove y-axis labels
        axis.title.x = element_blank(),    # Remove x-axis title
        axis.title.y = element_blank(),    # Remove y-axis title
        panel.grid.minor = element_blank(),
        plot.title = element_text(size = 36),
        legend.title = element_text(size = 20),
        legend.text = element_text(size = 16))

