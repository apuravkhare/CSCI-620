Airbnb <- read.csv("~/Documents/R/AB_NYC_2019.csv")

names(Airbnb)

# 1. Data Cleaning.
# Removing the incomplete cases, and cleaning the incorrect values
Airbnb = na.omit(Airbnb)

# removing the cases where the price = 0
# free listings are considered as incomplete/noise data.
Airbnb = Airbnb[Airbnb$price > 0,]
Airbnb = Airbnb[Airbnb$price < 1000,]
price=Airbnb$price
price=price[price<400]
library(cluster)
library(fpc)

kNNdistplot(Airbnb$price,k=100)
hist(Airbnb$price)

fit=dbscan(price,10,1000)
print(fit)
range(price[fit$cluster[]==1])
