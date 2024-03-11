library(tidyverse)
library(readxl)
library(here)
library(skimr) 
library(kableExtra)
library(dplyr)
library(ggplot2)
library(lubridate)
library(scales) 

setwd('C:/Users/nicol/OneDrive/Augustana College/3 year/Spring term/DATA 332/Data')
course <- read_xlsx('Course.xlsx')
registration <- read_xlsx('Registration.xlsx')
student <- read_xlsx('Student.xlsx')

#left join the data of Student ID
merged_data <- left_join(registration, student, by = 'Student ID')

#chart on the number of majors
count_majors <- course %>%
              group_by(Title) %>%
              summarize(count_majors = n())

  #doing the chart
ggplot(data = count_majors, aes(x = Title, y = count_majors, fill = Title)) +
  geom_bar(stat = "identity") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(x = "Major", y = "Number of Students", title = "Number of Students per Major") +
  scale_fill_viridis_d() ##viridis color palette 

#chart on the birth year of the student

  ##first we create a column with the birth years
  student$BirthYear <- year(ymd(student$`Birth Date`))
  

  #Now we plot the number of students per birth year from the student dataframe
  ggplot(student, aes(x = as.factor(BirthYear))) +
    geom_bar(aes(fill = as.factor(BirthYear)), show.legend = FALSE) +
    theme(axis.text.x = element_text(angle = 75, hjust = 1)) +
    labs(x = "Birth Year", y = "Number of Students", title = "Number of Students by Birth Year")

  
#total cost per major by payment plan

  ##I am going to add the payment plan column in the course data
  ##'Instance ID' is the common key 
    course <- course %>%
      left_join(registration, by = 'Instance ID')
   
    ##seeing insights
    total_cost_per_major_and_plan <- course %>%
      group_by(Title, 'Payment Plan') %>%
      summarize(TotalCost = sum(Cost, na.rm = TRUE)) %>%
      ungroup() # Ungroup for further analysis or manipulation
    
    # Looking at the summarized data
    print(total_cost_per_major_and_plan)

    #plotting the insights of cost per major and plan
    
    ggplot(total_cost_per_major_and_plan, aes(x = Title, y = TotalCost, fill = 'Payment Plan')) +
      geom_bar(stat = "identity", position = "dodge") +
      scale_y_continuous(labels = scales::comma) + # This will format the y-axis labels with commas
      theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
      labs(x = "Major", y = "Total Cost", title = "Total Cost per Major Segmented by Payment Plan")
    
#Total balance due by major, segment by payment plan 

    total_balance_due_per_major_and_plan <- course %>%
      group_by(Title, `Payment Plan`) %>%
      summarize(TotalBalanceDue = sum(`Balance Due`, na.rm = TRUE)) %>%
      ungroup() # Ungroup for further analysis or manipulation
    
    # Print out the result to see it
    print(total_balance_due_per_major_and_plan)
    
    # And to plot:
    ggplot(total_balance_due_per_major_and_plan, aes(x = Title, y = TotalBalanceDue, fill = "Payment Plan")) +
      geom_bar(stat = "identity", position = "dodge") +
      scale_y_continuous(labels = scales::comma) + #This formats the y-axis labels with commas instead of the scientific way
      theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
      labs(x = "Major", y = "Total Balance Due", title = "Total Balance Due by Major Segmented by Payment Plan")
    
    
    