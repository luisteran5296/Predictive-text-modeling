
library(shiny)
options(shiny.maxRequestSize = 60*1024^2)

# List of all the models
modelsList = readRDS("./data/model.rds")
isReady <- T

# Define server logic required to generate and plot a random distribution
shinyServer(function(input, output, session) {
    
    onlyLetters <- function(x)
        gsub("[^A-Za-z///' ]","" , x ,ignore.case = TRUE)
    
    predictNextWord <- function(testline,modelsList){
        ngramModelsCount = length(modelsList)
        
        line <- iconv(testline,"latin1","ASCII",sub="")
        line <- onlyLetters(tolower(line))
        
        listWords <- unlist(strsplit(line, split=" "));
        wordCount <- length(listWords);
        
        i<-0
        results<-NULL
        
        for (model in modelsList[1:(ngramModelsCount-1)]){
            i <- i+1
            nmodel <- ngramModelsCount + 1 - i 
            if((wordCount+1) >= nmodel){
                cutIndex <- wordCount - nmodel + 2
                input<-paste(listWords[cutIndex:wordCount],
                             collapse = " ")
                options<-model[grep(paste0("^",input," "), model$token)[1:3],1]
                options<-as.vector(options)
                options <- gsub(paste0("^",input," "),"" , options ,
                                ignore.case = TRUE)
                results<-c(results, options)
            }
        }
        
        results <- unique(results[!is.na(results)])
        
        if(length(results)<3){
            results <- as.vector(head(modelsList[[length(modelsList)]]$token,3))
        } else {
            results<- results[1:3]
        }
        
        results
        
        
    }
    
    observe({
        
        text <- reactive({input$text})
        
        predictions <- predictNextWord(text(),modelsList)
        opt1 <<- predictions[1]
        opt2 <<- predictions[2]
        opt3 <<- predictions[3]
        
        output$pred1 <- renderUI({
            actionButton("button1", label = opt1)
        })
        
        
        output$pred2 <- renderUI({
            actionButton("button2", label = opt2)
            
        })
        
        
        
        output$pred3 <- renderUI({
            actionButton("button3", label = opt3)
            
        })
        
        
    })
    
    observeEvent(input$button1, {
        if(input$button1 == 1){
            name <- paste(input$text, opt1)
            updateTextInput(session, "text", value=name)
        }

    })

    observeEvent(input$button2, {
        name <- paste(input$text, opt2)
        updateTextInput(session, "text", value=name)
    })

    observeEvent(input$button3, {
        name <- paste(input$text, opt3)
        updateTextInput(session, "text", value=name)
    })

    
    
})