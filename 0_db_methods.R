##---- Database ----
with_con <- function(f, db = "bot.db") {
  function(...) {
    con <- dbConnect(SQLite(), db)
    res <- f(..., `con` = con)
    on.exit(dbDisconnect(con))
    res
  }
}

get_state_ <- function(chat_id, con) {
  chat_state <- dbGetQuery(con, str_interp("
      SELECT state FROM chat_state
      WHERE chat_id == ${chat_id}
      "))
  return(unlist(chat_state$state))
}

set_state_ <- function(chat_id, state, con) {
  dbExecute(con, str_interp("
      INSERT INTO chat_state (chat_id, state)
      VALUES(${chat_id}, '${state}')
      ON CONFLICT(chat_id) DO UPDATE SET state='${state}';
      "))

}

find_user_ <- function(chat_id, con) {
  data <- dbGetQuery(con, str_interp("
      SELECT chat_id FROM student
      WHERE chat_id = ${chat_id};
      "))
  return(nrow(data) == 0)
}

set_group_ <- function(chat_id, group, con) {
  check <- dbGetQuery(con, str_interp("
      SELECT id FROM groups WHERE name='${group}';
      "))
  if (nrow(check) == 0)
    return(0)
  else {
    dbExecute(con, str_interp("
      INSERT INTO student (chat_id, group_id)
      VALUES(${chat_id}, (SELECT id FROM groups WHERE name = '${group}'))
      ON CONFLICT(chat_id) DO
      UPDATE SET group_id=(SELECT id FROM groups WHERE name = '${group}');
      "))
    return(1)
  }

}

update_db_ <- function(con) {
  BOT_IS_BUSY <<- TRUE
  bot$sendMessage(460020469, "чищу записи")
  dbExecute(con, "DELETE FROM groups;")
  dbExecute(con,"DELETE FROM SQLite_sequence WHERE name = 'groups';")
  dbExecute(con,'DELETE FROM schedule;')
  dbExecute(con,'REINDEX schedule;')
  dbExecute(con,'VACUUM;')
  json <- jsonlite::fromJSON("./parsing/schedule.json", simplifyVector = TRUE, simplifyMatrix = F)
  groups <- names(json)
  bot$sendMessage(460020469, "обновляю группы")
  for (group in groups)
    dbExecute(con, str_interp("
     INSERT INTO groups(id, name)
                     VALUES ((SELECT id FROM groups
                               WHERE name == '${group}'),
                            '${group}');
      "))
  bot$sendMessage(460020469, "обновляю расписание")
  total = (length(json))
  for (i in 1:total) {
    if (i%%14==0)  bot$sendMessage(460020469, str_interp("${i%/%14*10}%"))
    gid <- unlist(dbGetQuery(con, str_interp("
        SELECT id FROM groups WHERE name = '${names(json[i])}';")))
    for (day in 1:6)
      for (pairs in json[[i]][[day]])
        dbExecute(con, str_interp("
            INSERT INTO schedule(group_id, day, is_even, pair_no,
                                       content, type, teacher, aud)
                       VALUES (${gid},${day},${pairs[1]},${pairs[2]},'${pairs[3]}',
                                '${pairs[4]}','${pairs[5]}','${pairs[6]}');
            "))
  }
  BOT_IS_BUSY <<- FAL
  SE
}

get_sch_ <- function(id, day, even=2, con) {
  if (even == 2)
    return(dbGetQuery(con, str_interp("
        SELECT is_even, pair_no, content, type, teacher, aud
          FROM schedule
        WHERE group_id=(SELECT group_id
                        FROM student
                        WHERE chat_id=${id})
          AND day=${day};")))
  else
    return(dbGetQuery(con, str_interp("
        SELECT pair_no, content, type, teacher, aud
          FROM schedule
        WHERE group_id=(SELECT group_id
                        FROM student
                        WHERE chat_id=${id})
        AND day=${day}
        AND is_even=${even};")))
}


get_state <- with_con(get_state_)
set_state <- with_con(set_state_)
find_user <- with_con(find_user_)
set_group <- with_con(set_group_)
update_db <- with_con(update_db_)
get_sch <- with_con(get_sch_)
