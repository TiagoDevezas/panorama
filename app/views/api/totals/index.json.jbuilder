json.array! @days_and_totals do |el|
	json.time el[:time]
	json.articles el[:count]
	if @get_percent
		json.percent ((el[:count] / Article.where("pub_date BETWEEN ? AND ?", el[:time].to_datetime, el[:time].to_datetime + 1).count.to_f) * 100 ).round(2)
		if @type
			json.percent ((el[:count] / Article.with_source_type(@type).where("pub_date BETWEEN ? AND ?", el[:time].to_datetime, el[:time].to_datetime + 1).count.to_f) * 100 ).round(2)
		end
	end
	json.twitter_shares el[:twitter_shares]
	json.facebook_shares el[:facebook_shares]
	json.total_shares el[:total_shares]
end

