##---- Bot Methods ----
start <- function(bot, update) {
  id <- update$message$chat_id
  bot$sendMessage(id,
    text = sprintf("Привет, %s!",
                   update$message$from$first_name)
  )
  bot$sendMessage(id, parse_mode = "Markdown",
                    "Введи группу в формате *XXXX-XX-XX*.
                    \n_Пример:_ ИНБО-05-19")
  set_state(id, "wait_group")
}

set_group_chat <- function(bot, update) {
  id <- update$message$chat_id
  group <- toupper(enc2native(update$message$text))
  if (grepl("[А-Я]{4}-[0-9]{2}-[0-9]{2}", group)) { # АБВГ-12-34
    bot$sendMessage(id, "Принято",reply_markup = ReplyKeyboardMarkup(
      keyboard = list(list(
        KeyboardButton("На сегодня"),
        KeyboardButton("На завтра"),
        KeyboardButton("На неделю")),
        list(
          KeyboardButton("На следующую неделю"))
      ),
      resize_keyboard = TRUE,
      one_time_keyboard = FALSE))
    try <- set_group(id, group)
    if (try == 0)
      bot$sendMessage(id, "К сожалению, расписание для твоей группы пока недоступно.")
    else
      set_state(id, 'OK')
  } else {
    bot$sendMessage(id, "Ошибка :( Попробуй ещё.")
  }

}

menu <- function(bot, update) {
  id <- update$message$chat_id
  text <- enc2native(update$message$text)
  is_even = (as.integer(Sys.Date()-as.Date('2021-02-08'))%/%7)%%2
  get_time <- function(num){
    switch(as.character(num),
           '1'="9:00 - 10:30",
           '2'="10:40 - 12:10",
           '3'="12:40 - 14:10",
           '4'="14:20 - 15:50",
           '5'="16:20 - 17:50",
           '6'="18:00 - 19:30"
    )
  }
  to_num <- function(day){
    days = c("понедельник","вторник","среда","четверг","пятница","суббота","воскресенье")
    return(which(days == day))
  }
  to_day <- function(num){
    switch(num, "понедельник","вторник","среда","четверг","пятница","суббота")
  }

  if (text == "На сегодня") {
    day = to_num(enc2native(tolower(weekdays(Sys.Date()))))
    r = get_sch(id, day, is_even)
    if (nrow(r) == 0)
      bot$sendMessage(id, "Пар не обнаружено")
    else
      bot$sendMessage(id, parse_mode = "Markdown",
      paste0('*==== \U0001F4C5 ',toupper(to_day(day)),' \U0001F4C5 ====* \n',
       paste0(collapse='\n','*',unlist(r[1])," пара:* \U00023F0",sapply(unlist(r[1]), get_time),
    ' \U0001F6AA',unlist(r[5]),' \U0001F6A9',unlist(r[3]),'\n',unlist(r[2]),'\n',unlist(r[4]),'\n'))
    )
  }
  else if (text == "На завтра") {
    day = to_num(enc2native(tolower(weekdays(Sys.Date()+1))))
    r = get_sch(id, day, is_even)
    if (nrow(r) == 0)
      bot$sendMessage(id, "Пар не обнаружено")
    else
     bot$sendMessage(id, parse_mode = "Markdown",
      paste0('*==== \U0001F4C5 ',toupper(to_day(day)),' \U0001F4C5 ====* \n',
      paste0(collapse='\n','*',unlist(r[1])," пара:* \U00023F0",sapply(unlist(r[1]), get_time),
    ' \U0001F6AA',unlist(r[5]),' \U0001F6A9',unlist(r[3]),'\n',unlist(r[2]),'\n',unlist(r[4]),'\n'))
    )
  }
  else if (text == "На неделю") {
    res = c()
    for(day in 1:6){
      r = get_sch(id, day, is_even)
      if (nrow(r) == 0) next
      res = c(res, paste0('*==== \U0001F4C5 ',toupper(to_day(day)),' \U0001F4C5 ====* \n',
          paste0(collapse='\n','*',unlist(r[1])," пара:* \U00023F0",sapply(unlist(r[1]), get_time),
      ' \U0001F6AA',unlist(r[5]),' \U0001F6A9',unlist(r[3]),'\n',unlist(r[2]),'\n',unlist(r[4]),'\n')))
    }
    bot$sendMessage(id, parse_mode = "Markdown",
                    paste0(collapse='\n', res))

  }
  else if (text == "На следующую неделю") {
    if(is_even==0) is_even = 1
    else is_even = 0
    res = c()
    for(day in 1:6){
      r = get_sch(id, day, is_even)
      if (nrow(r) == 0) next
      res = c(res, paste0('*==== \U0001F4C5 ',toupper(to_day(day)),' \U0001F4C5 ====* \n',
  paste0(collapse='\n','*',unlist(r[1])," пара:* \U00023F0",sapply(unlist(r[1]), get_time),
 ' \U0001F6AA',unlist(r[5]),' \U0001F6A9',unlist(r[3]),'\n',unlist(r[2]),'\n',unlist(r[4]),'\n')))
    }
    bot$sendMessage(id, parse_mode = "Markdown",
                    paste0(collapse='\n', res))
  }
  bot$sendMessage(id, "Выбери период для получения расписания.",
                  reply_markup = ReplyKeyboardMarkup(
                    keyboard = list(list(
                      KeyboardButton("На сегодня"),
                      KeyboardButton("На завтра"),
                      KeyboardButton("На неделю")),
                      list(
                        KeyboardButton("На следующую неделю"))
                    ),
                    resize_keyboard = TRUE,
                    one_time_keyboard = FALSE
                  ))

 }

busy <- function(bot, update) {
  id <- update$message$chat_id
  bot$sendMessage(id, "В данный момент я обновляю расписание. Попробуй через пару минут.")
}
update <- function(bot, update) {
  if (update$message$chat_id == 460020469) {
    bot$sendMessage(460020469, "начинаю апдейт")
    BOT_IS_BUSY <- TRUE
    update_db()
    bot$sendMessage(460020469, "готово")
    BOT_IS_BUSY <<- FALSE
  }
}
state <- function(bot, update) {
  chat_state <- get_state(update$message$chat_id)
  bot$sendMessage(update$message$chat_id,
    text = unlist(chat_state)
  )
}
