#issue.rb

class Issue
	attr_accessor :key, :summary, :component, :size, :description, :sprints
	def initialize(key, summary, component, size, description, sprints)
		@key = key
		@summary = summary
		@component = component
		@size = size
		@description = description
		@sprints = sprints
	end

	def self.create_issue(key, summary, component, size, description, sprints)
	end
end