local database = 'http://umbrella.shayan-soft.ir/txt/'
local function run(msg)
	local res = http.request(database.."jomlak.db")
	if string.match(res, '@CPDteam') then res = string.gsub(res, '@CPDteam', "")
 end
	local jomlak = res:split(",")
	return jomlak[math.random(#jomlak)]
end

return {
	description = "500 Persian Jomlak",
	usage = "jomlak : send random jomlak",
	patterns = {"^[/!#]([Jj]omlak$)"},
	run = run
}
--plugin by shayan ahmadi
