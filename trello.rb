#trello.rb
module Trello
	def Trello.add_trello(url, query)
		response = HTTParty.post(
			url,
			:headers => {"Content-Type" => "application/json"},
			:query => query
		)
		sleep(1)
		return response
	end

	def Trello.delete_trello(url, query)
		response = HTTParty.delete(
			url,
			:headers => {"Content-Type" => "application/json"},
			:query => query
		)
		sleep(1)
	end

	def Trello.get_cards(url, query, priorities)
		trello_cards = get_trello(url + "/cards", query)
		cards = Hash.new
		trello_cards.each do |entry|
			if !priorities.include?(entry["name"].split(" - ")[0])
				card = Hash.new
				card["name"] = entry["name"]
				card["id"] = entry["id"]
				if entry["labels"].length > 0
					card["size"] = entry["labels"][0]["name"]
				end
				card["list_id"] = entry["idList"]
				card["description"] = entry["desc"]
				cards[entry["name"].split(" - ")[0]] = card
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

	def Trello.put_trello(url, query)
		response = HTTParty.put(
			url,
			:headers => {"Content-Type" => "application/json"},
			:query => query
		)
		sleep(1)
		return response
	end
end