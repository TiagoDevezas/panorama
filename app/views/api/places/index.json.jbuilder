if @district_list
	json.array! @district_list do |district|
	 json.name district[:name]
	 json.fips district[:code]
	 json.count district[:count]
	end
end

if @country_list
	json.array! @country_list do |country|
		json.name country[:name]
		json.alpha2 country[:alpha2] 
		json.alpha3 country[:alpha3]
		json.country_code country[:country_code]
		json.count country[:count]
	end
end