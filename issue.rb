class Issue
	attr_accessor :key, :summary, :component, :size, :description, :labels, :themes
	
	def initialize(key, summary, component, size, description, labels, themes)
		@key			= key
		@summary		= summary
		@component		= component
		@size			= size
		@description	= description
		@labels			= labels
		@themes			= themes
	end
end