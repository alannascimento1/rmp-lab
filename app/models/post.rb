class Post < ApplicationRecord
  belongs_to :user, counter_cache: true
  has_many :comments, dependent: :destroy
  has_many :post_tags, dependent: :destroy
  has_many :tags, through: :post_tags

  scope :recent, -> { order(published_at: :desc) }

  # Simula um calculo caro em Ruby (nao aparece como SQL no profiler,
  # aparece como tempo "sobrando" no request -> use ?pp=flamegraph/profile-gc)
  def expensive_score
    (1..20_000).reduce(0) { |acc, n| acc + (n % 7) } % 100
  end
end
