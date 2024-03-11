library(tidyverse)
library(readxl)
library(here)
library(skimr) 
library(kableExtra)
library(dplyr)
library(ggplot2)
library(tidyverse)
library(lubridate)
library(scales)
library(forcats)

setwd('C:/Users/nicol/OneDrive/Augustana College/3 year/Spring term/DATA 332/Data')
billing <- read_xlsx('Billing.xlsx')
patient <- read_xlsx('Patient.xlsx')
visit <- read_xlsx('Visit.xlsx')

#Discover insights into the data such as reason for visit segmented (stacked bar chart)by month of the year. 
  #Add the Month column to the visits dataframe 
  visit$Month <- month(ymd(visit$VisitDate), label = TRUE)

  #function to extract the first word from the reason
  extract_first_word <- function(reason) {
    # Extract the first word
    word_list <- str_split(reason, " ")[[1]]
    return(word_list[1])
  }
  #order of months
  visit$Month <- factor(format(as.Date(visit$VisitDate), "%b"), 
                         levels = c("Jan", "Feb", "Mar", "Apr", "May", "Jun", 
                                    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"))
  
  # stacked bar chart
  ggplot(visit, aes(x = Month, fill = AggregatedReason)) +
    geom_bar(position = "fill") +
    scale_y_continuous(labels = percent_format()) +
    labs(x = "Month", y = "Proportion of Visits", 
         title = "Proportion of Visit Reasons by Month") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
  
  
#Reason for visit based on walk in or not. 
  
  # Ensure 'Month' is ordered properly if it's not already
  visits$Month <- factor(visits$Month, levels = c("Jan", "Feb", "Mar", "Apr", "May", "Jun", 
                                                  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"))
  
  # Plot the reason for visit based on walk-in status
  ggplot(visit, aes(x = fct_inorder(AggregatedReason), fill = as.factor(WalkIn))) +
    geom_bar(position = "dodge") +
    labs(x = "Reason for Visit", y = "Count", 
         title = "Reason for Visit Based on Walk-In Status") +
    scale_fill_brewer(palette = "Set1", name = "Walk-In Status") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 75, hjust = 1), 
          legend.position = "bottom")
  
  
#Reason for visit based on City/State or zip code
  
  #Join the dataframes on the 'PatientID' column
  visit_joined <- visit %>%
    left_join(patient, by = "PatientID")
  
  #group by 'City', 'State', or 'Zip' to analyze the reason for visit
  #I am grouping it by city as they are all from GA
  reason_by_city <- visit_joined %>%
    group_by(City, Reason) %>%
    summarize(VisitCount = n(), .groups = 'drop')

#Total invoice amount based on reason for visit. Segmented (stacked bar chart) with it was paid. 
  #Joining the dataframes
  total_invoice_joined <- visit %>%
    left_join(billing, by = "VisitID")
  
  #I am grouping it by invoice amount 
  reason_by_total_invoice <- total_invoice_joined %>%
    group_by(InvoiceAmt, Reason) %>%
    summarize(VisitCount = n(), .groups = 'drop')
  
  #Apply the function to create a new 'AggregatedReason' column
  reason_by_total_invoice <- reason_by_total_invoice %>%
    mutate(AggregatedReason = sapply(Reason, extract_first_word))
  
  #grouping and plotting
  visit_reason_by_total_invoice <- reason_by_total_invoice %>%
    group_by(InvoiceAmt, AggregatedReason) %>%
    summarize(TotalVisitCount = sum(VisitCount), .groups = "drop")
  
  #stacked chart
  ggplot(visit_reason_by_total_invoice, aes(x = as.factor(InvoiceAmt), y = TotalVisitCount, fill = AggregatedReason)) +
    geom_bar(stat = "identity", position = "stack") +
    labs(x = "Invoice Amount", y = "Total Visit Count", title = "Visit Counts by Invoice Amount, Aggregated by Reason") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 75, hjust = 1))  
  

#And student is to find one insight into the data that they find interesting. In a chart.

  average_invoice_by_reason <- visit_reason_by_total_invoice %>%
    group_by(AggregatedReason) %>%
    summarize(AverageInvoiceAmt = mean(InvoiceAmt * TotalVisitCount / sum(TotalVisitCount), na.rm = TRUE), .groups = "drop") %>%
    arrange(desc(AverageInvoiceAmt))  #Arrange by descending order of average invoice amount
  
  #Plot of the average invoice amount by reason
  ggplot(average_invoice_by_reason, aes(x = reorder(AggregatedReason, AverageInvoiceAmt), y = AverageInvoiceAmt, fill = AggregatedReason)) +
    geom_col() +
    labs(x = "Aggregated Reason", y = "Average Invoice Amount ($)", title = "Average Invoice Amount by Visit Reason") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    scale_fill_viridis_d(begin = 0.3, direction = -1) 
  
    
