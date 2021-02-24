library(readr)
library(readxl)
data=read_xlsx(file.choose())
library(tseries)
library(forecast)
library(fpp)
library(smooth)
data['t']=c(1:96)
data["t_square"]=data['t']*data['t']
data["logt"]=log(data["t"])
X <- data.frame(outer(rep(month.abb,length = 96), month.abb,"==") + 0 )# Creating dummies for 12 months
colnames(X) <- month.abb # Assigning month names
View(X)
data=cbind(data,X)
colnames(data)

attach(data)
data_train=data[1:76,]
data_test=data[77:96,]
#*****************linear****************
linear_model <- lm(Passengers ~ t, data = data_train)
summary(linear_model)

linear_pred <- data.frame(predict(linear_model, interval = 'predict', newdata = data_test))

rmse_linear <- sqrt(mean((data_test$Passengers - linear_pred$fit)^2, na.rm = T))
rmse_linear

######################### Exponential ############################

expo_model <- lm(logt ~ t, data = data_train)
summary(expo_model)
expo_pred <- data.frame(predict(expo_model, interval = 'predict', newdata = data_test))
rmse_expo <- sqrt(mean((data_test$Passengers - exp(expo_pred$fit))^2, na.rm = T))
rmse_expo

######################### Quadratic ###############################

Quad_model <- lm(Passengers ~ t + t_square, data = data_train)
summary(Quad_model)
Quad_pred <- data.frame(predict(Quad_model, interval = 'predict', newdata = data_test))
rmse_Quad <- sqrt(mean((data_test$Passengers-Quad_pred$fit)^2, na.rm = T))
rmse_Quad      


######################### Additive Seasonality #########################

sea_add_model <- lm(Passengers ~ Jan + Feb + Mar + Apr + May + Jun + Jul + Aug + Sep + Oct + Nov + Dec, data = data_train)
summary(sea_add_model)
sea_add_pred <- data.frame(predict(sea_add_model, newdata = data_test, interval = 'predict'))
rmse_sea_add <- sqrt(mean((data_test$Passengers - sea_add_pred$fit)^2, na.rm = T))
rmse_sea_add


######################## Multiplicative Seasonality #########################

multi_sea_model <- lm(logt ~ Jan + Feb + Mar + Apr + May + Jun + Jul + Aug + Sep + Oct + Nov, data = data_train)
summary(multi_sea_model)
multi_sea_pred <- data.frame(predict(multi_sea_model, newdata = data_test, interval = 'predict'))
rmse_multi_sea <- sqrt(mean((data_test$Passengers - exp(multi_sea_pred$fit))^2, na.rm = T))
rmse_multi_sea



################### Additive Seasonality with linear Trend #################
Add_sea_Quad_model <- lm(Passengers ~ t  + Jan + Feb + Mar + Apr + May + Jun + Jul + Aug + Sep + Oct + Nov, data = data_train)
summary(Add_sea_Quad_model)
Add_sea_Quad_pred <- data.frame(predict(Add_sea_Quad_model, interval = 'predict', newdata = data_test))
rmse_Add_sea_Quad <- sqrt(mean((data_test$Passengers - Add_sea_Quad_pred$fit)^2, na.rm=T))
rmse_Add_sea_Quad

# Preparing table on model and it's RMSE values 
table_rmse <- data.frame(c("rmse_linear", "rmse_expo", "rmse_Quad", "rmse_sea_add", "rmse_Add_sea_Quad", "rmse_multi_sea"), c(rmse_linear, rmse_expo, rmse_Quad, rmse_sea_add, rmse_Add_sea_Quad, rmse_multi_sea))
colnames(table_rmse) <- c("model", "RMSE")
View(table_rmse)


#*********************File*********************************
write.csv(data, file = "Airlines.csv", row.names = F)
getwd()

############### Combining Training & test data to build Additive seasonality using Quadratic Trend ############
Add_sea_Quad_model_final <- lm(Passengers~ t+Jan+Feb+Mar+Apr+May+Jun+Jul+Aug+Sep+Oct+Nov, data = data)
summary(Add_sea_Quad_model_final)

####################### Predicting new data #############################

test_data <- read_csv(file.choose())
View(test_data)
pred_new <- predict(Add_sea_Quad_model_final, newdata = test_data, interval = 'predict')
pred_new <- as.data.frame(pred_new)
pred_new$fit
plot(Add_sea_Quad_model_final)

