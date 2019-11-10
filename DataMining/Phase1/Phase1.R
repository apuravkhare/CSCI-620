library(rpart)
# install.packages("rpart.plot")
library(rpart.plot)

setwd("C:\\Users\\apura\\Desktop\\CSCI-620-src\\AirBnb")

Airbnb <- read.csv("AB_NYC_2019.csv") 48895 - 38843

names(Airbnb)

# Removing the incomplete cases, and cleaning the incorrect values
Airbnb = na.omit(Airbnb)
mean(Airbnb$price)

Airbnb = Airbnb[Airbnb$price > 0,]

diff <- setdiff(Airbnb, na.omit(Airbnb))

summary(Airbnb[Airbnb$last_review != '',]$last_review)

un <- unique(Airbnb[Airbnb$last_review != '',]$last_review)

levels(Airbnb$last_review)

# percentiles
quants <- quantile(Airbnb$price)

nrow(Airbnb[Airbnb$price_class == 5,])
# 9663, 9726, 9660, 9782, 2

# maps price to price_class
get_quantile <- function (val) {
  q = vector()
  for (val_index in 1:length(val)) {
    for (index in rev(1:length(quants))) {
      if (val[val_index] >= quants[index]) {
        q[val_index] <- index
        break()
      }
    }
  }
  
  return(q)
}

hist(Airbnb$price_class)

unique(Airbnb$room_type)
unique(Airbnb$neighbourhood_group)
unique(Airbnb$neighbourhood)
quantile(Airbnb[Airbnb$availability_365 > 0,]$availability_365, c(.33, .50, .66))

plot(Airbnb$neighbourhood, Airbnb$price)

plot(Airbnb$minimum_nights, Airbnb$price)

nrow(Airbnb[Airbnb$availability_365 == 0,])

hist(Airbnb$availability_365)

# Assigning the price class.
Airbnb <- within(Airbnb, price_class <- get_quantile(Airbnb$price))

tree <- rpart(price ~ neighbourhood_group + room_type + availability_365, data=Airbnb)

price_class_f <- factor(Airbnb$price_class, levels=1:4, labels=c("$", "$$", "$$$", "$$$$"))

Airbnb <- within(Airbnb, room_type_f <- as.factor(Airbnb$room_type))

Airbnb <- within(Airbnb, neighbourhood_group_f <- as.factor(Airbnb$neighbourhood_group))

tree2 <- rpart(price_class_f ~ room_type_f + neighbourhood_group_f + availability_365 + minimum_nights + reviews_per_month + number_of_reviews, data=Airbnb, method='class' )

rpart.plot(tree2)

rpart.predict(tree2, c("Private Room", "Bronx"), type="class")

train <- Airbnb[sample(nrow(Airbnb),0.8*nrow(Airbnb)),]
test <- Airbnb[sample(nrow(Airbnb),0.2*nrow(Airbnb)),]

hist(train$price_class)
hist(test$price_class)


sample(1:20, 10, replace=TRUE)

