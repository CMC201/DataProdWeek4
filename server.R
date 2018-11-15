
library(shiny)
library(forecast)
library(lubridate)
library(plotly)
# Import our table of historical data
histdata<-read.csv('nycmonthlyclimate.csv')
# Clean up the data to give only needed quantities
smalldata<-subset(histdata,subset=!is.na(MonthlyMeanTemp),select=c(DATE,MonthlyMeanTemp,MonthlyDaysWithGT90Temp,MonthlyDaysWithLT32Temp))
# Convert the date column from factor to date
smalldata$DATE<-as_date(mdy_hm(as.character(smalldata$DATE)))
# Fill out the last 3 months so we have complete years to work with
next3df<-data.frame(as_date(c('2018-10-31','2018-11-30','2018-12-31')),c(64.1,46.6,35.0),c(0,0,0),c(0,0,9))
names(next3df)<-names(smalldata)
smalldata<-rbind(smalldata,next3df)
# Turn monthly data into time series
monthavg<-ts(smalldata$MonthlyMeanTemp,frequency=12)
monthhot<-ts(smalldata$MonthlyDaysWithGT90Temp,frequency=12)
monthcold<-ts(smalldata$MonthlyDaysWithLT32Temp,frequency=12)
# Fit a time-series model for each of our three necessary variables
avgmod<-auto.arima(monthavg)
hotmod<-auto.arima(monthhot)
coldmod<-auto.arima(monthcold)
# Use these models to predict each variable for the next 3 years
avgpred<-predict(avgmod,n.ahead=36)
hotpred<-predict(hotmod,n.ahead=36)
coldpred<-predict(coldmod,n.ahead=36)
# Create a vector of dates to fill with our predictions
startDate<-ymd('2019-01-31')
newdates<-startDate %m+% months(c(0:35))
# Attach the predictions to the historical data to create complete datasets
preddf<-data.frame(newdates,round(avgpred[['pred']],digits=2),round(hotpred[['pred']],digits=2),round(coldpred[['pred']],digits=2))
names(preddf)<-names(smalldata)
fulldata<-rbind(smalldata,preddf)
fulldata$year<-year(fulldata$DATE)
fulldata$month<-month(fulldata$DATE,label=TRUE)
# Define server logic required to draw three plots
shinyServer(function(input, output) {
   
  #Draw the average temperature by month plot
  output$avgPlot <- renderPlot({
    
    # select the appropriate data from input$year from ui.R
    yeardata<-subset(fulldata,year==input$year)
    
    # draw the barplot for the specified year
    barplot(yeardata$MonthlyMeanTemp, names.arg=yeardata$month, main = 'Average Monthly Temperature in Degrees F', xlab = 'Month', ylab = 'Temperature',ylim=c(0,85), col = 'Green', border = 'white')
    
  })
  
  #Draw the >90F days by month plot
  output$hotPlot <- renderPlot({
    
    # select the appropriate data from input$year from ui.R
    yeardata<-subset(fulldata,year==input$year)
    
    # draw the barplot for the specified year
    barplot(yeardata$MonthlyDaysWithGT90Temp, names.arg=yeardata$month, main = 'Number of days per month above 90F', xlab = 'Month', ylab = 'Number of Days',ylim=c(0,18), col = 'Red', border = 'white')
    
  })
  
  #Draw the <32F days by month plot
  output$coldPlot <- renderPlot({
    
    # select the appropriate data from input$year from ui.R
    yeardata<-subset(fulldata,year==input$year)
    
    # draw the barplot for the specified year
    barplot(yeardata$MonthlyDaysWithLT32Temp, names.arg=yeardata$month, main = 'Number of days per month below 32F high temperature', xlab = 'Month', ylab = 'Number of Days',ylim=c(0,18), col = 'Blue', border = 'white')
    
  })
  
})
