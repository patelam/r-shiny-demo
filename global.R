#Import Libraries
library(shinyjs) #For Shiny framework
library(DT) #For Datatables
library(leaflet) #For Map
library(sqldf) #For sql queries on the dataframe
library(plotly) #For charts
library(dplyr) #For basic operations on dataframe
library(plyr) #For basic operations on dataframe

#Read the data from csv
data <- read.csv("ecomm.csv")
cities <- read.csv("cities.csv")


#Clean the data

data<- na.omit(data)
data$InvoiceDate<- as.Date(data$InvoiceDate, format = "%m/%d/%Y")
data$UnitPrice <- data$UnitPrice*100
data<- data %>% filter(InvoiceDate >= '2011-01-01' & InvoiceDate <= '2011-06-30') %>%
                filter(UnitPrice >0 & UnitPrice <=1000) %>%
                filter(Quantity>0)
data$Description<- as.character(data$Description)
data$Country<- as.character(data$Country)

#Compute default values for UI

start_date <- min(data$InvoiceDate)
end_date <- max(data$InvoiceDate)
min_price <- min(data$UnitPrice)
max_price <- max(data$UnitPrice)
max_qty <- max(data$Quantity)
all_countries <- sort(unique(data$Country))



#Prepare the dataframe for the chart

week_df <- read.csv("date_week.csv")
week_df$Date<- as.Date(week_df$Date, format = "%Y-%m-%d")
data <- merge(x= data,y = week_df,by.x ='InvoiceDate',by.y = 'Date' , all.x=TRUE)
weekly_prices <- sqldf("select StockCode,Weeknumber,avg(UnitPrice) as WeeklyPrice, stdev(UnitPrice) as stdWeeklyPrice from data group by StockCode,Weeknumber")
data <- merge(data,weekly_prices,by=c("StockCode","Weeknumber"))
products <- count(data, 'StockCode')  %>% arrange(desc(freq)) %>% filter(freq > 100) %>% select(StockCode)
product_default <- products[1]
