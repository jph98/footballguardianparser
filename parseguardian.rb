#!/usr/bin/env ruby

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require './match'

#
# Football Fixtures/Results Parser for guardian.co.uk
#
class FootballFixturesParser

	attr_accessor :match

	def initialize()    
		@baseurl = "http://www.guardian.co.uk"
		@fixtures = "/football/premierleague/fixtures"
		@results = "/football/premierleague/results"
		@match = Match.new()
		print_banner()
   	end

	# Parse football fixtures/results
   	def parse()
		parse_fixtures()
	end

   	# Parse fixtures
	def parse_fixtures() 
		parse_match_overview(@fixtures, "Fixtures")
	end

	# Parse results
	def parse_results()
		parse_match_overview(@results, "Results")
	end

	# Parse match detail
	private
	def parse_match_details(matchurl)
				
		parse_url = @baseurl + matchurl
		doc = Nokogiri::HTML(open(parse_url))

		puts "Parsing match details from ... " + parse_url + " \n"		
		matchdetail="//p[contains(@class, 'type-7 place-holder')]"

		@match.homescore = get_detail(doc, "Home Score: ", "//h2[contains(@class, 'type-3')]")
		@match.homescorers = get_detail(doc, "Home Scorers (mins) ", "p[@class='home-scorers type-11']")
		@match.awayscore = get_detail(doc, "Away Score: ", "//h2[contains(@class, 'away-team type-3')]")
		@match.awayscorers = get_detail(doc, "Away Scorers (mins) ", "//p[@class='type-11']")

		@match.poshome = get_detail(doc, "Possession Home: ", "//div[contains(@data-stat, 'Possession')]/ol/li/div[contains(@class, 'home-num type-7')]")
		@match.posaway = get_detail(doc, "Possession Away: ", "//div[contains(@data-stat, 'Possession')]/ol/li/div[contains(@class, 'away-num type-7')]")

		@match.gahome = get_detail(doc, "Goal Attempts Home: ", "//div[contains(@data-stat, 'Goal attempts')]/ol/li/div[contains(@class, 'home-num type-7')]")
		@match.gaaway = get_detail(doc, "Goal Attempts Away: ", "//div[contains(@data-stat, 'Goal attempts')]/ol/li/div[contains(@class, 'away-num type-7')]")

		@match.shotshome = get_detail(doc, "Shots on target: ", "//div[contains(@data-stat, 'On target')]/ol/li/div[contains(@class, 'home-num type-7')]")
		@match.shotsaway = get_detail(doc, "Shots off target: ", "//div[contains(@data-stat, 'On target')]/ol/li/div[contains(@class, 'away-num type-7')]")

		@match.cornershome = get_detail(doc, "Corners: ", "//div[contains(@data-stat, 'Corners')]/ol/li/div[contains(@class, 'home-num type-7')]")
		@match.cornersaway = get_detail(doc, "Corners: ", "//div[contains(@data-stat, 'Corners')]/ol/li/div[contains(@class, 'away-num type-7')]")

		@match.foulshome = get_detail(doc, "Fouls: ", "//div[contains(@data-stat, 'Fouls')]/ol/li/div[contains(@class, 'home-num type-7')]")
		@match.foulsaway = get_detail(doc, "Fouls: ", "//div[contains(@data-stat, 'Fouls')]/ol/li/div[contains(@class, 'away-num type-7')]")

		@match.offsideshome = get_detail(doc, "Offsides: ", "//div[contains(@data-stat, 'Offsides')]/ol/li/div[contains(@class, 'home-num type-7')]")
		@match.offsidesaway = get_detail(doc, "Offsides: ", "//div[contains(@data-stat, 'Offsides')]/ol/li/div[contains(@class, 'away-num type-7')]")
	end

	# Parse match overview
	private
	def parse_match_overview(urlpart, type)	

		parse_url = @baseurl.to_s + urlpart
		puts "\nParsing " + type + "... " + parse_url + " \n"
		doc = Nokogiri::HTML(open(parse_url))
		
		beginning_time = Time.now
		matches="//div/ol[contains(@class,'competitions unstyled')]/li/ol[contains(@class,'matches unstyled')]/li"
		details = doc.search(matches).map do |match|			
			
			@match.link = match.at_xpath("a")[:href]
			@match.home = hometeam = match.at("span.match-home").text.strip rescue ''
			@match.away = match.at("span.match-away").text.strip rescue ''
			@match.result = match.at("span.match-result").text.strip rescue ''		
			@match.status = match.at("p.match-status").text.gsub(/\n\s+/,"") rescue ''		

			# Only parse the details (stats) when we want results
			if type == "Results"
				parse_match_details(@match.link)			
			end

			puts "\nParsed match " + type.downcase + " #{@match.inspect}"			
			store(@match)
		end
		end_time = Time.now
		puts "Time elapsed #{(end_time - beginning_time)*1000} milliseconds"
	end	

	# Return the detail for a xpath expression
	private
	def get_detail(doc, desc, xpath)
		details = doc.search(xpath).map do |item|
			detail = item.text.strip rescue ''
			return detail
		end	
	end

	# Store a match (fixtures)
	private
	def store(match)
		
		# What uniquely identifies the match (date, home, away)
	end

	private
	def print_banner()
   		puts"\n|_  _  |  |  _ \n|_)(_) |  | (_)"
   	end

end

parser = FootballFixturesParser.new()
parser.parse()
