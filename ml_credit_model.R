#1. First, create a machine learning model

url <- "https://archive.ics.uci.edu/ml/machine-learning-databases/statlog/german/german.data"
col.names <- c(
  'Status of existing checking account', 'Duration in month', 'Credit history'
  , 'Purpose', 'Credit amount', 'Savings account/bonds'
  , 'Employment years', 'Installment rate in percentage of disposable income'
  , 'Personal status and sex', 'Other debtors / guarantors', 'Present residence since'
  , 'Property', 'Age in years', 'Other installment plans', 'Housing', 'Number of existing credits at this bank'
  , 'Job', 'Number of people being liable to provide maintenance for', 'Telephone', 'Foreign worker', 'Status'
)
# Get the data
data <- read.csv(
  url
  , header=FALSE
  , sep=' '
  , col.names=col.names
)

# A13: Checking account balance >= 200 DM or salary assignments for at least 1 year
# A14: No checking account
# A32: Existing credits paid back duly till now
# A33: Delay in paying off in the past
# A34: Critical account / other credits existing (not at this bank)
# A64: Savings account balance >= 1000 DM
# A65: Unknown/ no savings account.

library(rpart)
# Build a tree
# I already figured these significant variables from my first iteration (not shown in this code for simplicity)
decision.tree <- rpart(
  Status ~ Status.of.existing.checking.account + Duration.in.month + Credit.history + Savings.account.bonds
  , method="class"
  , data=data
)

library(rpart.plot)
# Visualize the tree
# 1 is good, 2 is bad
prp(
  decision.tree
  , extra=1
  , varlen=0
  , faclen=0
  , main="Decision Tree for German Credit Data"
)

#2. Predict using the machine learning credit model

new.data <- list(
  Status.of.existing.checking.account='A11'
  , Duration.in.month=20
  , Credit.history='A32'
  , Savings.account.bonds='A65'
)
predict(decision.tree, new.data)

# 3. Save it

save(decision.tree, file='decision_Tree_for_german_credit_data.RData')

# 4. Use the R package Plumber to create a RESTful API

library(rpart)
library(jsonlite)
load("decision_Tree_for_german_credit_data.RData")

#* @post /predict
predict.default.rate <- function(
  Status.of.existing.checking.account
  , Duration.in.month
  , Credit.history
  , Savings.account.bonds
) {
  data <- list(
    Status.of.existing.checking.account=Status.of.existing.checking.account
    , Duration.in.month=Duration.in.month
    , Credit.history=Credit.history
    , Savings.account.bonds=Savings.account.bonds
  )
  prediction <- predict(decision.tree, data)
  return(list(default.probability=unbox(prediction[1, 2])))
}


