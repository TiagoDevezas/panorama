class Feed < ActiveRecord::Base
  belongs_to :source
  has_many :articles, dependent: :destroy
  validates :url, presence: true
end
