#jira.rb
module Jira
	def Jira.active_epics(server, creds)
		api_url = server + "api/latest/"
		search_url = api_url + "search?jql="
		maxResults = 50
		startAt = 0
		count = 0

		all_epics = hash.new 
		
	end

	def Jira.active_issues(server, jira_board, creds)
		api_url = server + "api/latest/"
		search_url = api_url + "search?jql="
		maxResults = 50
		startAt = 0
		count = 0

		all_issues = Hash.new
		params = {:includeHistoricSprints => false, :includeFutureSprints => false}
		sprints_active = Jira.active_sprint("#{server}greenhopper/latest/sprintquery/#{jira_board}", creds, params)
		query_url = search_url + "project = CORE and type in (story, bug) and status != closed&startAt=#{startAt}&maxResults=#{maxResults}"
		new_issues = search_jira(query_url, creds)		
		until startAt > new_issues["total"]
			query_url = search_url + "project = CORE and type in (story, bug) and status != closed&startAt=#{startAt}&maxResults=#{maxResults}"
			new_issues = search_jira(query_url, creds)

			# new_issues = Jira.active_issues(search_url, creds, startAt)
			count = count + new_issues["issues"].count
			puts "Processing = #{count} of #{new_issues["total"].to_s}"
			new_issues["issues"].each do |issue|
				sprints = Jira.sprints_to_list(issue["fields"]["customfield_10007"])
				if (sprints_active & sprints).empty?
					#TODO turn into class
					issue_hash = Hash.new
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
					if !issue["fields"]["customfield_10400"].nil? 
						issue_hash["story_description"] = issue["fields"]["customfield_10400"]
					else
						issue_hash["story_description"] = "As a <user type>, I want to <function or goal>, so that <benefit or reason>\r\n\r\nAcceptance Criteria (Define \"Done\"):"
						#@TODO Update the Jira ticket with this description as well.
					end
					if issue["fields"]["labels"].length > 0
						issue_hash["labels"] = issue["fields"]["labels"]
					end
					all_issues[issue["key"]] = issue_hash
				end
			end
			startAt = new_issues["maxResults"] + new_issues["startAt"]
		end

		return all_issues	
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
				sprints << sprint.split("id=")[1].split("]")[0].to_i
			end
		end
		return sprints
	end

	def Jira.update_issue(url, creds, params)
		response =  HTTParty.put(
			url, 
			:headers => {'Content-Type' => 'application/json'},
			:basic_auth => creds,
			:data => params
		)
		return response
	end
end