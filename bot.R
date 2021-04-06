library(telegram.bot)
library(DBI)
library(readr)
library(RSQLite)

library(stringr)

TOKEN <- readLines('.token', warn=F)
PATH <- "C:/Users/palya/Documents/RTUAssistant_bot"; setwd(PATH)

bot <- Bot(token = TOKEN)

updater <- Updater(TOKEN)

source("db_methods.R")
source("bot_methods.R")
source("msg_filters.R")
source("handlers.R")

updater$start_polling()
