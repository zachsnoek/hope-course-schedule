#----------------------------------------------------------------------
# libraries
#----------------------------------------------------------------------
install.packages("data.table")
install.packages("tidyverse")
install.packages("ggplot2")
install.packages("RColorBrewer")

library(RColorBrewer)
library(data.table)
library(tidyverse)
library(ggplot2)

#----------------------------------------------------------------------
# read data
#----------------------------------------------------------------------

# put your absolute path here
setwd("/Users/zacharysnoek/Programming/java/hope-course-schedule")

main <- fread("FA10-SP19.csv")
main <- as.tibble(main)

#----------------------------------------------------------------------
#----------------------------------------------------------------------
# the dirty work...fix the stupid credits column, and make a date column
#----------------------------------------------------------------------
#----------------------------------------------------------------------


#----------------------------------------------------------------------
#replace some strings in the course titles
#----------------------------------------------------------------------

#the space before and is important
main$Title <- gsub("\\<and\\>", "&", main$Title)
main$Title <- gsub("\\<mus\\>", "Music", main$Title)

main$Title <- gsub("\\<Mus\\>", "Music", main$Title)
# main$Title <- gsub("Mus", "Music", main$Title)
main$Title <- gsub("\\<Ensmble\\>", "Ensemble", main$Title)

sort(unique(main$Title))

#row indices of where these groups are. Going to 
# replace their titles with something to combine the various
# groups under one common name
jce <- which(grepl("Jazz Chamber Ensemble", main$Title))
fme <- which(grepl("Folk", main$Title))

#change these rows to just say these titles
main$Title[jce] <- "Jazz Chamber Ensembles"
main$Title[fme] <- "Folk Music Ensembles"

#----------------------------------------------------------------------
#Make a column with an actual Date column, with a Data type
#----------------------------------------------------------------------
yr <- rep(c(10:19), each = 2, length.out = 19)
sm <- rep(c("SP", "FA"), each = 1, length.out = 19)

Year <- paste0(yr, sm)

#Year and year are not the same...yeah, I should use a different name probably
year <- rep(c(2010:2019), each = 2, length.out = 19)
month <- rep(c("01", "08"), each = 1, length.out = 19)
day <- rep("01", each = 1, length.out = 19)
Date <- paste(year, month, day, sep = "-")
Date <- as.Date(Date)
d <- tibble(Year, Date)
# d

main <- left_join(main, d, by = "Year")
# main

#----------------------------------------------------------------------
#----------------------------------------------------------------------
#----------------------------------------------------------------------
# run this if you want to filter out 2019
#----------------------------------------------------------------------
#----------------------------------------------------------------------
#----------------------------------------------------------------------
main <- filter(main, Date < as.Date("2019-01-01"))

#----------------------------------------------------------------------
#fix the # of credits. If it's a single number, just convert it to numeric
# If it's 2/3 or some shit, convert it to the average of those two numbers
#----------------------------------------------------------------------
credit_fix <- function(s) {
 
   result = tryCatch({
    as.numeric(s)
  }, warning = function(w) {
    
    s <- gsub("[-/]", "", s)
    
    #put all the numbers in a vector
    nums <- c()
    
    for (i in 1:nchar(s)) {
      n <- substr(s, i, i)
      nums <- append(nums, as.numeric(n))
    }
    
    #return the average
    mean(nums)
  })
  as.numeric(result)
}


# I can't figure out another way so I'm looping, damnnit
for(i in 1:nrow(main)) {
  main$Credits[i] <- credit_fix(main$Credits[i])
}

# have to manually convert to numeric, even though my function does it
# You have to convert a whole column's type at once, you can't convert
# each elements type in a loop
main <- mutate(main, Credits = as.numeric(Credits))

#----------------------------------------------------------------------
#sanity check...hooray, Credits is a double
#----------------------------------------------------------------------
main

#----------------------------------------------------------------------
#another sanity check
#----------------------------------------------------------------------
sort(unique(main$Instructor))

#----------------------------------------------------------------------
#----------------------------------------------------------------------
# now the fun stuff
#----------------------------------------------------------------------
#----------------------------------------------------------------------

#a useful thing you can do
# filter(main, Instructor == "Talaga Stephen C.")

#----------------------------------------------------------------------
#totals per class, per professor, per year
#----------------------------------------------------------------------
agg <- 
  main %>%
  group_by(Instructor, Title, Date) %>% 
  summarise(Students = sum(Actual))
agg

#----------------------------------------------------------------------
#ensemble dataframe
#----------------------------------------------------------------------

#folk groups taught by Roberts
robertsfolk <-
  main %>% 
  filter(Instructor == "Roberts Nathaniel J.") %>% 
  filter(Title == "Folk Music Ensembles")

womenschamber <-
  main %>% 
  filter(Title == "Women's Chamber Choir")

ensdf <- main
ensdf <- ensdf[-which(grepl("Women's Chamber Choir", ensdf$Title)), ]
ensdf$Title[grepl("Chamber", ensdf$Title)] <- "Chamber Groups"
ensdf$Title[grepl("Woodwind Quintet", ensdf$Title)] <- "Woodwind Quintets"
ensdf$Title[grepl("WoodWind Quintet", ensdf$Title)] <- "Woodwind Quintets"

ensembles <- c("Orchestra",
               "Chapel Choir",
               "Wind Ensemble",
               "Chamber Groups",
               "Saxophone Quartet",
               "Woodwind Quintets")

ensdf <- 
  ensdf %>% 
  filter(Title %in% ensembles) %>% 
  full_join(robertsfolk, .) %>% 
  full_join(womenschamber, .) %>% 
  mutate(`Credit/No Credit` = ifelse(Credits > 0, "Credit", "No Credit")) %>% 
  group_by(Date, Title, `Credit/No Credit`) %>% 
  summarise(Students = sum(Actual))
ensdf

#----------------------------------------------------------------------
# filter to who is interesting
# haven't used this for anything so far
#----------------------------------------------------------------------
keeps <- c("Coyle Brian R.", 
           "Roberts Nathaniel J.",
           "Briggs John A.", 
           "Beaulieu Genevieve L.")

#df of who is interesting/been fired
fired <- 
  agg %>% 
  filter(., Instructor %in% keeps)
fired

#######################################################################
#######################################################################
#######################################################################
#
# run to here before graphing stuff
#
#######################################################################
#######################################################################
#######################################################################

# save to correct directory
setwd("/Users/zacharysnoek/Programming/java/hope-course-schedule/plots")

#----------------------------------------------------------------------
#function to plot courses

#to change how the image is saved, as additional function paramters, you can pass
# width =, height =,  choose one of: units = c("in", "cm", "mm"), dpi = 

# see the help for ggsave, anything you want to pass to that function you can 
#pass to courseplot and it'll pass those on to ggsave

#----------------------------------------------------------------------
courseplot <- function(course, totalstudents = FALSE, ...) {
  e <- filter(ensdf, Title == course)
  
  if(totalstudents == TRUE) {
    e <- 
      e %>% 
      summarise(`Total Students` = sum(Students))
    
    ggplot(e, aes(x = Date, y = `Total Students`)) +
      geom_line(size = 2, color = "orange") +
      geom_point(size = 3, color = "orange") +
      ggtitle(course, "Count of Students, per Semester") +
      theme(legend.title = element_blank()) +
      scale_color_brewer(palette = "Dark2")  
    fname <- paste(course, "_total_students.png")
  } else {
    ggplot(e, aes(x = Date, y = Students, group = `Credit/No Credit`)) +
      geom_line(aes(color = `Credit/No Credit`), size = 2) +
      geom_point(aes(color = `Credit/No Credit`), size = 3) +
      ggtitle(course, "Count of Students taking for Credit/No Credit, per Semester") +
      theme(legend.title = element_blank()) +
      scale_color_brewer(palette = "Dark2")  
    fname <- paste0(course, ".png")
  }
  
  ggsave(filename = fname,
         plot = last_plot(),
         dpi = 300, ...)
}

courseplot("Folk Music Ensembles", totalstudents = TRUE)

courseplot("Folk Music Ensembles", totalstudents = FALSE)
courseplot("Chamber Groups", totalstudents = TRUE)
courseplot("Chamber Groups", totalstudents = FALSE)
courseplot("Saxophone Quartet")
courseplot("Chapel Choir")
courseplot("Wind Ensemble")
courseplot("Orchestra")
courseplot("Woodwind Quintets")
courseplot("Women's Chamber Choir")
courseplot("Women's Chamber Choir", totalstudents = TRUE)

#----------------------------------------------------------------------
#function to plot that for a particular prof
# get profs with sort(unique(main$Instructor))
#----------------------------------------------------------------------
profplot <- function(prof, ...) {
  
  #all classes taught by this prof over all semesters
  p <- filter(agg, Instructor == prof)

  #filter out classes they only taught once
  taught_once <-
    p %>% 
    summarise(times = n()) %>% 
    filter(times > 1)
  
  p <- filter(p, Title %in% taught_once$Title)
    
  #number of unique class titles they have taught
  classes_taught <- length(unique(p$Title))
  
  #If they've taught more than  classes, filter out the 
  #small ones (anything less than 4 students)
  if(classes_taught > 8) {
    large_classes <- 
      p %>% 
      summarise(mean = mean(Students)) %>% 
      filter(mean >= 4)
    
    p <-
      p %>% 
      filter(Title %in% large_classes$Title)
  }
  
  ggplot(p, aes(x = Date, y = Students, group = Title)) +
    geom_line(aes(color = Title), size = 2) +
    geom_point(aes(color = Title), size = 3) +
    ggtitle(prof, "Count of Students per Course, per Semester") +
    scale_color_brewer(palette = "Dark2")
  
  ggsave(filename = paste0(prof, ".png"),
         plot = last_plot(),
         dpi = 300,
         ...)
  
}

#usage
profplot("Roberts Nathaniel J.")
profplot("Briggs John A.")
profplot("Coyle Brian R.")
profplot("Beaulieu Genevieve L.")

#----------------------------------------------------------------------
#plot all the fired ones. Works but it's messy since there's so many
#classes and the lines are hard to distinguish
#----------------------------------------------------------------------
ggplot(fired, aes(x = Date, y = Students, group = Title)) +
  geom_line(aes(color = Title)) +
  facet_wrap(~Instructor)
  
#----------------------------------------------------------------------
#----------------------------------------------------------------------
# Plots for the 8 ensembles
# stacked bar chart
#----------------------------------------------------------------------
#----------------------------------------------------------------------

# the sexy AF plot of Students enrolled for credit/no credit
ggplot(ensdf) +
  geom_bar(aes(x = `Credit/No Credit`, y = Students, fill = Title),
           stat = "identity",
           position = "stack",
           size = 1.5) +
  facet_wrap(~Date, nrow = 1) +
  theme(panel.spacing = unit(.75, "lines"),
        axis.text.x = element_text(angle = 45, hjust = 1),
        axis.title.x = element_blank()) +
  scale_fill_brewer(palette = "Dark2") +
  ggtitle("Students Enrolled for Credit/No Credit", subtitle = "per Semester in Selected Ensembles")

ggsave(plot = last_plot(),
       filename = "enrollment_selected_ensembles_bar.png",
       dpi = 800,
       width = 18)

# Line graph of the 8 ensembles
ensemble_totals <- 
  ensdf %>% 
  summarise(`Total Students` = sum(Students))

ggplot(ensemble_totals, aes(x = Date, y = `Total Students`, group = Title)) +
  geom_line(aes(color = Title), size = 2) +
  geom_point(aes(color = Title), size = 3) +
  ggtitle("Total Students Enrolled", subtitle = "In Selected Ensembles, per Semester") +
  theme(legend.title = element_blank()) +
  scale_color_brewer(palette = "Dark2")  

ggsave(plot = last_plot(),
       filename = "enrollment_selected_ensembles_line.png",
       dpi = 500)

#----------------------------------------------------------------------
#----------------------------------------------------------------------
# Theory and Aural Skills things
#----------------------------------------------------------------------
#----------------------------------------------------------------------

theory <- c("Theory I",
            "Theory II",
            "Theory III",
            "Theory IV")

hodson_theory <- 
  main %>% 
  filter(Title %in% theory) %>% 
  filter(Instructor == "Hodson Robert D.")

krause_theory <- 
  main %>% 
  filter(Title %in% theory) %>% 
  filter(Instructor == "Krause Ben A.")

thry <- full_join(hodson_theory, krause_theory) %>% 
  group_by(Instructor, Title, Date) %>% 
  summarise(Students = sum(Actual))

aural <- c("Aural Skills I",
           "Aural Skills II",
           "Aural Skills III",
           "Aural Skills IV")

wolfe_aur <- 
  main %>%  
  filter(Title %in% aural) %>% 
  filter(Instructor == "Wolfe Jennifer A.") %>% 
  filter(Date <= as.Date("2018-01-01"))

west_aur <- 
  main %>%  
  filter(Title %in% aural) %>% 
  filter(Instructor == "West Elizabeth O.") %>% 
  filter(Date > as.Date("2018-01-01"))

aur <- full_join(wolfe_aur, west_aur) %>% 
  group_by(Instructor, Title, Date) %>% 
  summarise(Students = sum(Actual))

#----------------------------------------------------------------------
# time to plot them
#----------------------------------------------------------------------

#aural skills
ggplot(aur, aes(x = Date, y = Students, group = Title)) +
  geom_line(aes(color = Title), size = 2) +
  geom_point(aes(color = Title), size = 4.5) +
  # geom_point(aes(color = Title, shape = Instructor), size = 4.5) +
  ggtitle("Count of Students in Aural Skills", subtitle = "per Semester") +
  scale_color_brewer(palette = "Dark2")

ggsave(filename = "aural_skills.png",
       plot = last_plot(),
       dpi = 400)

#theory
ggplot(thry, aes(x = Date, y = Students, group = Title)) +
  geom_line(aes(color = Title), size = 2) +
  # geom_point(aes(color = Title, shape = Instructor), size = 4.5) +
  geom_point(aes(color = Title), size = 4.5) +
  ggtitle("Count of Students in Theory", subtitle = "per Semester") +
  scale_color_brewer(palette = "Dark2")

ggsave(filename = "theory.png",
       plot = last_plot(),
       dpi = 400)

