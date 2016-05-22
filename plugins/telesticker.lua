do

function run(msg, matches)
send_document(get_receiver(msg), "/root/robot/sticker.webp", ok_cb, false)
end

return {
patterns = {
"^[/#!]([Cc][Pp][Dd])",

},
run = run
}

end
