##---- Message Filters ----
MessageFilters$wait_group <- BaseFilter(
  function(message)
    get_state( message$chat_id ) == "wait_group"
)
MessageFilters$OK <- BaseFilter(
  function(message)
    get_state( message$chat_id ) == "OK"
)
MessageFilters$BUSY <- BaseFilter(
  function(message)
    BOT_IS_BUSY
)
