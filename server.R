

function(input, output) {

output$dateRangeText  <- renderText({
  paste("InvoiceDate Range is", paste(as.character(input$date_input), collapse = " to "))
})

output$qtySliderText  <- renderText({
  paste("Quantity Slider Value is",input$qty_slider)
})

output$priceSliderText  <- renderText({
  paste("Price Slider Range is", paste(as.character(input$price_slider), collapse = " to "))
})

output$countriesText  <- renderText({
  paste("Countries selected are", paste(as.character(input$countries), collapse = ", "))
})

output$textOutput  <- renderText({
  paste("Text: ",input$text_input)
})



# Filter the selections, returning a data frame
filtered_data <- reactive({
  
  st_date <- input$date_input[1]
  en_date <- input$date_input[2]
  countries <- input$countries
  qty <- input$qty_slider
  st_price <- input$price_slider[1]
  en_price <- input$price_slider[2]
  
  filtered_df <- data %>% filter(InvoiceDate >= st_date & InvoiceDate <= en_date) %>% 
                          filter(Quantity <=  qty)%>%
                          filter(UnitPrice  >= st_price & UnitPrice <= en_price)
  
  if(!(length(countries) == 1 & countries == 'All'))
    filtered_df <- filtered_df %>%filter(Country %in%  countries)
  
  filtered_df
})



output$filtered_datatable <- DT::renderDataTable({
  data <- filtered_data()
  DT::datatable(data, filter = 'top') #%>% formatRound(columns=c('UnitPrice'), digits=2)
})




output$map_thai <- renderLeaflet({
  map10 <- leaflet() %>%
    addTiles() %>%
    setView(lng = 101.30, lat = 14.47, zoom = 6) %>%
    addMarkers(~Longitude,~Latitude,layerId=~Id,data = cities)
  
  map10
})

observe({
  leafletProxy("map") %>% clearPopups()
  event <- input$map_marker_click
  if (is.null(event))
    return()
  
  isolate({
    showCityPopup(event$id, event$lat, event$lng)
  })
  
})

# Show a popup at the given location
showCityPopup <- function(id, lat, lng) {
  
  selectedCity <- cities[cities$Id == id,][1,]
  content <- as.character(tagList(
    tags$h4(selectedCity$City)
  ))
  
  leafletProxy("map") %>% addPopups(lng, lat, content, layerId = id)
}



output$plot_price <- renderPlotly({
  data <- filtered_data()
  product <- input$stockcode
  data <- data %>%  filter(StockCode==product)
  key <- row.names(data)
  data$AllDescription<- with(data, paste0('Description: ',Description,'\nStdWeeklyPrice: ',stdWeeklyPrice))
  
  p <- ggplot(data, aes_string(x="Weeknumber",y = "WeeklyPrice") ) +
    geom_point(aes(text = AllDescription, key=key)) + 
   # scale_y_continuous(name="Unit Price", limits=c(0, 400)) +
    geom_errorbar(mapping=aes(x=Weeknumber, ymin=WeeklyPrice - stdWeeklyPrice, ymax=WeeklyPrice + stdWeeklyPrice)) +
    labs(x = "Week", y = "Unit Price") +
    theme(axis.text.x = element_text(angle = 70, hjust = 1))+
    ggtitle(paste("Price variation across weeks for product - ",input$stockcode))
  
  ggplotly(p)  
})

output$click_table_plot <- DT::renderDataTable({
  d <- event_data("plotly_click")
  data <- filtered_data()
  product <- input$stockcode
  data <- data %>%  filter(StockCode==product)
  
  if (is.null(d))
  {
    output <- DT::datatable(data,filter = 'bottom') %>% formatRound(columns=c('WeeklyPrice'), digits=2)
  }
  else
  {

    row <-data[rownames(data) == d$key,]
    week <- row$Weeknumber
    wk <- data %>% filter(Weeknumber==week)
    output <- DT::datatable(wk,filter = 'bottom') %>% formatRound(columns=c('WeeklyPrice'), digits=2)
    
  }
  
  
  output
})



}