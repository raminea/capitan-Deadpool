do

local function run(msg, matches)
  local id = msg.to.id
if matches[1]:lower() == "gplist" then
local text = 'The list of groups that you can join them : \n'
local name = redis:hkeys("passes")
for i=1,#name do
text = text..i..'- '..name[i]..'\n'
end
return text
end
  if matches[1]:lower() == "/user" and msg.to.type == "chat" and matches[2] and is_owner(msg) then
    local pass = matches[2]:lower()
    if redis:hget('passes',pass) then
      return "user "..matches[2].."For this group was set\nFrom now on users can enter by sending their groups \njoin "..matches[2]
    end
local nowpass = redis:hget('setpass',msg.to.id)
if nowpass then
redis:hdel('passes',nowpass)
end
redis:hset('setpass',msg.to.id,pass)
redis:hset('passes',pass,msg.to.id)
local name = string.gsub(msg.to.print_name, '_', '')
     send_large_msg("chat#id"..msg.to.id, "user "..matches[2].." For this group was set\nFrom now on users can enter by sending their groups \njoin "..matches[2], ok_cb, true)
    return
  end
  if matches[1]:lower() == "join" and matches[2] then
    local hash = 'passes'
    local pass = matches[2]:lower()
    id = redis:hget(hash, pass)
    local receiver = get_receiver(msg)
    if not id then
      return "There is a group with this user❌"
    end
  if data[tostring(id)] then
  if is_banned(msg.from.id, id) then
      return 'you are banned this group💢'
   end
      if is_gbanned(msg.from.id) then
            return 'you are has been super banned💥'
      end
      if data[tostring(id)]['settings']['lock_member'] == 'yes' and not is_owner2(msg.from.id, id) then
        return 'group is private🔰'
      end
    end
    chat_add_user("chat#id"..id, "user#id"..msg.from.id, ok_cb, false) 
  return 'added '..pass..' to group🚀'
  end
  if matches[1]:lower() == "user" then
if not msg.to.type == 'chat' then
return 'just in groups⚠️'
end
   local hash = 'setpass'
   local pass = redis:hget(hash,msg.to.id)
   local receiver = get_receiver(msg)
   send_large_msg(receiver, "group user [ "..msg.to.print_name.." ] :\n\n > "..pass)
 end
end

return {
  patterns = {
    "^(/[Uu]ser) (.*)$",
    "^(/[Uu]ser)$",
    "^(/[Gg]plist)$",
    "^(/[Jj]oin) (.*)$",
  },
  run = run
}
end      
