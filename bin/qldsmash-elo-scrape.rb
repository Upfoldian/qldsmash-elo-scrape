require 'JSON'
require 'nokogiri'
require 'open-uri'

print "Connecting to QLDSmash..."
eloPage = Nokogiri::HTML(open("http://qldsmash.com/Elo/SSBU"))


puts "Connected.\nScrape process started..."
players = {:players => []}
i = 0
eloPage.xpath("//tr[@class='rating-row']").each do |player|

	newPlayer = {:name => "", :region => "", :elo => 0, :nationalRank => "", :regionalRank => "", :mains => [], :link => "",  :resultData => []}
	playerInfo = player.xpath("td")

	newPlayer[:nationalRank] = playerInfo[1].xpath("span[@class='elo-national']").text.strip
	newPlayer[:regionalRank] = playerInfo[1].xpath("span[@class='elo-local']").text.strip

	newPlayer[:elo] = playerInfo[2].xpath("text()").to_s.strip.to_i

	newPlayer[:region] = playerInfo[3].xpath("img/@alt").text.strip

	newPlayer[:name] = playerInfo[4].xpath("a/text()").to_s.strip
	newPlayer[:link] = "http://qldsmash.com" + playerInfo[4].xpath("a/@href").text.strip

	newPlayer[:mains] = playerInfo[5].xpath("img/@alt").map{|x| x.to_s.strip}

	
	resultsPage = Nokogiri::HTML(open(newPlayer[:link]))
	resultsData = []

	matchData = resultsPage.xpath("//div[@class='panel match-history  panel-success']").each do |match|
		#only win data, changes opponent locations from "col-xs-5" to just "col-xs-5 text-right"

		curMatch = {:event => "", :date => Date.new, :opponent => "", :opponentElo => 0, :win? => false, :data => ""}

		if match.xpath("@data-filter-game").to_s.strip == "SSBU"
			curMatch[:win?] = true
			curMatch[:opponentElo] = match.xpath("@data-filter-opponent").to_s.strip.to_i
			curMatch[:event] = match.xpath("div[@class='panel-heading']/a/text()").to_s.strip
			curMatch[:data] = match.xpath("div[@class='panel-body']/div[@class='row']/div[@class='col-xs-2 text-center']").text.strip
			curMatch[:opponent] = match.xpath("div[@class='panel-body']/div[@class='row']/div[@class='col-xs-5 text-right']/div/a/text()").to_s.strip
			date = match.xpath("div[@class='panel-footer']/div[@class='row']/div[@class='col-xs-6 text-right']").text.strip
			curMatch[:date] = Date.strptime(date, '%d/%m/%Y')

			resultsData.push curMatch
		end
	end

	matchData = resultsPage.xpath("//div[@class='panel match-history  panel-danger']").each do |match|
		#only loss data, changes opponent locations from "col-xs-5 text-right" to just "col-xs-5"
		curMatch = {:event => "", :date => Date.new, :opponent => "", :opponentElo => 0, :win? => false, :data => ""}

		if match.xpath("@data-filter-game").to_s.strip == "SSBU"
			curMatch[:win?] = false
			curMatch[:opponentElo] = match.xpath("@data-filter-opponent").to_s.strip.to_i
			curMatch[:event] = match.xpath("div[@class='panel-heading']/a/text()").to_s.strip
			curMatch[:data] = match.xpath("div[@class='panel-body']/div[@class='row']/div[@class='col-xs-2 text-center']").text.strip
			curMatch[:opponent] = match.xpath("div[@class='panel-body']/div[@class='row']/div[@class='col-xs-5']/div/a/text()").to_s.strip
			date = match.xpath("div[@class='panel-footer']/div[@class='row']/div[@class='col-xs-6 text-right']").text.strip
			curMatch[:date] = Date.strptime(date, '%d/%m/%Y')

			resultsData.push curMatch
		end
	end

	resultsData.sort_by do |m|
		m[:date]
	end

	arr = resultsData.map do |x| 
		x[:date] = x[:date].to_s
		x
	end

	resultsData = arr

	newPlayer[:resultData] = resultsData

	players[:players].push(newPlayer)
	puts newPlayer[:nationalRank]
	i+=1
	break if i > 200
end
File.open("dump.json", 'w') { |file| file.write(JSON.pretty_generate(players))}

puts "Scrape finished!"





