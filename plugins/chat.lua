local function run(msg)
if msg.text == "hello" then
  return "Hi honey😍"
end
if msg.text == "iro team" then
  return "🚀the best team🔰"
end
if msg.text == "iro" then
  return "جونم 😼"
end
if msg.text == "bot" then
  return "بله 😼"
end
if msg.text == "Bot" then
  return "جونم😼"
end
if msg.text == "سلام" then
  return "سلام ✋🏻"
end
if msg.text == "slm" then
  return "slm✋🏻"
end
if msg.text == "Slm" then
  return "سلام"
end
if msg.text == "بای" then
  return "بای 👋🏻"
end
if msg.text == "bye" then
  return "Bye👋🏻"
end
if msg.text == "رامین" then
  return "با بابا رامینم چیکار داری؟"
end
if msg.text == "@raminoa" then
  return "با بابا رامینم چیکار داری؟"
end
end

return {
  description = "Chat With Robot Server", 
  usage = "chat with robot",
  patterns = {
    "^hello$",
    "^iro teamم$",
    "^iro$",
    "^[Bb]ot$",
    "^سلام$",
    "^[Ss]lm$",
    "^بای$",
    "^bye$",
    "^رامین$",
    "^@raminoa$",
    }, 
  run = run,
  pre_process = pre_process
}
