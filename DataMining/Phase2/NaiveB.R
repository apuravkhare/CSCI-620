Airb=read.csv("~/Documents/R/AB_NYC_2019.csv",header=T,na.strings="?")

attach(Airb)
library(sqldf)
library(e1071)

price_x=Airb$price>100
Airb=data.frame(Airb,price_x)

TRain=sqldf("select longitude,latitude,minimum_nights,
            availability_365,price_x from Airb where price!=0 and
            price<1000 and id%10!=1")


TEst=sqldf("select longitude,latitude,minimum_nights,
           availability_365,price_x from Airb where price!=0 and
           price<1000 and id%10==1")

fit=naiveBayes(price_x~.,data=TRain)
pred=predict(fit,TEst,type="class")
cm = as.matrix(table(Actual = TEst$price_x, Predicted = pred))
accu=sum(diag(cm))/length(TEst$price_x)
message(accu)
