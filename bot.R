library(telegram.bot)
library(readr)
library(RSQLite)

library(stringr)

TOKEN <- readLines('.token', warn = F)
#PATH <- '/'; setwd(PATH)

bot <- Bot(token = TOKEN)
BOT_IS_BUSY <- FALSE
updater <- Updater(TOKEN)

source("0_db_methods.R")   # file with methods for work with DB
source("1_bot_methods.R")  # file with bot methods (main functionality)
source("2_msg_filters.R")  # file with message filters
source("3_handlers.R")     # file with handlers

check <- function(){
  return("I'm alive")
}

check()

bot$clean_updates()
updater$start_polling()




