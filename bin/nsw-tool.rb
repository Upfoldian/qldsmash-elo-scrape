require 'JSON'
require 'date'

#expect input date, players*

results = JSON.parse(File.read('dump.json'))


results = results["players"]

results = results.select {|player| player["region"] == "New South Wales"}

results.each do |player|

	player["resultData"] = player["resultData"].select do |result| 
		matchDate = Date.strptime(result["date"], "%Y-%m-%d")
		targetDate = Date.strptime(ARGV[0], "%Y-%m-%d")
		targetDate < matchDate
	end
end

puts "Target Date: #{ARGV[0]}, Players: NSW"
results.each do |player|
	puts "Player Name: #{player['name']}"
	puts "\tBeat:"
	wins = player["resultData"].select{|match| match["win?"] == true}
	wins.each do |win|
		puts "\t\t- #{win['opponent']}, (#{win['data']}), #{win['event']}"
	end
	puts "\tLost to:"
	losses = player["resultData"].select{|match| match["win?"] == false}
	losses.each do |loss|
		puts "\t\t- #{loss['opponent']}, (#{loss['data']}), #{loss['event']}"
	end
	puts "=== END PLAYER ==="
end


