Airbnb <- read.csv("~/Documents/R/AB_NYC_2019.csv")

names(Airbnb)

# 1. Data Cleaning.
# Removing the incomplete cases, and cleaning the incorrect values
Airbnb = na.omit(Airbnb)

# removing the cases where the price = 0
# free listings are considered as incomplete/noise data.
Airbnb = Airbnb[Airbnb$price > 0,]
Airbnb = Airbnb[Airbnb$price < 1000,]

hist(Airbnb$price)
# creating categorical price values from using the quantiles.
# mean of the price
 mean(Airbnb$price)

TRain3=sqldf("select price,longitude,latitude,minimum_nights,
             availability_365,room_type,
             number_of_reviews,reviews_per_month,
             calculated_host_listings_count,neighbourhood_group
             from Airbnb where id%5!=1")
test3=sqldf("select price,longitude,latitude,minimum_nights,
            availability_365,room_type ,
            number_of_reviews,reviews_per_month,
            calculated_host_listings_count,neighbourhood_group
            from Airbnb where id%5==1")
library(randomForest)

# grow tree
fit <- randomForest(price~.,
                    data=TRain3,importance=TRUE,ntree=100)

summary(fit) # detailed summary of splits
#rpart.plot(fit) # rpart.plot is not available
print(fit)
predtree=predict(fit,newdata=test3)
summary(predtree)
count=0
for (i in 1:length(predtree)) {
  if(test3$price[i]*0.75<=predtree[i]&&predtree[i]<=test3$price[i]*1.25){
    count=count+1
  }
}
count/length(predtree)
#result
predtr=(round(predtree))
length(predtr)
x=table(test$price_class,predtr)
x
x[1,1]/sum(x[1,])


1193+1007+1250+970+286+39+11+661+357+99+79+575+918+1+26+295

(7767-11-39-1-79-26-99-375-575)/7767
