# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(readr)
library(plotly)
library(DT)



shinyUI(fluidPage(title = "Electric Energy Free of Fuels (ELC) Estimation Tool",
                  theme = "bootstrap.css",
                  tags$head(
                    tags$style(HTML(" .shiny-output-error-validation {color: red; }"))
                    ,   tags$style(HTML(" .shiny-notification-message {color: #007833;background-color: #e7f1d8; border-color: #007833;}"))
                    ,   tags$style(HTML(" table tbody tr:last-child {font-weight:bold;}")) 
                    ,   tags$style(HTML(id = "diagram", "table tbody tr:last-child {font-weight:bold;}"))
                  ), 
                  # titlePanel(h1("Electric Energy Free of Fuels Estimation Tool", style = "color:#007833")),
                  navbarPage(h3("ELC Estimation Tool", style = "color:#007833")
                       
                    # Guide Tab ----
                  ,  tabPanel(div(icon("book"), "Guide"),h3("Tool Guide")
                             # IMAGE HERE, tags$img(src='ToolScope.svg', style = "height: 300; width: 100%; max-width: 778.3079951422452px;")
                             , br()
                             , selectizeInput("lang", label = "",
                                              choices = c("English", "Español" ), multiple = FALSE,
                                              options = list(placeholder = 'English')) 
                             , hr()
                             , br()
                             #Disclaimer
                            ,  conditionalPanel(
                               condition = 'input.lang == "English"'
                             , strong('This tool has been developed by ORNL to provide CHP owners in Mexico an simple calculator to determine if their
                                      system qualifies as Efficient Cogeneration.  ORNL does not guarantee these results.'))
                             ,  conditionalPanel(
                               condition = 'input.lang == "Español"'
                               , strong('Esta herramienta ha sido desarrollada por ORNL para proporcionar a los propietarios de CHP en México 
                                        una calculadora simple para determinar si su sistema califica como Cogeneración Eficiente. 
                                        ORNL no garantiza estos resultados..'))
                             , br()
                             , hr()
                          #Download  
                          ,  conditionalPanel(
                              condition = 'input.lang == "English"'
                            , p(icon("book"),'   For help using or additional information about this tool,', span(strong( "download" )), 'the Tool Documentation. This includes the ORNL
                                 report on CHP Opportunities in Mexico' ) )
                          , conditionalPanel(
                              condition = 'input.lang == "Español"'
                              , p(icon("book"),'   Para ayuda con el uso o información adicional sobre esta herramienta,', span(strong( "descargar" )), 'la documentación de la herramienta. Esto incluye el ORNL
                                  informe sobre las oportunidades de CHP en México. (Disponible solo en Inglés)' ) )
                          , downloadButton('info', "Download/Descargar")
                          ,  conditionalPanel(
                            condition = 'input.lang == "English"'
                            , p("If you are unable to download the background zip file, try", span(strong("reloading")), "the application.",  
                                 span("Note: you will lose any information you have entered into the app.", style = "color:red")))
                            ,  conditionalPanel(
                              condition = 'input.lang == "Español"'
                              , p("Si no puede descargar el archivo zip de fondo, intente", span(strong("recargando")), "la aplicación.",  
                                  span("Nota: perderá la información que ingresó en la aplicación.", style = "color:red")))
                          , hr()    
                          #Warnings
                          ,  conditionalPanel(
                            condition = 'input.lang == "English"'
                             , p(icon("internet-explorer"),'   Some features of this tool are not fully supported in Internet Explorer.')
                             , p(icon("envelope-o"), '   If you wish to wish to comment on this tool, please contact 
                                 the developer by', span(strong(" email:")), 'Kristina Armstrong (', span('armstrongko@ornl.gov', style = "text-decoration: underline"),  
                                 ')')
                             , helpText(a("Or connect with us on GitHub", href = "https://github.com/koay9f/FRPC-Energy-Estimator", target= "_blank"))
                             , p(icon("save"),"When you exit the application, all data is lost.", style = "color: red")
                             , p(icon("times"),"Application will shut down after 5 minutes of inactivity (and data will be lost).", style = "color: red")
                             , p(icon("save"),"Data is not lost when moving between pages."))
                          ,  conditionalPanel(
                            condition = 'input.lang == "Español"'
                            , p(icon("internet-explorer"),'   Algunas características de esta herramienta no son totalmente compatibles con Internet Explorer.')
                            , p(icon("envelope-o"), '   Si desea comentar esta herramienta, contáctese con
                                el desarrollador por', span(strong(" email:")), 'Kristina Armstrong (', span('armstrongko@ornl.gov', style = "text-decoration: underline"),  
                                ')')
                            , helpText(a("O conéctese con nosotros en GitHub", href = "https://github.com/koay9f/FRPC-Energy-Estimator", target= "_blank"))
                            , p(icon("save"),"Cuando sale de la aplicación, todos los datos se pierden.", style = "color: red")
                            , p(icon("times"),"La aplicación se cerrará después de 5 minutos de inactividad (y se perderán los datos).", style = "color: red")
                            , p(icon("save"),"Los datos no se pierden cuando se mueve entre las páginas."))
                          
                          
                             # , p(icon("download"),'To save your session, download the "Input" files from the', strong('Download Page'), ' at the end of your session.')
                             # , p(icon("upload"), 'In later sessions, you can upload this on the', strong(' Upload Page'), ', and the forms will autopopulate.')
                             
                             ),
                    
                    # Initial Tab ----   
                    tabPanel(div(icon("edit"), "Calculator"), h3("Calculator")
                             , fluidRow(
                               column(6
                                      , h4("Inputs")
                                      , wellPanel(
                                          selectizeInput("totalCap", label = "Capacity",
                                                         choices = NULL, multiple = FALSE,
                                                         options = list(placeholder = 'Choose System Capacity'))  
                                          , selectizeInput("altitude", label = "Is facility altitude greater than 1500m?",
                                                           choices = c("No", "Yes" ), multiple = FALSE,
                                                           selected = "No")
                                          , selectizeInput("voltage", label = "System Voltage",
                                                           choices = NULL, multiple = FALSE)
                                          , selectizeInput("type", label = "System Heat Medium",
                                                           choices = c("Steam/Hot Water", "Direct use of combustion gases" ), multiple = FALSE,
                                                           options = list(placeholder = 'Choose Medium'))
                                          , numericInput("Input_E","Net Annual Electricity Generated, E (MWh)", 1,  min = 0,NA,NA)
                                          , numericInput("Input_F","Energy of Fossil Fuels, F (MWh)", 1,  min = 0,NA,NA)
                                          , numericInput("Input_H","Net useful heat generated and used, H (MWh)", 1,  min = 0,NA,NA)
                                          )
                                      
                                      
                               )
                               , column(6
                                        , h4("Results")
                                        , wellPanel(
                                          
                                        conditionalPanel(
                                            condition = 'input.lang == "English"'  
                                        , fluidRow(column (6,strong("AEP:")),column(6,textOutput("AEPEn"), align = "right"))
                                        , fluidRow(column (6,strong("ELC:")),column(6,textOutput("ELCEn"), align = "right"))
                                        , fluidRow(column (6,strong("Does this qualify?")),column(6,textOutput("qualEn"), align = "right")) 
                                        , fluidRow(column (6,strong("RefE")),column(6,textOutput("RefEEn"), align = "right"))
                                        , fluidRow(column (6,strong("RefH")),column(6,textOutput("RefHEn"), align = "right"))
                                        , fluidRow(column (6,strong("fp")),column(6,textOutput("ReffpEn"), align = "right"))
                                        
                                        
                                          )
                                          ,  conditionalPanel(
                                            condition = 'input.lang == "Español"'
                                        , fluidRow(column (6,strong("AEP:")),column(6,textOutput("AEPEs"), align = "right"))
                                        , fluidRow(column (6,strong("ELC:")),column(6,textOutput("ELCEs"), align = "right"))
                                        , fluidRow(column (6,strong("¿Esto califica?")),column(6,textOutput("qualEs"), align = "right"))  
                                        , fluidRow(column (6,strong("RefE")),column(6,textOutput("RefEEs"), align = "right"))
                                        , fluidRow(column (6,strong("RefH")),column(6,textOutput("RefHEs"), align = "right"))
                                        , fluidRow(column (6,strong("fp")),column(6,textOutput("ReffpEs"), align = "right"))  )
                             ))))
                    #End ----
                   
                    )))

