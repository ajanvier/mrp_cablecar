local Translations = {
    error = {
        cablecar_in_use = "This cablecar is currently in use, please wait before trying again.",
        not_enough_money = "You don't have enough money !"
    },
    help = {
        start = "Press ~INPUT_CONTEXT~ to start"
    },
    target = {
        call_cablecar = "Call a cablecar (%{price} P$)"
    }
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
