##---- Handlers ----
ch_start <- CommandHandler("start", start)
ch_state <- CommandHandler("state", state)

mh_wait_group <- MessageHandler(

  set_group,

  MessageFilters$wait_group &
  !MessageFilters$command
)

mh_wait_role <- MessageHandler(

  set_role,

  MessageFilters$wait_role &
  !MessageFilters$command
)

mh_wait_register_check <- MessageHandler(

  register_approve,

  MessageFilters$wait_register_check &
  !MessageFilters$command
)

updater <- updater +
           ch_start +
           ch_state +
           mh_wait_group +
           mh_wait_role +
           mh_wait_register_check
