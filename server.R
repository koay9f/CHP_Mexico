
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(readr)
library(plotly)
library(tidyverse)

Ref_Vals_RefE = read_csv("data/RefE.csv")
Ref_Vals_fp = read_csv("data/fp.csv")

caplist <- unique(Ref_Vals_RefE$Capacity_range)
voltlist <- unique(Ref_Vals_fp$Voltage_range)

source("other.R", local = TRUE) 


shinyServer(function(input, output, session) {
# Build complex lists
  observe({
    updateSelectizeInput(session, 'totalCap',
                         choices = caplist,
                         server = TRUE           
    )
    
    updateSelectizeInput(session, 'voltage',
                         choices = voltlist,
                         options = list(placeholder = 'Choose System Voltage'), 
                         server = TRUE 
    )
    # BUG not using placeholder
  })




  #Outputs ----
  refE_val <- reactive(as.double(RefE(input$totalCap, input$altitude)))
  refH_val <- reactive(as.double(RefH(input$type)))
  reffp_val <- reactive(as.double(fp(input$voltage)))
  AEP_val <- reactive(as.double(AEP_fxn(input$Input_E,refE_val(),reffp_val(),input$Input_H,refH_val(),input$Input_F)))
  ELC_val <- reactive(as.double(ELC_fxn(input$Input_E,refE_val(),reffp_val(),input$Input_H,refH_val(),input$Input_F)))
  qual_val <- reactive (as.character(qual_fxn(input$lang, ELC_val())))

  
  output$AEPEs <- output$AEPEn <- renderText({AEP_val()})   
  
  output$ELCEs <- output$ELCEn <- renderText({ELC_val()})
  
  output$RefEEs <- output$RefEEn <- renderText({refE_val()})
    
  output$RefHEs <- output$RefHEn <- renderText({refH_val()})
  
  output$ReffpEs <- output$ReffpEn <- renderText({reffp_val()})
  
  output$qualEs <- output$qualEn <- renderText({
    validate (need(AEP_val() , translate("Need Input", "Necesita Entrada", input$lang)) )
    ({qual_val()})})


  #Translations ----
  observeEvent(input$lang, {
    
    capplace <- translate('Choose System Capacity', 'Elija la capacidad del sistema', input$lang)
    voltplace <-translate('Choose System Voltage', 'Elija Voltaje del sistema', input$lang)
    typeplace <-translate('Choose Heating Medium', 'Elija Calefacción Medio', input$lang)

  updateSelectizeInput(session, 'totalCap',
                  label = (translate("Capacity", "Capacidad", input$lang)),
                  choices = caplist,
                  options = list(placeholder = capplace),
                  server = TRUE
                  )

     updateSelectizeInput(session, 'altitude',
                    label = (translate("Is facility altitude greater than 1500m?", "¿La altura de las instalaciones es superior a 1500 m?",
                                       input$lang)),
                    choices = c( "No", translate("Yes", "Si", input$lang)),
                    selected = "No",
                    server = TRUE)

    updateSelectizeInput(session, 'voltage',
                    label = (translate("System Voltage", "Voltaje del Sistema", input$lang)),
                    choices = voltlist,
                    options = list(placeholder = voltplace),
                    server = TRUE
                    )

    updateSelectizeInput(session, 'type',
                    label = (translate("System Heat Medium", "Sistema de calor medio", input$lang)),
                    choices = c(translate("Steam/Hot Water", "Steam / agua caliente", input$lang)
                                , translate("Direct use of combustion gases", "Uso directo de los gases de combustión" , input$lang )),
                    options = list(placeholder = typeplace),
                    server = TRUE
                    )

    updateNumericInput(session, 'Input_E',
                    label = (translate("Net Annual Electricity Generated, E (MWh)", "Energía Eléctrica Neta Generada, E (MWh)", input$lang)))

    updateNumericInput(session, 'Input_F',
                    label = (translate("Energy of Fossil Fuels, F (MWh)", "Energía de los Combustibles Fósiles Empleados, F (MWh)", input$lang)))

    updateNumericInput(session, 'Input_H',
                    label = (translate("Net useful heat generated and used, H (MWh)", "Energía térmica Neta o el Calor Útil Generado, H (MWh)", input$lang)))




  })






#
  #End ----
})