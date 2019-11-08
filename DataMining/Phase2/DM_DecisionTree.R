Airb=read.csv("~/Documents/R/AB_NYC_2019.csv",header=T,na.strings="?")

attach(Airb)
library(sqldf)
library(rpart)

price_x=Airb$price>50
Airb=data.frame(Airb,price_x)

TRain=sqldf("select longitude,neighbourhood_group,latitude,price,minimum_nights,
            availability_365,price_x from Airb where price!=0 and
            price<1000 and id%10!=1")


TEst=sqldf("select longitude,neighbourhood_group,latitude,price,minimum_nights,
            availability_365,price_x from Airb where price!=0 and
           price<1000 and id%10==1")

# grow tree
fit = rpart(price_x~longitude+latitude+minimum_nights+
            availability_365,method="class", data=TRain)


summary(fit) # detailed summary of splits
#rpart.plot(fit) # rpart.plot is not available

predtree=predict(fit,newdata=TEst,type="class")
#result
table(TEst$price_x,predtree)
cm = as.matrix(table(Actual = TEst$price_x, Predicted = predtree))
accu=sum(diag(cm))/length(TEst$price_x)
#accuracy
message(accu)
