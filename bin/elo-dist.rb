require 'JSON'
require 'date'

#expect input date, players*

results = JSON.parse(File.read('dump.json'))


results = results["players"]

results = results.select {|player| player["region"] == "New South Wales"}

results.each do |player|

	#player["resultData"] = player["resultData"].select do |result| 
	#	matchDate = Date.strptime(result["date"], "%Y-%m-%d")
	#	targetDate = Date.strptime(ARGV[0], "%Y-%m-%d")
	#	targetDate < matchDate
	#end
end

puts "Players: NSW"
puts "elo\t\tsets\tname"
puts ""
results.each do |player|

	elo = player["elo"]
	name = player["name"]
	numGames = player["resultData"].size

	puts "#{elo}\t#{numGames}\t\t#{name}"
end



