##---- Handlers ----
ch_start <- CommandHandler("start", start)
ch_state <- CommandHandler("state", state)
ch_update <- CommandHandler("update", update)

mh_BUSY <- MessageHandler(
  filters = MessageFilters$BUSY,
  callback = busy
)

mh_wait_group <- MessageHandler(
  filters = MessageFilters$wait_group &
    !MessageFilters$command &
    !MessageFilters$BUSY,
  callback = set_group_chat
)

mh_OK <- MessageHandler(
  filters = MessageFilters$OK &
    !MessageFilters$command &
    !MessageFilters$BUSY,

  callback = menu
)

updater <- updater +
           ch_start +
           ch_state +
           ch_update +
           mh_wait_group +
           mh_OK +
           mh_BUSY
