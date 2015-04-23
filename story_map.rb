# story_map.rb

module storymap
	def storymap.parse_issues()
		# puts "Getting New Jira Issues"
		# until startAt > new_issues["total"]
		# 	### Get the new jira issues
		# 	new_issues = new_jira(search_url, creds, project_key, startAt)

		# 	puts "Total Issues = " + new_issues["total"].to_s
		# 	count = count + new_issues["issues"].count
		# 	puts "Processing = #{count} of #{new_issues["total"].to_s}"

		# 	new_issues["issues"].each do |issue|
		# 		#TODO turn into class
		# 		issue_hash = Hash.new
		# 		issue_hash["key"] = issue["key"]
		# 		issue_hash["summary"] = issue["fields"]["summary"]
		# 		begin
		# 			issue_hash["component"] = issue["fields"]["components"][0]["name"]
		# 		rescue
		# 		end
		# 		begin
		# 			epic_id = issue["fields"]["customfield_10008"]
		# 			issue_hash["epic"] = { epic_id => get_issues(search_url + "issuekey = #{epic_id}", creds)["issues"][0]["fields"]["summary"] }
		# 		rescue
		# 		end
		# 		issue_hash["story_description"] = issue["fields"]["customfield_10400"]
		# 		all_issues << issue_hash
		# 	end

		# 	remaining = remaining - new_issues["issues"].count
		# 	startAt = new_issues["maxResults"] + new_issues["startAt"]
		# 	puts "#{remaining} issues remaining"
		# end
		# puts "#{all_issues.count.to_s} new issue(s) imported"
	end
end