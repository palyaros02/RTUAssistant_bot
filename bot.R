library(telegram.bot)

TOKEN <- readLines('.token', warn=F)

bot <- Bot(token = TOKEN)

# Запрашиваем информацию о боте
print(bot$getMe())

# Получаем обновления бота, т.е. список отправленных ему сообщений
updates <- bot$getUpdates()

# Запрашиваем идентификатор чата
chat_id <- updates[[1L]]$from_chat_id()

bot$sendMessage(754256022, text = "взлом жопы")
chat_id <- "460020469" #460020469 - я 423622323 - ваня 534436665 - саша

# Create Custom Keyboard
text <- "test"
RKM <- ReplyKeyboardMarkup(
  keyboard = list(
    list(KeyboardButton("test1")),
    list(KeyboardButton("test2")),
    list(KeyboardButton("test3"))
  ),
  resize_keyboard = FALSE,
  one_time_keyboard = TRUE
)

# Send Custom Keyboard
bot$sendMessage(chat_id, text, reply_markup = RKM)


for (i in 1:length(updates)){
  cat(updates[[i]][["message"]][["from"]][["username"]],': ')
  cat(updates[[i]][["message"]][["text"]], sep='\n')
}
