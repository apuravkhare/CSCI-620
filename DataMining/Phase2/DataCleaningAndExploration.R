setwd("C:\\Users\\apura\\Desktop\\CSCI-620-src\\AirBnb")

Airbnb <- read.csv("AB_NYC_2019.csv")

names(Airbnb)

# 1. Data Cleaning.
# Removing the incomplete cases, and cleaning the incorrect values
Airbnb = na.omit(Airbnb)

# removing the cases where the price = 0
# free listings are considered as incomplete/noise data.
Airbnb = Airbnb[Airbnb$price > 0,]

# creating categorical price values from using the quantiles.
# mean of the price
mean(Airbnb$price)

# 2. Categorizing price.
# percentiles of the price.
quants <- quantile(Airbnb$price)

# maps price to price_class
get_quantile <- function (val) {
  q = vector()
  for (val_index in 1:length(val)) {
    for (index in rev(1:length(quants)-1)) {
      if (val[val_index] >= quants[index]) {
        q[val_index] <- index
        break()
      }
    }
  }
  
  return(q)
}

# Assigning the price class.
Airbnb <- within(Airbnb, price_class <- get_quantile(Airbnb$price))
Airbnb[1:4,]

# Distribution by price class.
hist(Airbnb$price_class)

# 3. Feature Engineering
# encoding 'neighbourhood_group' as a factor.
Airbnb <- within(Airbnb, neighbourhood_group_f <- as.factor(Airbnb$neighbourhood_group))
Airbnb[1:4,]

# encoding 'neighbourhood' as a factor.
Airbnb <- within(Airbnb, neighbourhood_f <- as.factor(Airbnb$neighbourhood_group))
Airbnb[1:4,]

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
Airbnb[1:4,]

# encoding 'room_type' as a categorical attributes with levels.
room_type_factor <- factor(Airbnb$room_type, levels=c("Shared room", "Private room", "Entire home/apt"))

# 4. Train and Test split.
# Randomly identifying indexes of 80% of the rows for the training set,
train_ind = sample(seq_len(nrow(Airbnb)),size = 0.8*nrow(Airbnb))
# The training dataset
train <- Airbnb[train_ind,]
train[1:4,]
# All other indexes go into the testing dataset.

test <- Airbnb[-train_ind,]
test[1:4,]

# Verifying the distribution of price in the train and test sets.
hist(train$price_class)
hist(test$price_class)
