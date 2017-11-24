library(nnet)
library(caret)
data=read.csv("bloodTransfusion.data", header=T,na.strings="?")
#data=read.csv("pima-indians-diabetes.data", header=F,na.strings="?")
dim(data)
#Delete examples with missing values
data=na.omit(data)


set.seed(1)
#Partition data: training and test
#Arguments: dataName$outputName, % of training data, returns a vector (instead of a list), creates one partition
trainIndex = createDataPartition(data$y,p=0.8,list=FALSE,times=1)
#trainIndex = createDataPartition(data$V9,p=0.8,list=FALSE,times=1)
#Select as train data the examples with index in trainIndex
trainData=data[trainIndex,]
#Select as test data the examples with index not in trainIndex
testData=data[-trainIndex,]

#"center" subtracts the mean, "scale" divides by the standard deviation
preProcValues = preProcess(trainData[,1:dim(trainData)[2]-1], method=c("center", "scale"))
trainDataTransf_x = predict(preProcValues, trainData[,1:dim(trainData)[2]-1])
train_y=factor(trainData[,dim(trainData)[2]])

#Standardize test data
testDataTransf_x = predict(preProcValues, testData[,1:dim(testData)[2]-1])
#cbind(testDataTransf, testData[,dim(testData)[2]])
test_y=factor(testData[,dim(testData)[2]])


learningControl = trainControl(method="cv", number=5, verboseIter=TRUE) 
#.size: number of neurons in the hidden layer; .decay: regularization parameter (lambda)
nnetGrid = expand.grid(.size=c(真valores separados por comas??), .decay=c(真valores separados por comas??))

#rang: initial random weights in [-rang, +rang]; maxit: maximum number of training epochs
model = train(x=trainDataTransf_x, train_y, method="nnet",
rang=真valor??, maxit=真valor??, trControl=learningControl, tuneGrid=nnetGrid)
str(model)
print(model)

pred=predict(model, testDataTransf_x)
confusionMatrix(pred, test_y)
dim(data)
names(data)
dim(trainData)
dim(testData)


