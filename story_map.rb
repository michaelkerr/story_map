# story_map.rb
require 'awesome_print'
require 'httparty'
require 'pry'
require 'sinatra'


### Bulk Sync Jira/Trello
get '/sync_jt' do
	### Run jira_trello_sync
	ap "Running jira/trello sync....."
	load 'jira_trello_sync.rb'
	ap "Done"
	return "200"
end

### Change in list == component update
post '/component' do
	#Get the list of the card
	#Update the component in 
end

### Change in board position
post '/position' do

end

### Get status of update
get '/status' do

end