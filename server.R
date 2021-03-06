library(shiny)

load("C02Worldwide.Rdata")
load("CanadianMeanTemp.Rdata")
load("CanadianAvgSnow.Rdata")
city_data = MeanTemp[order(as.character(MeanTemp$`InfoTemp[3]`),as.character(MeanTemp$`InfoTemp[2]`)),]
city_data <- replace(city_data, city_data=="-9999.9", NA)
city_data$City <- city_data$`InfoTemp[2]`

shinyServer(function(input, output, session) {
  
  # Update Year input,  and sync both input methods
  observeEvent(input$years,  {
    updateSliderInput(session, "year2", value = input$years)
  })
  
  observeEvent(input$year2,  {
    updateNumericInput(session, "years", value = input$year2)
  })
  
  # Update another Year input
  observeEvent(input$years2,  {
    updateSliderInput(session, "years1", value = input$years2)
  })
  
  observeEvent(input$years1,  {
    updateNumericInput(session, "years2", value = input$years1)
  })
  
  #=====================For Tab 2=====================#
  
  get_filtered_data <- reactive({
    city_data[city_data$`InfoTemp[3]` %in% input$province & 
                city_data$City %in% input$city, , drop = FALSE]
  })
  
  observe({
    updateSelectInput(session, "city",
                      choices = unique(city_data[city_data$`InfoTemp[3]` %in%
                                                   input$province, "City"]))
  })
  
  #######################################################
  #######################################################
   
  output$distPlot <- renderPlot({
    
    year = input$years
    year2 = input$years2
    
    # Vancouver snow
    AllSnow_van = AllSnow[5091:5129,]
    #Vancouver Mean Temp
    MeanTemp_van = MeanTemp[2593:2631,]
    
    Co2World_sub = Co2World[grep(c(year), Co2World$Year),]
    df_value = aggregate(Co2World_sub$Value ~ factor(Co2World_sub$Month), FUN=mean)
    df_Uncertainty = aggregate(Co2World_sub$Uncertainty ~ factor(Co2World_sub$Month), FUN=mean)
    AllSnow_van_sub = t(AllSnow_van[grep(c(year), AllSnow_van$Year),-c(1,14:21)])
    MeanTemp_van_sub = t(MeanTemp_van[grep(c(year), MeanTemp_van$Year),-c(1,14:21)])
    df_full = cbind(df_value, df_Uncertainty[2], AllSnow_van_sub, MeanTemp_van_sub)
    
    
    par(mar = c(5,5,2,5))
    plot.ts(df_full[2], type = "b", xlab = "Month", ylab = paste("CO2 in", year, "(ppm)"),
            main = paste("Worldwide CO2 Levels by Month in", year))
    
    if(input$extra){
      par(new = T)
      if(input$dataSource == "Uncertainty"){
        if(input$Adjust_axis){
          plot.ts(df_full[3], type = "l", axes = F, xlab = NA, ylab = NA, col = 2, ylim = c(0,0.6))
        }else{
          plot.ts(df_full[3], type = "l", axes = F, xlab = NA, ylab = NA, col = 2)
        }
        axis(side = 4)
        mtext(side = 4, line = 3, "Uncertainty")
        legend("bottomleft", c(paste("CO2 in", year, "(ppm)"), "Uncertainty"), lty=c(1,1), pch=c(1,NA), col = c(1,2))
      }
      else if(input$dataSource == "AllSnow"){
        plot.ts(df_full[4], type = "l", axes = F, xlab = NA, ylab = NA, col = 2)
        axis(side = 4)
        mtext(side = 4, line = 3, "Vancouver Ave.Snow")
        if(input$Adjust_axis){
          legend(7,max(df_full[4]), xpd = T, c("CO2 ppm", "Vancouver Ave.Snow"), lty=c(1,1), pch=c(1,NA), col = c(1,2))
        }else{
          legend("bottomleft", c(paste("CO2 in", year, "(ppm)"), "Vancouver Ave.Snow"), lty=c(1,1), pch=c(1,NA), col = c(1,2))
        }
      }
      else if(input$dataSource == "MeanTemp"){
        plot.ts(df_full[5], type = "l", axes = F, xlab = NA, ylab = NA, col = 2)
        axis(side = 4)
        mtext(side = 4, line = 3, "Vancouver Ave.Temp")
        if(input$Adjust_axis){
          legend(3,min(df_full[5])+2, xpd = T,  c("CO2 ppm", "Vancouver Ave.Temp"), lty=c(1,1), pch=c(1,NA), col = c(1,2))
        }else{
          legend("bottomleft", c(paste("CO2 in", year, "(ppm)"), "Vancouver Ave.Temp"), lty=c(1,1), pch=c(1,NA), col = c(1,2))
        }
      }
      else{
        Co2World_sub2 = Co2World[grep(c(year2), Co2World$Year),]
        df_value2 = aggregate(Co2World_sub2$Value ~ factor(Co2World_sub2$Month), FUN=mean)
        plot.ts(df_value2[2], type = "l", axes = F, xlab = NA, ylab = NA, col = 2)
        axis(side = 4)
        mtext(side = 4, line = 3, paste("CO2 in", year2, "(ppm)"))
        legend("bottomleft", c(paste("CO2 in", year, "(ppm)"), paste("CO2 in", year2, "(ppm)")), lty=c(1,1), pch=c(1,NA), col = c(1,2))
      }
    }
  })
  
  ###################END OF TAB 1###################
  
  output$distplot2 <- renderPlot({
    plot(Co2World$YearDecimal, Co2World$Value, type = "l",
         xlab = "Year", ylab = "Co2 (ppm)",
         main = "Worldwide CO2 Level")
    lines(supsmu(Co2World$YearDecimal, Co2World$Value), col = 2)
  })
  
  output$distplot3 <- renderPlot({
    my_data <- get_filtered_data()
    plot(my_data$Year, my_data$Annual, type = "l",
         xlab = "Year", ylab = "Temperature(C)",
         main = "Annual Temperature(C) in Selected City")
    lines(supsmu(my_data$Year, my_data$Annual), col = 2)
  })
  
})
