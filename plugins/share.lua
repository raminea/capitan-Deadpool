do

function run(msg, matches)

if matches[1] == 'share' then
send_contact(get_receiver(msg), "+13306675180", "cpd", "Use /Share To Get Number🔰", ok_cb, false)
end
end
return {
patterns = {
"^[#!/]([Ss][Hh][Aa][Rr][Ee])$",
"^([Ss][Hh][Aa][Rr][Ee])$"

},
run = run
}

end
