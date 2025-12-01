local places = {}

places.lobby = 740581508

places.missions = {
    3200010305,
	2797881676,
	2625195454,
	3590667014,
	2951213182,
	4518266946,
	4661507759,
	4768829954, 
	4134003540,
	3925577908,
	4388762338,
	5071816792,
	5188855685,
	5862433299,
	2215221144,
	7799530284
}

places.place_group = "unknown"

if game.PlaceId == places.lobby then
    places.place_group = "lobby"
elseif table.find(places.missions, game.PlaceId) then
    places.place_group = "mission"
end

return places