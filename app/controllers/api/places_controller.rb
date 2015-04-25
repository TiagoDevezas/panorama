module Api
	class PlacesController < ApplicationController
		helper_method :convert_to_fips, :get_article_count
		respond_to :json

		caches_action :index, cache_path: Proc.new {|c| c.params.except(:callback) }, expires_in: 6.hour

		def index
			map_type = params[:map]
			lang = params[:lang] || 'pt'

			if !map_type || map_type.downcase == 'portugal'
				@district_list = []
				Country.find_country_by_name('Portugal').subdivisions.each do |sub|
					code = sub[0]
					name = sub[1]['name']
					count = get_article_count(name) if name
					# count = Article.find_articles_with(name).count
					@district_list << Hash[
						name: name || nil,
						code: convert_to_fips(code),
						count: count
					]
				end
			elsif map_type == 'world'
				@country_list = []
				countries = Country.all
				countries.each do |name, alpha2|
					country = Country.find_country_by_alpha2(alpha2)
					country_name = country.translation(lang)
					alpha2_code = country.alpha2
					alpha3_code = country.alpha3
					country_code = country.country_code
					count = get_article_count(country_name) if country_name
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
				count = source.articles.find_articles_with(query).count
			elsif type
				count = Article.with_source_type(type).find_articles_with(query).count
			else
				count = Article.find_articles_with(query).count
			end

		end

		def check_for_dates
			start_date = params[:since]
			end_date = params[:until]
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