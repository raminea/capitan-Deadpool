do

function run(msg, matches)
send_document(get_receiver(msg), "/root/robot/sticker.webp", ok_cb, false)
end

return {
patterns = {
"^[Ss][Bb][Ss][Ss]$",
"^[!/]([Ii][Rr][Oo]$",

},
run = run
}

end
