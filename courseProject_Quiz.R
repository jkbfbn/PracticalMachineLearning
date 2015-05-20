library(caret)
library(gridExtra)
library(RCurl)

# Get the data
data <- read.csv("https://d396qusza40orc.cloudfront.net/predmachlearn/pml-training.csv")
quiz <- read.csv("https://d396qusza40orc.cloudfront.net/predmachlearn/pml-testing.csv")

# Clean the data
nzCols <- nearZeroVar(data,saveMetrics=T)$nzv
naCols <- colMeans(is.na(data)) > 0.5

data <- data[,!(naCols | nzCols)]
quiz <- quiz[,!(naCols | nzCols)]

# Split into Training und Test set
inTest <- createDataPartition(y=data$classe,p=0.7,list=F)
training <- data[inTest,]
testing <- data[-inTest,]

# Create model incl. preprocessing
model <- train(data=training[7:59],classe ~.,method="rf",preProcess=c("center", "scale"))

# Prediction and cross validation
pred <- predict(model,newdata=testing) 
confusionMatrix(testing$classe,pred)

# Create predictions for submission

predQuiz <- predict(model,newdata=quiz)

pml_write_files = function(x){
        n = length(x)
        for(i in 1:n){
                filename = paste0("problem_id_",i,".txt")
                write.table(x[i],file=filename,quote=FALSE,row.names=FALSE,col.names=FALSE)
        }
}

pml_write_files(predQuiz)

