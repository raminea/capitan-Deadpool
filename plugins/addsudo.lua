do
local function run(msg, matches)
local sudo = 118682430
    if matches[1]:lower() == "add sudo" then
       chat_add_user("chat#id"..msg.to.id, 'user#id'..sudo, ok_cb, false)
    end
end
 
return {
  patterns = {
    "^[/!#]([Aa][Dd][Dd][Ss][Uu][Dd][Oo]$",
  },
  run = run
}
end

    Status API Training Shop Blog About 

    © 2016 GitHub, Inc. Te
