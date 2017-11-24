library(nnet)
library(caret)
library(hydroGOF)
data=read.csv("EnergyEfficiency.data", header=T,na.strings="?")
#Delete examples with missing values
data=na.omit(data)


set.seed(1)
#Partition data: training and test
#Arguments: dataName$outputName, % of training data, returns a vector (instead of a list), creates one partition
trainIndex = createDataPartition(data$Y2,p=0.8,list=FALSE,times=1)
#Select as train data the examples with index in trainIndex
trainData=data[trainIndex,]
#Select as test data the examples with index not in trainIndex
testData=data[-trainIndex,]

#"center" subtracts the mean, "scale" divides by the standard deviation
preProcValues = preProcess(trainData, method=c("center", "scale"))
trainDataTransf = predict(preProcValues, trainData)
trainDataTransf_x = trainDataTransf[,1:dim(trainData)[2]-1]
trainDataTransf_y = trainDataTransf[,dim(trainData)[2]]

#Standardize test data
testDataTransf = predict(preProcValues, testData)
testDataTransf_x = testDataTransf[,1:dim(testData)[2]-1]
testDataTransf_y = testDataTransf[,dim(testData)[2]]

learningControl = trainControl(method="cv", number=5, verboseIter=TRUE) 
#.size: number of neurons in the hidden layer; .decay: regularization parameter (lambda)
nnetGrid = expand.grid(.size=c(真valore separados por comas??), .decay=c(真valores separados por comas??))


#rang: initial random weights in [-rang, +rang]; maxit: maximum number of training epochs; lineout=TRUE: activation function in the output layer is the identity
model = train(x=trainDataTransf_x, trainDataTransf_y, method="nnet",
rang=真valor??, maxit=真valor??, trControl=learningControl, tuneGrid=nnetGrid, linout=TRUE)
str(model)
print(model)
predTransf=predict(model, testDataTransf_x)

#Undo standarization of output
tmpMean = rep(preProcValues[["mean"]][dim(testData)[2]], length(predTransf)) 
pred = (predTransf*preProcValues[["std"]][dim(testData)[2]])+tmpMean

rmse(matrix(testDataTransf[,dim(testData)[2]]), predTransf)
mse(matrix(testData[,dim(testData)[2]]), pred)

print(testData[,dim(testData)[2]])
print(pred)
dim(data)
names(data)
dim(trainData)
dim(testData)


