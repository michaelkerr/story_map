# story_map.rb
require 'awesome_print'
require 'httparty'
require 'pry'
require 'sinatra'

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

### Bulk Sync Jira/Trello
get '/sync_jt' do
	### Run jira_trello_sync
	ap "Running jira to trello sync....."
	load 'jira_trello_sync.rb'
	ap "Done"
	return "200"
end

### Change in list == component update
post '/component_update' do
	#Get the list of the card in Trello
	#Update the component in Jira
end

post '/list_update' do
	#Get the component of the card from Jira
	#Update the list in Trello
end

### Change in board position
post '/position_update' do
	# if the position in Trello changes
	# Update the issues position in the Jira backlog
end

post '/position_update' do
	# if the position in the backlog changes
	# update the position in the trello board
end

### Get status of update
get '/status' do
	# if the active status in Jira changes (completed, or moved into the active sprint)
	# remove it from the trello board
end

### Update the Card Description
get '/card_description' do
	# if the story description in Jira changes
	# update the description in the Trello Board
	ap "Running jira->trello story update....."
	ap "Done"
	return "200"
end

### Update the Story Description
get '/story_desc' do
	# if the story description in Trello changes
	# update the description in Jira issue
	ap "Running trello->jira story update....."
	ap "Done"
	return "200"
end

### Update the Card Size
get '/card_size' do
	# if the story size in Jira changes
	# update the Trello card
	ap "Running jira->trello size update....."
	ap "Done"
	return "200"
end

### Update the issue Size
get '/issue_size' do
	# if the story size changes in Trello card
	# Update the Jira issues
	ap "Running trello->jira size update....."
	ap "Done"
	return "200"
end