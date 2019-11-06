Airb=read.csv("~/Documents/R/AB_NYC_2019.csv",header=T,na.strings="?")

attach(Airb)
library(sqldf)
library(rpart)

mean(Airb$price)
price_x=Airb$price>100
Airb=data.frame(Airb,price_x)

TRain=sqldf("select longitude,neighbourhood_group,latitude,price,minimum_nights,
            availability_365,price_x from Airb where price!=0 and
            price<1000 and id%5!=0")


TEst=sqldf("select longitude,neighbourhood_group,latitude,price,minimum_nights,
            availability_365,price_x from Airb where price!=0 and
           price<1000 and id%5==0")
mean(TEst$price)
# grow tree
fit = rpart(price_x~longitude+latitude+minimum_nights+
            availability_365,method="class", data=TRain)

printcp(fit) # display the results
plotcp(fit) # visualize cross-validation results
summary(fit) # detailed summary of splits
plot(fit) # plot tree

predtree=predict(fit,newdata=TEst,type="class")
table(TEst$price_x,predtree)

