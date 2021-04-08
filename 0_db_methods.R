##---- Database ----
db <- "bot.db"

get_state <- function(chat_id) {
  con <- dbConnect(SQLite(), db)

    chat_state <- dbGetQuery(con, str_interp("

      SELECT state FROM chat_state
      WHERE chat_id == ${chat_id}

      "))

  dbDisconnect(con)
  return(unlist(chat_state$state))
}

set_state <- function(chat_id, state) {
  con <- dbConnect(SQLite(), db)

    dbExecute(con, str_interp("

      INSERT INTO chat_state (chat_id, state)
      VALUES(${chat_id}, '${state}')
      ON CONFLICT(chat_id) DO UPDATE SET state='${state}';

      "))

  dbDisconnect(con)
}

get_data <- function(chat_id, field) {
  con <- dbConnect(SQLite(), db)

    data <- dbGetQuery(con, str_interp("

      SELECT ${field} FROM data
      WHERE chat_id = ${chat_id};

      "))

  dbDisconnect(con)
  return(data)
}

set_data <- function(chat_id, field, value) {
  con <- dbConnect(SQLite(), db)

    dbExecute(con, str_interp("

      INSERT INTO data (chat_id, ${field})
      VALUES(${chat_id}, '${value}')
      ON CONFLICT(chat_id) DO UPDATE SET ${field}='${value}';

      "))

  dbDisconnect(con)
}
