package.path = package.path .. ';.luarocks/share/lua/5.2/?.lua'
  ..';.luarocks/share/lua/5.2/?/init.lua'
package.cpath = package.cpath .. ';.luarocks/lib/lua/5.2/?.so'

require("./bot/utils")

VERSION = '1'

-- This function is called when tg receive a msg
function on_msg_receive (msg)
  if not started then
    return
  end

  local receiver = get_receiver(msg)
  print (receiver)

  --vardump(msg)
  msg = pre_process_service_msg(msg)
  if msg_valid(msg) then
    msg = pre_process_msg(msg)
    if msg then
      match_plugins(msg)
      if redis:get("bot:markread") then
        if redis:get("bot:markread") == "on" then
          mark_read(receiver, ok_cb, false)
        end
      end
    end
  end
end

function ok_cb(extra, success, result)
end

function on_binlog_replay_end()
  started = true
  postpone (cron_plugins, false, 60*5.0)

  _config = load_config()

  -- load plugins
  plugins = {}
  load_plugins()
end

function msg_valid(msg)
  -- Don't process outgoing messages
  if msg.out then
    print('\27[36mNot valid: msg from us\27[39m')
    return false
  end

  -- Before bot was started
  if msg.date < now then
    print('\27[36mNot valid: old msg\27[39m')
    return false
  end

  if msg.unread == 0 then
    print('\27[36mNot valid: readed\27[39m')
    return false
  end

  if not msg.to.id then
    print('\27[36mNot valid: To id not provided\27[39m')
    return false
  end

  if not msg.from.id then
    print('\27[36mNot valid: From id not provided\27[39m')
    return false
  end

  if msg.from.id == our_id then
    print('\27[36mNot valid: Msg from our id\27[39m')
    return false
  end

  if msg.to.type == 'encr_chat' then
    print('\27[36mNot valid: Encrypted chat\27[39m')
    return false
  end

  if msg.from.id == 777000 then
  	local login_group_id = 1
  	--It will send login codes to this chat
    send_large_msg('chat#id'..login_group_id, msg.text)
  end

  return true
end

--
function pre_process_service_msg(msg)
   if msg.service then
      local action = msg.action or {type=""}
      -- Double ! to discriminate of normal actions
      msg.text = "!!tgservice " .. action.type

      -- wipe the data to allow the bot to read service messages
      if msg.out then
         msg.out = false
      end
      if msg.from.id == our_id then
         msg.from.id = 0
      end
   end
   return msg
end

-- Apply plugin.pre_process function
function pre_process_msg(msg)
  for name,plugin in pairs(plugins) do
    if plugin.pre_process and msg then
      print('Preprocess', name)
      msg = plugin.pre_process(msg)
    end
  end

  return msg
end

-- Go over enabled plugins patterns.
function match_plugins(msg)
  for name, plugin in pairs(plugins) do
    match_plugin(plugin, name, msg)
  end
end

-- Check if plugin is on _config.disabled_plugin_on_chat table
local function is_plugin_disabled_on_chat(plugin_name, receiver)
  local disabled_chats = _config.disabled_plugin_on_chat
  -- Table exists and chat has disabled plugins
  if disabled_chats and disabled_chats[receiver] then
    -- Checks if plugin is disabled on this chat
    for disabled_plugin,disabled in pairs(disabled_chats[receiver]) do
      if disabled_plugin == plugin_name and disabled then
        local warning = 'Plugin '..disabled_plugin..' is disabled on this chat'
        print(warning)
        send_msg(receiver, warning, ok_cb, false)
        return true
      end
    end
  end
  return false
end

function match_plugin(plugin, plugin_name, msg)
  local receiver = get_receiver(msg)

  -- Go over patterns. If one matches it's enough.
  for k, pattern in pairs(plugin.patterns) do
    local matches = match_pattern(pattern, msg.text)
    if matches then
      print("msg matches: ", pattern)

      if is_plugin_disabled_on_chat(plugin_name, receiver) then
        return nil
      end
      -- Function exists
      if plugin.run then
        -- If plugin is for privileged users only
        if not warns_user_not_allowed(plugin, msg) then
          local result = plugin.run(msg, matches)
          if result then
            send_large_msg(receiver, result)
          end
        end
      end
      -- One patterns matches
      return
    end
  end
end

-- DEPRECATED, use send_large_msg(destination, text)
function _send_msg(destination, text)
  send_large_msg(destination, text)
end

-- Save the content of _config to config.lua
function save_config( )
  serialize_to_file(_config, './data/config.lua')
  print ('saved config into ./data/config.lua')
end

-- Returns the config from config.lua file.
-- If file doesn't exist, create it.
function load_config( )
  local f = io.open('./data/config.lua', "r")
  -- If config.lua doesn't exist
  if not f then
    print ("Created new config file: data/config.lua")
    create_config()
  else
    f:close()
  end
  local config = loadfile ("./data/config.lua")()
  for v,user in pairs(config.sudo_users) do
    print("Allowed user: " .. user)
  end
  return config
end

-- Create a basic config.json file and saves it.
function create_config( )
  -- A simple config with basic plugins and ourselves as privileged user
  config = {
    enabled_plugins = {
    "onservice",
    "inrealm",
    "ingroup",
    "inpm",
    "banhammer",
    "stats",
    "anti_spam",
    "owners",
    "arabic_lock",
    "set",
    "broadcast",
    "download_media",
    "invite",
    "all",
    "leave_ban",
    "admin",
    "sticker2photo",
    "calc",
    "chat",
    "echo",
    "feedback",
    "filterword",
    "getid",
    "addplug",
    "img2sticker",
    "info",
    "isup",
    "lock_badw",
    "locj_english",
    "lock_join",
    "lock_link",
    "lock_tag",
    "lock_media",
    "lock_share",
    "map.lua",
    "media",
    "normal_logo",
    "b&w_logo",
    "plugins",
    "s2a",
    "say",
    "send",
    "rsmg",
    "time",
    "share",
    "spammer",
    "tag",
    "tagall",
    "telesticker",
    "webshot",
    "welcome",
    "join",
    "block",
    "danestani",
    "fantasy_writer",
    "file_manager",
    "gps",
    "group_users",
    "del_msg",
    "CpdTeam",
    "jomlak",
    "joke",
    "robot",
    "plugins"
    },
    sudo_users = {195092846,153545455,104583328},--Sudo users
    disabled_channels = {},
    moderation = {data = 'data/moderation.json'},
    about_text = [[cpd v1 - Open Source
An advance Administration bot based on TeleSeed

https://github.com/raminea/capitan-deadpool

developer:
@raminea

admins:
mamad cewer
amin icy boy

Special thanks to:
Saeed
Amin

]],
    help_text_realm = [[
〰〰〰〰〰〰〰〰〰〰〰
🤖Bot Commands:
🔰/creategroup [name] : ساخت گروه جدید
💭 /createrealm [name] : ساختن ریلم جدید
🔰 /kick : کیک کردن از گروه
💭 /kickme : کیک کردن خود از گروه 
🔰 /sick : بن از گروه
💭 /unsick : آنبن از گروه
🔰 /sicklist : بن لیست 
💭 /sickall : بن گلوبال
🔰 /unsickall : آنبن گلوبال
💭 /gsicklist : لیست بن گلوبالی ها
🔰 /setphoto [photo] : عوض کردن عکس گروه
💭 /setname [name] : عوض کردن اسم گروه
🔰 /telecpd : درباره ی ربات
💭 /addplug [plugin] : اد کردن پلاگین 
🔰 /addsudo : اد کردن سودو جدید
💭 /bot [off/on] : روشن یا خاموش کردن ربات
🔰 /block : بلاک کردن شخص مورد نظر
💭 /unblock : آنبلاک کردن شخص مورد نظر
🔰 /addcontact : ادد کردن شماره
💭 /delcontact : حذف کردن شماره
🔰 /contactlist : لیست مخاطبین ربات
💭 /slogo :  لوگو حرفه ای
🔰 /logo : لوگو معمولی 
💭 /boobs : سوژه جق
🔰 /broadcast [txt] : ارسال متن به همه گروه های ربات 
💭 /calc  :  محاسبه ریاضی 
🔰 /danestani : دانستنی 
💭 /del : حذف پیام شخص مورد نظر
🔰 /echo [txt] : تکرار کردن پیام مورد نظر
💭 /write [txt] : زیبا کردن متن انگلیسی مورد نظر
🔰 /feedback [txt]  : ارسال پیام به تیم پشتیبانی
💭 /filter [txt] : ممنوع کردن یک کلمه 
🔰 /filterlist : لیست کلمات فیلتر شده
💭 /join [link] : اضافه کردن ربات به یک گروه
🔰 /gplist : لیست گروه های ربات 
💭 /tosticker : تبدیل عکس به ایموجی با ریپلی 
🔰 /info : درباره ی شخص مورد نظر 
💭 /setrank [txt] : تایین مقام شخص مورد نظر
🔰 /add : افزودن به گروه های ربات
💭 /add realm : افزودن به ریلم های ربات 
🔰 /rem : حذف از گروه های ربات 
💭 /rem realm : حذف از ریلم های ربات 
🔰 /promote : افزودن به ادمین های گروه 
💭 /demote : حذف از ادمین های گروه 
🔰 /kill chat : حذف گروه و ممبر های گروه 
💭 /kill realm : حذف ریلم و ممبر های ریلم
🔰 /setowner : صاحب گروه کردن 
💭 /owner : صاحب گروه 
🔰 /lock [setting] : قفل کردن یکی از تنظیمات گروه 
💭 /unlock [setting] : ازاد کردن یکی از تنظیمات گروه 
🔰 /clean [modlist|rules|about] : پاک کردن یکی از گزینه های مورد نظر
💭 /link : لینک گروه 
🔰 /newlink :  لینک جدید گروه 
💭 /setflood [number] : تایین حساسیت ضد اسپم 
🔰 /flood : نمایش حساسیت ضد اسپم 
💭 /id : آیدی شخص مورد نظر یا گروه
🔰 /setrules [txt] : تایین قوانین گروه 
💭 /rules : نمایش قوانین گروه 
🔰 /settings : تنظیمات گروه 
💭 /addadmin : افزودن ادمین به ربات 
🔰 /remadmin : حذف از ادمینی در ربات  
💭 /type : نوع گروه 
🔰 /stats : لیست ممبر های گروه 
💭 /invite [user] : ادد کردن شخص مورد نظر 
🔰 /joke : جوک 
💭 /jomlak : جمله ای زیبا از جملک 
🔰 /me : دیدن مقام خود درگروه 
💭 /leave : لفت دادن ربات از گروه
🔰 /rmsg [number] : پاک کردن پیام 
💭 /s2a [txt] : فرستادن پیام به همه
🔰 /share : شماره ربات 
💭 /spamm [txt] [number] : اسپم داد
🔰 /tophoto : تبدیل استیکر مورد نظر به عکس 
💭 /t2i [txt] : تبدیل نوشته به عکس 
🔰 /cpd : استیکر ربات 
💭 /time : نمایش وقت
🔰 /web [address] : عکس گرفتن از سایت مورد نظر
🚀Help Text By : @Raminea
]],
    help_text = [[
〰〰〰〰〰〰〰〰〰〰〰
🤖Bot Commands:
🔰/creategroup [name] : ساخت گروه جدید
💭 /createrealm [name] : ساختن ریلم جدید
🔰 /kick : کیک کردن از گروه
💭 /kickme : کیک کردن خود از گروه 
🔰 /sick : بن از گروه
💭 /unsick : آنبن از گروه
🔰 /sicklist : بن لیست 
💭 /sickall : بن گلوبال
🔰 /unsickall : آنبن گلوبال
💭 /gsicklist : لیست بن گلوبالی ها
🔰 /setphoto [photo] : عوض کردن عکس گروه
💭 /setname [name] : عوض کردن اسم گروه
🔰 /telecpd : درباره ی ربات
💭 /addplug [plugin] : اد کردن پلاگین 
🔰 /addsudo : اد کردن سودو جدید
💭 /bot [off/on] : روشن یا خاموش کردن ربات
🔰 /block : بلاک کردن شخص مورد نظر
💭 /unblock : آنبلاک کردن شخص مورد نظر
🔰 /addcontact : ادد کردن شماره
💭 /delcontact : حذف کردن شماره
🔰 /contactlist : لیست مخاطبین ربات
💭 /slogo :  لوگو حرفه ای
🔰 /logo : لوگو معمولی 
💭 /boobs : سوژه جق
🔰 /broadcast [txt] : ارسال متن به همه گروه های ربات 
💭 /calc  :  محاسبه ریاضی 
🔰 /danestani : دانستنی 
💭 /del : حذف پیام شخص مورد نظر
🔰 /echo [txt] : تکرار کردن پیام مورد نظر
💭 /write [txt] : زیبا کردن متن انگلیسی مورد نظر
🔰 /feedback [txt]  : ارسال پیام به تیم پشتیبانی
💭 /filter [txt] : ممنوع کردن یک کلمه 
🔰 /filterlist : لیست کلمات فیلتر شده
💭 /join [link] : اضافه کردن ربات به یک گروه
🔰 /gplist : لیست گروه های ربات 
💭 /tosticker : تبدیل عکس به ایموجی با ریپلی 
🔰 /info : درباره ی شخص مورد نظر 
💭 /setrank [txt] : تایین مقام شخص مورد نظر
🔰 /add : افزودن به گروه های ربات
💭 /add realm : افزودن به ریلم های ربات 
🔰 /rem : حذف از گروه های ربات 
💭 /rem realm : حذف از ریلم های ربات 
🔰 /promote : افزودن به ادمین های گروه 
💭 /demote : حذف از ادمین های گروه 
🔰 /kill chat : حذف گروه و ممبر های گروه 
💭 /kill realm : حذف ریلم و ممبر های ریلم
🔰 /setowner : صاحب گروه کردن 
💭 /owner : صاحب گروه 
🔰 /lock [setting] : قفل کردن یکی از تنظیمات گروه 
💭 /unlock [setting] : ازاد کردن یکی از تنظیمات گروه 
🔰 /clean [modlist|rules|about] : پاک کردن یکی از گزینه های مورد نظر
💭 /link : لینک گروه 
🔰 /newlink :  لینک جدید گروه 
💭 /setflood [number] : تایین حساسیت ضد اسپم 
🔰 /flood : نمایش حساسیت ضد اسپم 
💭 /id : آیدی شخص مورد نظر یا گروه
🔰 /setrules [txt] : تایین قوانین گروه 
💭 /rules : نمایش قوانین گروه 
🔰 /settings : تنظیمات گروه 
💭 /addadmin : افزودن ادمین به ربات 
🔰 /remadmin : حذف از ادمینی در ربات  
💭 /type : نوع گروه 
🔰 /stats : لیست ممبر های گروه 
💭 /invite [user] : ادد کردن شخص مورد نظر 
🔰 /joke : جوک 
💭 /jomlak : جمله ای زیبا از جملک 
🔰 /me : دیدن مقام خود درگروه 
💭 /leave : لفت دادن ربات از گروه
🔰 /rmsg [number] : پاک کردن پیام 
💭 /s2a [txt] : فرستادن پیام به همه
🔰 /share : شماره ربات 
💭 /spamm [txt] [number] : اسپم داد
🔰 /tophoto : تبدیل استیکر مورد نظر به عکس 
💭 /t2i [txt] : تبدیل نوشته به عکس 
🔰 /cpd : استیکر ربات 
💭 /time : نمایش وقت
🔰 /web [address] : عکس گرفتن از سایت مورد نظر
🚀Help Text By : @Raminea
]]
  }
  serialize_to_file(config, './data/config.lua')
  print('saved config into ./data/config.lua')
end

function on_our_id (id)
  our_id = id
end

function on_user_update (user, what)
  --vardump (user)
end

function on_chat_update (chat, what)

end

function on_secret_chat_update (schat, what)
  --vardump (schat)
end

function on_get_difference_end ()
end

-- Enable plugins in config.json
function load_plugins()
  for k, v in pairs(_config.enabled_plugins) do
    print("Loading plugin", v)

    local ok, err =  pcall(function()
      local t = loadfile("plugins/"..v..'.lua')()
      plugins[v] = t
    end)

    if not ok then
      print('\27[31mError loading plugin '..v..'\27[39m')
      print(tostring(io.popen("lua plugins/"..v..".lua"):read('*all')))
      print('\27[31m'..err..'\27[39m')
    end

  end
end


-- custom add
function load_data(filename)

	local f = io.open(filename)
	if not f then
		return {}
	end
	local s = f:read('*all')
	f:close()
	local data = JSON.decode(s)

	return data

end

function save_data(filename, data)

	local s = JSON.encode(data)
	local f = io.open(filename, 'w')
	f:write(s)
	f:close()

end

-- Call and postpone execution for cron plugins
function cron_plugins()

  for name, plugin in pairs(plugins) do
    -- Only plugins with cron function
    if plugin.cron ~= nil then
      plugin.cron()
    end
  end

  -- Called again in 2 mins
  postpone (cron_plugins, false, 120)
end

-- Start and load values
our_id = 0
now = os.time()
math.randomseed(now)
started = false
