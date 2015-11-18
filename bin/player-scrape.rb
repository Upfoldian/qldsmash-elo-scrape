require 'JSON'
require 'nokogiri'
require 'open-uri'

print "Connecting to QLDSmash HopeDealer..."
resultsPage = Nokogiri::HTML(open("http://qldsmash.com/Players/QLD?p=HopeDealer"))


puts "Connected.\nScrape process started..."
matches = []
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

		matches.push curMatch
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

		matches.push curMatch
	end
end

matches.sort_by do |m|
	m[:date]
end

arr = matches.map do |x| 
	x[:date] = x[:date].to_s
	x
end

puts arr