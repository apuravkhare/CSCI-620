Airb=read.csv("~/Documents/R/AB_NYC_2019.csv",header=T,na.strings="?")

attach(Airb)
library(sqldf)
library(class)

price_x=Airb$price>100
Airb=data.frame(Airb,price_x)


TRain=sqldf("select longitude,latitude,minimum_nights,
            availability_365 from Airb where price!=0 and
            price<1000 and id%10!=1")


TEst=sqldf("select longitude,latitude,minimum_nights,
           availability_365 from Airb where price!=0 and
           price<1000 and id%10==1")

Train_label=(sqldf("select price_x from Airb where price!=0 and
            price<1000 and id%10!=1"))

TEst_label=sqldf("select price_x from Airb where price!=0 and
            price<1000 and id%10==1")

#normalization 
TRain_z=as.data.frame(scale(TRain))
TEst_z=as.data.frame(scale(TEst))

pred=knn(train=TRain,test=TEst,cl=Train_label$price_x,k=20)

#result
table(Actual = TEst_label$price, Predicted = pred)
cm = as.matrix(table(Actual = TEst_label$price_x, Predicted = pred))
accu=sum(diag(cm))/length(TEst_label$price)
#accuracy
message(accu)

