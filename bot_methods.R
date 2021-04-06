##---- Bot Methods ----
start <- function(bot, update) {
  id <- update$message$chat_id
  bot$sendMessage(
    chat_id = id,
    text = sprintf("Привет, %s! Давай поищу тебя в базе...",
                   update$message$from$first_name))
  
  data <- get_data(id, "*")
  
  if (nrow(data) == 0) {
    bot$sendMessage(id, "Ты новенький! Перехожу к регистрации.")
    ask_group(bot, update)
  } else {
    bot$sendMessage(id, "Нашёл!")
    register_check(bot, update)
  }
  
}
register_check <- function(bot, update) {
  id <- update$message$chat_id
  data <- get_data(id, "*")
  bot$sendMessage(
    id, 
    paste("Давай всё проверим.\nГруппа:",data$group,"\nРоль:",data$role,"\nВсё верно?"),
    reply_markup = ReplyKeyboardMarkup(
      keyboard = list(
        list(
          KeyboardButton("Ага"),
          KeyboardButton("Не-а")
        )
      ),
      resize_keyboard = T,
      one_time_keyboard = T)
  )
  set_state(id, "wait_register_check")
}
ask_group <- function(bot, update) {
  id <- update$message$chat_id
  bot$sendMessage(chat_id = id,
                  text = "Введи группу в формате *XXXX-XX-XX*.\n_Пример:_ ИНБО-05-19",
                  parse_mode = "Markdown")
  
  set_state(id, "wait_group")
}
set_group <- function(bot, update) {
  id <- update$message$chat_id
  text <- toupper(update$message$text)
  if(grepl("[А-Я]{4}-[0-9]{2}-[0-9]{2}", text)) {
    bot$sendMessage(id, "Принято!")
    set_data(id, "[group]", text)
    ask_role(bot, update)
  } else {
    bot$sendMessage(id, "Ошибка :( Попробуй ещё.")
  }
}
ask_role <- function(bot, update) {
  id <- update$message$chat_id
  bot$sendMessage(
    chat_id = id,
    text = "Выбери *роль* (_староста_ или _студент_)",
    parse_mode = "Markdown",
    reply_markup = ReplyKeyboardMarkup(
      keyboard = list(
        list(
          KeyboardButton("Студент"),
          KeyboardButton("Староста")
        )
      ),
      resize_keyboard = T,
      one_time_keyboard = T
    )
  )
  
  set_state(id, "wait_role")
}
set_role <- function(bot, update) {
  id <- update$message$chat_id
  text <- tolower(update$message$text)
  if (text == "староста" | text == "студент"){
    bot$sendMessage(id, "Регистрация завершена.",
                    reply_markup = ReplyKeyboardRemove())
    set_data(id, "role", text)
    register_check(bot, update)
  } else {
    bot$sendMessage(id, "Ошибка :( Попробуй ещё.")
  }
}
register_approve <- function(bot, update) {
  id <- update$message$chat_id
  text <- tolower(update$message$text)
  if (any(c("да","ага") == text)) {
    set_state(id, "OK")
    bot$sendMessage(id, "Отлично!",
                    reply_markup = ReplyKeyboardRemove())
  } else
    ask_group(bot, update)
}
state <- function(bot, update) {
  chat_state <- get_state(update$message$chat_id)
  bot$sendMessage(update$message$chat_id, 
                  text = unlist(chat_state))
}
