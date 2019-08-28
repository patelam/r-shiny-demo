
fluidPage(
  
  titlePanel("R Shiny Demo"),
  
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    
    # Sidebar panel for inputs ----
    sidebarPanel(width=4,
                 dateRangeInput(inputId = "date_input", label = "Invoice Date range:",
                                start = start_date,
                                end   = end_date,
                                min = start_date,
                                max = end_date),
                 sliderInput(inputId = "qty_slider", label = "Quantity", min = 1, 
                             max = max_qty, value = max_qty),
                 sliderInput(inputId = "price_slider", label = "Unit Price", min = min_price, 
                             max = max_price, value = c(min_price, max_price)),
                  selectInput(inputId = "countries", label = "Select Country", 
                              choices = c('All', all_countries), 
                              selected = 'All',multiple = TRUE),
                  textInput(inputId = "text_input", label = "Text input",value = ""),
                 br(),
                 br(),
                 br(),
                 selectInput(inputId = "stockcode",label= "Products", choices = products, selected = product_default)
    
                 
    ),
    
    # Main panel for displaying outputs ----
    mainPanel(
      
      tabsetPanel(type = "tabs",id="plots",
                  tabPanel(title = "Widgets",br(),verbatimTextOutput(outputId = "dateRangeText"),verbatimTextOutput(outputId="qtySliderText"),
                           verbatimTextOutput(outputId="priceSliderText"),verbatimTextOutput(outputId="countriesText"),verbatimTextOutput(outputId="textOutput")),
                  
                  tabPanel(title = "Data Table",br(), DT::dataTableOutput(outputId="filtered_datatable")),
                  
                  tabPanel(title = "Map",br(),  leafletOutput(outputId="map_thai", width="100%", height="700")),
                  
                  tabPanel(title = "Price by Week", plotlyOutput(outputId="plot_price", height = 700, width = 'auto'),DT::dataTableOutput(outputId="click_table_plot"))
                  
      )
      
    )
  )
)
