module Api
	class PlacesController < ApplicationController
		caches_action :index, cache_path: Proc.new {|c| c.params.except(:callback) }, expires_in: 6.hour
		
		helper_method :convert_to_fips, :get_article_count, :check_for_dates
		respond_to :json


		def index
			map_type = params[:map]
			lang = params[:lang] || 'pt'
			list = params[:listOnly]

			if !map_type || map_type.downcase == 'portugal'
				@district_list = []
				Country.find_country_by_name('Portugal').subdivisions.each do |sub|
					sub[1]['name'] = 'Açores'  if sub[0].to_s == '20'  
					sub[1]['name'] = 'Madeira' if sub[0].to_s == '30' 

					code = sub[0]
					name = sub[1]['name']

					if(list && list == 'true')
						count = 0
					else
						count = get_article_count(name) if name
					end
					# count = Article.find_articles_with(name).count
					@district_list << Hash[
						name: name || nil,
						code: convert_to_fips(code),
						count: count || 0
					]
				end
			elsif map_type == 'world'
				@country_list = []
				countries = Country.all
				countries.each do |name, alpha2|
					country = Country.find_country_by_alpha2(alpha2)
					country_name = country.translation(lang) ? country.translation(lang).split(',')[0] : nil
					alpha2_code = country.alpha2
					alpha3_code = country.alpha3
					country_code = country.country_code
					
					if alpha3_code.to_s == 'RUS'
						if lang == 'en'
							country_name = 'Russia'
						end
						if lang == 'pt'
							country_name = 'Rússia'
						end
					end

					if alpha3_code.to_s == 'GBR' && lang == "en"
						country_name = 'UK'
					end

					if(list && list == 'true')
						count = 0
					else
						count = get_article_count(country_name) if country_name
					end
					# count = Article.find_articles_with(country_name).count if country_name
					@country_list << Hash[
						name: country_name || nil,
						alpha2: alpha2_code || nil,
						alpha3: alpha3_code || nil,
						country_code: country_code || nil,
						count: count || nil
					]
				end
			end

		end

		def get_article_count(query)
			source = params[:source]
			type = params[:type]
			if source
				source = Source.where(name: source).empty? ? Source.where(acronym: source).first : Source.where(name: source).first
				count = check_for_dates(source.articles, query)
				# count = source.articles.find_articles_with(query).count
			elsif type
				count = check_for_dates(Article.with_source_type(type), query)
				# count = Article.with_source_type(type).find_articles_with(query).count
			else
				count = check_for_dates(Article, query)
				# count = Article.find_articles_with(query).count
			end

		end

		def check_for_dates(articles, query)
			start_date = params[:since]
			end_date = params[:until]
			q = params[:q]

			if q
				# query = query.gsub(/'/, {"'" => "\\'"})
				# query = "'#{query}' & '#{q}'"
				query = query + " " + q
			end

			if start_date && !end_date
				count = articles.find_articles_with(query).where('pub_date >= ?', start_date.to_datetime).count
			end

			if end_date && !start_date
				count = articles.find_articles_with(query).where('pub_date <= ?', end_date.to_datetime + 1.day).count
			end

			if start_date && end_date
				count = articles.find_articles_with(query).where(
					'pub_date BETWEEN ? AND ?', start_date.to_datetime, end_date.to_datetime + 1.day
				).count
			end

			if !start_date && !end_date
				count = articles.find_articles_with(query).count
			end
			count
		end

		def convert_to_fips(code)
			code = code.to_s
			one_to_eight = (1..8).to_a.map { |el| '0' + el.to_s }
			twelve_to_eighteen = (12..18).to_a.map { |el| el.to_s }
			if code == "20"
				return "PO23"
			end
			if code == "30"
				return "PO10"
			end
			if code == "09"
				return "PO11"
			end
			if code == "10" || code == "11"
				return "PO" + (code.to_i + 3).to_s
			end
			if one_to_eight.include?(code)
				return "PO0" + (code.to_i + 1).to_s
			end
			if twelve_to_eighteen.include?(code)
				return "PO" + (code.to_i + 4).to_s
			end
		end

	end
end