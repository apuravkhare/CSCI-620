Airbnb=read.csv("~/Documents/R/AB_NYC_2019.csv",header=T,na.strings="?")

library(sqldf)

# 1. Data Cleaning.
# Removing the incomplete cases, and cleaning the incorrect values
Airbnb = na.omit(Airbnb)

# removing the cases where the price = 0
# free listings are considered as incomplete/noise data.

# 3. Feature Engineering
# encoding 'neighbourhood_group' as a factor.
Airbnb <- within(Airbnb, neighbourhood_group_f <- as.factor(Airbnb$neighbourhood_group))
#Airbnb[1:4,]

# encoding 'neighbourhood' as a factor.
Airbnb <- within(Airbnb, neighbourhood_f <- as.factor(Airbnb$neighbourhood_group))
#Airbnb[1:4,]

# encoding ;availability_365' as a factor, based on the .33rd and .66th quantiles.
availability_quants <- quantile(Airbnb[Airbnb$availability_365 > 0,]$availability_365, c(0, .33, .66))
get_availability_quantile <- function (val) {
  q = vector()
  for (val_index in 1:length(val)) {
    for (index in rev(1:length(availability_quants))) {
      if (val[val_index] >= availability_quants[index]) {
        q[val_index] <- index
        break()
      }
    }
  }
  
  return(q)
}

Airbnb <- within(Airbnb, availability_class <- get_availability_quantile(Airbnb$availability_365))
#Airbnb[1:4,]

# encoding 'room_type' as a categorical attributes with levels.
room_type_factor <- factor(Airbnb$room_type, levels=c("Shared room", "Private room", "Entire home/apt"))
Airbnb=data.frame(Airbnb,room_type_factor)
TEst=sqldf("select longitude,latitude,minimum_nights,
            availability_365,price_class,room_type_factor from Airbnb where price!=0 and
           price<1000 and id%10==1")
TRain=sqldf("select longitude,latitude,minimum_nights,
            availability_365,price_class,room_type_factor from Airbnb where price!=0 and
            price<1000 and id%10!=1")

# Verifying the distribution of price in the train and test sets.



library(randomForest)

# grow tree
fit = randomForest(price_class~.,data=TRain,ntreeclass="regression")


summary(fit) # detailed summary of splits
#rpart.plot(fit) # rpart.plot is not available
print(fit)
predtree=predict(fit,newdata=TEst)
#result
table(TEst$price_x,predtree)
cm = as.matrix(table(Actual = TEst$price_x, Predicted = predtree))
accu=sum(diag(cm))/length(TEst$price_x)
#accuracy
message(accu)
