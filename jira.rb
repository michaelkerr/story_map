#jira.rb
module Jira
	def Jira.active_issues(url, creds, keys, startAt)
		#TODO Add support for multiple projects
		maxResults = 50
		query_url = url + "issuekey not in (#{keys}) and project = CORE and type in (story, bug) and status != closed&startAt=#{startAt}&maxResults=#{maxResults}"
		response = search_jira(query_url, creds)
		if keys.length == 0
			query_url = url + "project = CORE and type in (story, bug) and status != closed&startAt=#{startAt}&maxResults=#{maxResults}"
			response = search_jira(query_url, creds)
		end
		return response		
	end

	def Jira.active_sprint(url, creds, query)
		response =  HTTParty.get(
			url, 
			:headers => {'Content-Type' => 'application/json'},
			:basic_auth => creds,
			:query => query
		)
		sprints = JSON.parse(response.body)["sprints"]
		active_sprints = Array.new
		sprints.each do |sprint|
			if sprint["state"] == "ACTIVE"
				active_sprints << sprint["id"]
			end
		end
		return active_sprints
	end

	def Jira.search_jira(url, creds)
		response =  HTTParty.get(
			URI::encode(url), 
			:headers => {'Content-Type' => 'application/json'},
			:basic_auth => { :username => creds[:username], :password => creds[:password] },
		)
		return JSON.parse(response.body)
	end

	def Jira.sprints_to_list(issue_sprints)
		sprints = Array.new
		if issue_sprints != nil
			issue_sprints.each do |sprint|
				sprints << sprint.split(",id=")[1].split("]")[0].to_i
			end
		end
		return sprints
	end
end