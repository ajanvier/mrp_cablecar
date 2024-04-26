local Translations = {
    error = {
        cablecar_in_use = "Ce téléphérique est actuellement utilisé, veuillez réessayez dans quelques instants.",
        not_enough_money = "Vous n'avez pas assez d'argent !"
    },
    help = {
        start = "Appuyez sur ~INPUT_CONTEXT~ pour démarrer"
    },
    target = {
        call_cablecar = "Appeler un téléphérique (%{price} P$)"
    }
}

if GetConvar('qb_locale', 'en') == 'fr' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
