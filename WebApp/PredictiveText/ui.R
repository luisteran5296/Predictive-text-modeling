#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
    title ="Predictive Text",
    br(),
    # Application title
    titlePanel(
        h1("Predictive text model", align = "center"),
    ),
    br(),
    br(),
    br(),
    
    fluidRow(
        column(4,
               div(style = "height:500px;width:100%;background-color: #999999;",
               )),
        column(4, align="center", 
               br(),
               br(),
               br(),
               tags$head(
                   tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
               ),
               tags$div(
                   h4("Enter your text here", align="center", ),
                   tags$textarea(id = 'text', placeholder = 'Type here', rows = 3, class='form-control',""),
                   HTML('<script type="text/javascript"> 
                            document.getElementById("text").focus();
                        </script>'),
                   br(),
                   HTML("<div id='buttons' align='center'>"),
                   uiOutput("pred1",inline = T),
                   uiOutput("pred2",inline = T),
                   uiOutput("pred3",inline = T)),
                   br(),
                   br(),
                   p("Predictive texting is a data processed tool that makes it quicker and easier to write
                   text by suggesting words as you type. Because the user simply taps on a word instead 
                     of typing it out on the keyboard, predictive text can significantly speed up the 
                     input process.", align = "justify"),
                   p("The tool will read the text inside the text input area and predict the three most 
                     suitable options. After the prediction is made, the options are displayed as buttons. 
                     The user can press the button to insert text, the tool is intended to simulate text word 
                     predictor in smartphones. This three word prediction is made for every change in the input 
                     area.", align = "justify"),
                   br(),
                   p("Luis Terán", align = "center"),
                   HTML("</div>"),align="center"),
        
        column(4,
               div(style = "height:500px;width:100%;background-color: #999999;",
               )),
        
    ),
))






