class ArticlesController < ApplicationController
	def destroy
		@article = Article.find(params[:id])
		@article.destroy
		flash[:notice] = "Artigo '#{@article.title}' apagado"
		redirect_to source_path(@article.feed.source)
	end

	def show
		duplicates_ids = Article.find_duplicates
		@articles = Article.where(id: duplicates_ids)
		render 'duplicates'
	end
end
