library(sqldf)

price_x=Airb$price>150
Airb=data.frame(Airb,price_x)

TRain=sqldf("select longitude,latitude,price,minimum_nights,
            availability_365,price_class from Airbnb where id%5!=0")


TEst=sqldf("select longitude,latitude,price,minimum_nights,
            availability_365,price_class from Airbnb where id%5==0")

# grow tree

fit=rpart(price_class~.,data = TRain1,method = "class")
summary(fit) # detailed summary of splits
rpart.plot(fit) # plot tree
predtree=predict(fit,newdata=test1)
#result
predtree
for (variable in 1:length(predtree)) {
  predtr[variable]=which.max(predtree[variable])
}
predtr=index(max(predtree))
x=table(predtree,TEst$price_class)
x
(x[1,1]+x[2,2]+x[3,3])/sum(x[,])
