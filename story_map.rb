# story_map.rb
require 'awesome_print'
require 'httparty'
require 'pry'
require 'sinatra'
#@TODO turn issue into a class
#@TODO webhooks for issue/card changes
#@TODO add gem file

### CONFIGURATION
if File.exist?("config/config.local.yml")
	CONFIG = YAML.load_file("config/config.local.yml") unless defined? CONFIG
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
priority_cards = [
	"-------------1-------------", 
	"-------------2-------------", 
	"-------------3-------------", 
	"-------------4-------------", 
	"-------------5-------------", 
	"-------------NEW-------------"]
size_hash = {"S" => "green", "M" => "yellow", "L" => "orange", "XL" => "red" }

### Bulk Sync Jira/Trello
get '/sync_jt' do
	### Run jira_trello_sync
	ap "Running jira to trello sync....."
	load 'jira_trello_sync.rb'
	ap "Done"
	return "200"
end

### Trello Card Create 
post '/card_create' do
end

### Trello Story/Bug Card Update
post '/card_update' do
	# Trello => Jira
	# Update Component from list
	# Update Size from label
	# Update Story Description from Description
	# Update Summary from Name
	# Position
end

### Jira issue Update
post '/issue_update' do
	# Jira => Trello
	# Update list from component
	# Update label from Size
	# Update Description from Story Description
	# Update Name from Summary and Key
end

### Trello 
### Jira Theme Update