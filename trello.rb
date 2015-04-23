#trello.rb
module Trello
	def Trello.add_trello(url, query)
		return HTTParty.post(
			url,
			:headers => {"Content-Type" => "application/json"},
			:query => query
		)
	end

	def Trello.get_cards(url, query, priorities)
		# card = { :name => "", :labels => Array.new }
		trello_cards = get_trello(url + "/cards", query)
		cards = Hash.new
		trello_cards.each do |entry|
			if !priorities.include?(entry["name"].split(" - ")[0])
				cards[entry["name"].split(" - ")[0]] = entry["id"]
			end
		end
		return cards
	end

	def Trello.get_lists(url, query)
		list_data = get_trello(url, query)
		list_hash = Hash.new
		list_data.each do |entry|
			list_hash[entry["name"]] = entry["id"]
		end
		return list_hash
	end

	def Trello.get_trello(url, query)
		response =  HTTParty.get(
			url,
			:headers => {"Content-Type" => "application/json"},
			:query => query
		)
		return JSON.parse(response.body)
	end
end