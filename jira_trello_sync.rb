#jira_trello_sync.rb

require 'awesome_print'
require 'httparty'
require 'open-uri'
require 'pry'
require 'yaml'
require_relative 'jira'
require_relative 'trello'
# require './issue.rb'

### CONFIGURATION
if File.exist?("config/config.yml")
	CONFIG = YAML.load_file("config/config.yml") unless defined? CONFIG
else
	abort("config.yml not found in /config")
end

# LOAD JIRA CONFIG
server = "#{CONFIG["server"]}"
api_url = server + "api/latest/"
search_url = api_url + "search?jql="
creds = { :username => "#{CONFIG["username"]}", :password => "#{CONFIG["password"]}" }
jira_board = "#{CONFIG["jira_board"]}"

# LOAD TRELLO CONFIG
trello_url = "#{CONFIG["trello_base"]}"
trello_board = "#{CONFIG["board_id"]}"
base_query = {:key => "#{CONFIG["app_key"]}", :token => "#{CONFIG["member_token"]}"}
app_secret = "#{CONFIG["app_secret"]}"
priority_cards = ["--1--", "--2--", "--3--", "--4--", "--5--", "--INCOMING--"]


### Current Trello Cards
trello_cards = Trello.get_cards("#{trello_url}boards/#{trello_board}", base_query, priority_cards)
startAt = 0
count = 0
all_issues = Array.new

### Current Active Issues
#@TODO need to get all active issues, not just those that are not in the baord
puts "Getting Active Jira Issues"
params = {:includeHistoricSprints => false, :includeFutureSprints => false}
sprints_active = Jira.active_sprint("#{server}greenhopper/latest/sprintquery/#{jira_board}", creds, params)
new_issues = Jira.active_issues(search_url, creds, trello_cards.keys.join(","), startAt)
until startAt > new_issues["total"]
	new_issues = Jira.active_issues(search_url, creds, trello_cards.keys.join(","), startAt)
	count = count + new_issues["issues"].count
	puts "Processing = #{count} of #{new_issues["total"].to_s}"
	new_issues["issues"].each do |issue|
		sprints = Jira.sprints_to_list(issue["fields"]["customfield_10007"])
		if (sprints_active & sprints).empty?
			#TODO turn into class
			issue_hash = {:key => "", :summary => "", :story_description => ""}
			issue_hash["key"] = issue["key"]
			issue_hash["summary"] = issue["fields"]["summary"]
			begin
				issue_hash["component"] = issue["fields"]["components"][0]["name"]
			rescue
			end
			begin
				issue_hash["size"] = issue["fields"]["customfield_10803"]["value"]
			rescue
			end
			issue_hash["story_description"] = issue["fields"]["customfield_10400"]
			all_issues << issue_hash
		end
	end
	startAt = new_issues["maxResults"] + new_issues["startAt"]
end
puts "#{all_issues.count.to_s} new issue(s) imported"

### Add Active Issues as Cards
#@TODO only add cards that are not in the board
puts "Adding to Trello"
lists = Trello.get_lists("#{trello_url}boards/#{trello_board}/lists", base_query)
added_issues = Array.new
all_issues.each do |issue|
	if issue.has_key?("component")
		### If a list does not exist, create it
		if !lists.has_key?(issue["component"])
			query = base_query.merge({ :name => issue["component"], :idBoard => trello_board, :pos => "bottom" })
			ap "Adding Trello List: " + Trello.add_trello("#{trello_url}boards/#{trello_board}/lists", query)["name"]
			lists = Trello.get_lists("#{trello_url}boards/#{trello_board}/lists", base_query)
			### Add the 5 levels of priority as cards to the new list
			priority_cards.each do |priority|
				query = base_query.merge({ :idList => lists[issue["component"]], :name => priority })
				Trello.add_trello("#{trello_url}cards", query)
				sleep(1)
			end
		end
	else
		issue["component"] = "Unknown"
	end
	Trello.add_trello(trello_url + "cards", base_query.merge({ :idList => lists[issue["component"]], :name => issue["key"] + " - " + issue["summary"], :desc => issue["story_description"], :pos => "bottom"}))
	added_issues << issue["key"]
	sleep(1)
end

### Remove Inactive Cards
#@TODO Remove the cards that are no longer active
