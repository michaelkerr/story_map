class Issue
	attr_accessor :key, :summary, :component, :size, :description, :labels, :themes
	
	def initialize params
		self.key			= params[:key]
		self.summary		= params[:summary]
		self.component		= params[:component]
		self.size			= params[:size]
		self.description	= params[:description]
		self.labels			= params[:labels]
		self.themes			= params[:themes]
	end
end