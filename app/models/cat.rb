class Cat < ActiveRecord::Base
	has_and_belongs_to_many :articles

	validates :name, presence: true

	# def self.get_names_and_article_counts
	# 	cats = self.all.includes(:articles)
	# 	names_article_counts = cats.each.map { |cat| [cat.name, cat.articles.size] }.sort_by { |e| e[1] }.reverse
	# end

end
