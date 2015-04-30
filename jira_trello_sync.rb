#jira_trello_sync.rb

require 'awesome_print'
require 'httparty'
require 'open-uri'
require 'pry'
require 'yaml'
require_relative 'jira'
require_relative 'trello'

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
size_hash = {"S" => "green", "M" => "yellow", "L" => "orange", "XL" => "red" }

ap "Getting Active Jira Issues"
all_issues = Jira.active_issues(server, jira_board, creds)
puts "#{all_issues.keys.count.to_s} active issue(s)"

### Current Trello Cards and Lists
trello_cards = Trello.get_cards("#{trello_url}boards/#{trello_board}", base_query, priority_cards)
lists = Trello.get_lists("#{trello_url}boards/#{trello_board}/lists", base_query)
if !lists.keys.include?("No Component")
	ap "Adding Trello List: No Component"
	Trello.add_trello("#{trello_url}boards/#{trello_board}/lists", base_query.merge({ :name => "No Component", :idBoard => trello_board, :pos => "bottom" }))
	lists = Trello.get_lists("#{trello_url}boards/#{trello_board}/lists", base_query)
end
#@TODO if new list added and there is no component for it, add it

ap "Adding new cards to Trello..."
all_issues.each do |key, issue|
	if !trello_cards.keys.include?(key)
		if issue.has_key?("component")
			### If a list does not exist, create it
			if !lists.has_key?(issue["component"])
				ap "Adding Trello List: " + Trello.add_trello("#{trello_url}boards/#{trello_board}/lists", base_query.merge({ :name => issue["component"], :idBoard => trello_board, :pos => "bottom" }))["name"]
				lists = Trello.get_lists("#{trello_url}boards/#{trello_board}/lists", base_query)
				### Add the 5 levels of priority as cards to the new list
				priority_cards.each do |priority|
					query = base_query.merge({ :idList => lists[issue["component"]], :name => priority })
					Trello.add_trello("#{trello_url}cards", query)
				end
			end
		else
			issue["component"] = "No Component"
		end
		Trello.add_trello("#{trello_url}cards", base_query.merge({ :idList => lists[issue["component"]], :name => key + " - " + issue["summary"], :desc => issue["story_description"], :labels => [size_hash[issue["size"]]], :pos => "bottom"}))
		#@TODO need to set up webhooks on card creation
		puts "Added #{key} - #{issue["summary"]}"
	end
end
puts "Done."

### Update Jira Issues, components, sizes, remove inactive cards
trello_cards = Trello.get_cards("#{trello_url}boards/#{trello_board}", base_query.merge({ "list" => true }), priority_cards)
trello_cards.each do |key, value|
	if !priority_cards.include?(key)
		# Remove inactive cards
		if !all_issues.keys.include?(key)
			puts "Deleting #{value["name"]}"
			Trello.delete_trello("#{trello_url}cards/#{value["id"]}", base_query)
		else
			# Update the Jira Component
			card_list = lists.invert[value["list_id"]].to_s
			begin
				jira_component = all_issues[key]["component"].to_s
			rescue
				binding.pry
			end
			if (card_list != jira_component) and (card_list != "No Component" or jira_component.nil?)
				if jira_component.length == 0
					data = {"update" => {"components" => [{"add" => {"name" => card_list}}]}}
				else	
					data = {"update" => {"components" => [{"remove" => {"name" => jira_component}}, {"add" => {"name" => card_list}}]}}
				end
				ap "Moving #{key} to #{card_list}"
				response =  HTTParty.put("#{api_url}issue/#{key}", :headers => {'Content-Type' => 'application/json'}, :basic_auth => creds, :body => data.to_json)
			end
			# Update the Jira Size
			if (value.keys.include?("size")) and (value["size"] != all_issues[key]["size"])
				data = {"fields" => {"customfield_10803" => {"value" => value["size"]}}}
				response =  HTTParty.put("#{api_url}issue/#{key}", :headers => {'Content-Type' => 'application/json'}, :basic_auth => creds, :body => data.to_json)
			end
		end
	end
end