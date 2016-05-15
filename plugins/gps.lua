do
local function run(msg, matches)
	local lat = matches[2]
	local lon = matches[3]
	local receiver = get_receiver(msg)
	if matches[1] == "loc" then
		send_location(receiver, lat, lon, ok_cb, false)
	elseif matches[1] == "map" then
		local zooms = {10, 16}
		local urls = {}
		for i = 1, #zooms do
			local zoom = zooms[i]
			local url = "http://maps.googleapis.com/maps/api/staticmap?zoom=" .. zoom .. "&size=600x300&maptype=roadmap&center=" .. lat .. "," .. lon .. "&markers=color:blue%7Clabel:X%7C" .. lat .. "," .. lon
			table.insert(urls, url)
		end
		send_photos_from_url(receiver, urls)
	elseif matches[1] == "view" then
		local zooms = {12, 18}
		local urls = {}
		for i = 1, #zooms do
			local zoom = zooms[i]
			local url = "http://maps.googleapis.com/maps/api/staticmap?zoom=" .. zoom .. "&size=600x300&maptype=hybrid&center=" .. lat .. "," .. lon .. "&markers=color:blue%7Clabel:X%7C" .. lat .. "," .. lon
			table.insert(urls, url)
		end
		send_photos_from_url(receiver, urls)
	elseif matches[1] == "link" then
		return "🌐💢Location in Google Map:\nhttps://www.google.com/maps/place/" .. lat .. "," .. lon
	end  
end

return {
	description = "Generate Map for GPS Coordinates", 
	usagehtm = '<tr><td align="center">gps loc Latitude, Longitude</td><td align="right">Show location coordinates entered in a location</td></tr>'
		..'<tr><td align="center">gps link Latitude, Longitude</td><td align="right">Providing the coordinates into Google Maps link</td></tr>'
		..'<tr><td align="center">gps map Latitude, Longitude</td><td align="right">View map coordinates entered in a photo</td></tr>'
		..'<tr><td align="center">gps view Latitude, Longitude</td><td align="right">View live images spatial coordinates entered in a photo</td></tr>',
	usage = {
		"gps loc (lat,lon) : Situation locations",
		"gps link (lat,lon) : google map link",
		"gps map (lat,lon) : Location map",
		"gps view (lat,lon) : Real picture",
	},
	patterns = {
		"^[/#!]([Gg]ps) (loc) ([^,]*)[,%s]([^,]*)$",
		"^[/#!]([Gg]ps) (map) ([^,]*)[,%s]([^,]*)$",
		"^[/#!]([Gg]ps) (view) ([^,]*)[,%s]([^,]*)$",
		"^[/#!]([Gg]ps) (link) ([^,]*)[,%s]([^,]*)$",
	}, 
	run = run 
}
end
