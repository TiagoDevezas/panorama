namespace :panorama do
	desc "Atualiza todas as feeds na BD"
	task update_feeds: :environment do
		puts "A atualizar feeds..."
		Source.update_feeds
	end
	desc "Vai buscar o número de partilhas do artigo no Twitter e Facebook"
	task get_share_count: :environment do
		puts "A actualizar partilhas nas redes sociais..."
		Article.all.each do |article|
			article.get_social_shares
		end
	end
end