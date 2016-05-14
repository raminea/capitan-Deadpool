local function returnids(cb_extra, success, result)
   local receiver = cb_extra.receiver
   local chat_id = result.id
   local chatname = result.print_name
   for k,v in pairs(result.members) do
      send_large_msg(v.print_name, text)
   end
   send_large_msg(receiver, 'پیام با موفقیت به همه اعضا ارسال شد')
end

local function run(msg, matches)
   local receiver = get_receiver(msg)
   if not is_chat_msg(msg) then
      return 'Working just in group🚀'
   end
   if matches[1] then
      text = 'sended to : ' .. string.gsub(msg.to.print_name, '_', ' ') .. '\n______________________________'
      text = text .. '\n\n' .. matches[1]
      local chat = get_receiver(msg)
      chat_info(chat, returnids, {receiver=receiver})
   end
end

return {
   description = "💢send message to all group members",
   usage = {
	  "/s2a (pm) : 💢send message to all group members",
	  "s2a (pm) : 💢send message to all group members",
   },
   patterns = {
	  "^[!/#]s2a +(.+)$",
	  "^s2a +(.+)$"
   },
   run = run,
   moderated = true
}
