
do

function run(msg, matches)
  return [[ 
Capitan Deadpool version 1.0.0 🚀
_________________________
Sudo User: @Raminea 👔👑
Bot User: @cpd_bot 🤖
_________________________
Sudo ID:195092846
Bot ID:212899738
_________________________
⚜Team Members: Amin,Ramin 💯
_________________________
CPD Team PV bot: @CPD_PV_bot 🏈
_________________________
Based on TeleSeed☘
_________________________
CPD Api Bot: @CPD_ROBOT 👾
_________________________
github addres: https://github.com/raminea/Capitan-DeadPool 🇮🇷
_________________________
Bot Launguage: English 🔠
_________________________
Thanks To:
Saeed
Rastin
Zaniar
 and more...]]
end

return {
  description = "Shows bot version", 
  usage = "ver: Shows bot version",
  patterns = {
    "^[/!#](cpd)$"
  }, 
  run = run 
}

end
