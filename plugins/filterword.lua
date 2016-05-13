local function save_filter(msg, name, value)
  local hash = nil
  if msg.to.type == 'chat' then
    hash = 'chat:'..msg.to.id..':filters'
  end
  if msg.to.type == 'user' then
    return 'just in group❌''
  end
  if hash then
    redis:hset(hash, name, value)
    return "done ✅"
  end
end

local function get_filter_hash(msg)
  if msg.to.type == 'chat' then
    return 'chat:'..msg.to.id..':filters'
  end
end 

local function list_filter(msg)
  if msg.to.type == 'user' then
    return 'just in group❌'
  end
  local hash = get_filter_hash(msg)
  if hash then
    local names = redis:hkeys(hash)
    local text = '🌐🚀filter word list:\n______________________________\n 
    ⚜💢⚜💢⚜💢⚜💢⚜💢⚜💢⚜💢' 
    for i=1, #names do
      text = text..'> '..names[i]..'\n'
    end
    return text
  end
end

local function get_filter(msg, var_name)
  local hash = get_filter_hash(msg)
  if hash then
    local value = redis:hget(hash, var_name)
    if value == 'msg' then
      return '❌The word you use is prohibited , if repeated will deal with you😼'
    elseif value == 'kick' then
      send_large_msg('chat#id'..msg.to.id, "🔰Speaking to continue dialogue Failure to comply with the rules will be disqualified"❌)
      chat_del_user('chat#id'..msg.to.id, 'user#id'..msg.from.id, ok_cb, true)
    end
  end
end

local function get_filter_act(msg, var_name)
  local hash = get_filter_hash(msg)
  if hash then
    local value = redis:hget(hash, var_name)
    if value == 'msg' then
      return '🚀Warning and pointed to the word⚜'
    elseif value == 'kick' then
      return '⚡️This word is prohibited and will be removed❌'
    elseif value == 'none' then
      return '🔰This word was removed from the filter✅'
    end
  end
end

local function run(msg, matches)
  local data = load_data(_config.moderation.data)
  if matches[1] == "filterlist" or matches[1] == "filter list" then
    return list_filter(msg)
  elseif matches[1] == "filter" or matches[1] == "filter" and matches[2] == ">" then
    if data[tostring(msg.to.id)] then
      local settings = data[tostring(msg.to.id)]['settings']
      if not is_momod(msg) then
        return "🔰you are not moderator❌""
      else
        local value = 'msg'
        local name = string.sub(matches[3]:lower(), 1, 1000)
        local text = save_filter(msg, name, value)
        return text
      end
    end
  elseif matches[1] == "filter" or matches[1] == "filter" and matches[2] == "+" then
    if data[tostring(msg.to.id)] then
      local settings = data[tostring(msg.to.id)]['settings']
      if not is_momod(msg) then
        return "🔰you are not moderator❌""
      else
        local value = 'kick'
        local name = string.sub(matches[3]:lower(), 1, 1000)
        local text = save_filter(msg, name, value)
        return text
      end
    end
  elseif matches[1] == "filter" or matches[1] == "filter" and matches[2] == "-" then
    if data[tostring(msg.to.id)] then
      local settings = data[tostring(msg.to.id)]['settings']
      if not is_momod(msg) then
        return "🔰you are not moderator❌"
      else
        local value = 'none'
        local name = string.sub(matches[3]:lower(), 1, 1000)
        local text = save_filter(msg, name, value)
        return text
      end
    end
  elseif matches[1] == "filter" or matches[1] == "filter" and matches[2] == "?" then
    return get_filter_act(msg, matches[3]:lower())
  else
    if is_sudo(msg) then
      return
    elseif is_admin(msg) then
      return
    elseif is_momod(msg) then
      return
    elseif tonumber(msg.from.id) == tonumber(our_id) then
      return
    else
      return get_filter(msg, msg.text:lower())
    end
  end
end

return {
  description = "Word Filtering", 
  usage = {
  user = {
    "filter ? (word) : مشاهده عکس العمل",
    "filterlist : لیست فیلتر شده ها",
  },
  moderator = {
    "filter > (word) : اخطار کردن لغت",
    "filter + (word) : ممنوع کردن لغت",
    "filter - (word) : حذف از فیلتر",
  },
  },
  patterns = {
    "^[!/#](filter) (.+) (.*)$",
    "^[!/#](filterlist)$",
    "(.*)",
  },
  run = run
}
