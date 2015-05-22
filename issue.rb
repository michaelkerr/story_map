class Issue
	def initialize(key, summary, component, size, story_description, labels, themes)
		@key				= key
		@summary			= summary
		@component			= component
		@size				= size
		@story_description	= story_description
		@labels				= labels
		@themes				= themes
	end
end