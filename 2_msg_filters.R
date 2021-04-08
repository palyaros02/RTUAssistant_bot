##---- Message Filters ----
MessageFilters$wait_register_check <- BaseFilter(
  function(message)
    get_state(message$chat_id) == "wait_register_check"
)

MessageFilters$wait_group <- BaseFilter(
  function(message)
    get_state( message$chat_id ) == "wait_group"
)

MessageFilters$wait_role <- BaseFilter(
  function(message)
    get_state( message$chat_id ) == "wait_role"
)
