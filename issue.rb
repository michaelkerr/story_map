class Issue
	attr_accessor :key, :summary, :component, :size, :description, :labels, :themes
	
	def initialize params
		@key				= params[:key]
		@summary			= params[:summary]
		@component			= params[:component]
		@size				= params[:size]
		@description		= params[:description]
		@labels				= params[:labels]
		@themes				= params[:themes]
	end
end