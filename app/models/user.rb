class User < ApplicationRecord
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy

  # Usado no cenario "count x size x counter_cache"
  def slow_post_count
    posts.count      # SEMPRE bate no banco: SELECT COUNT(*)
  end

  def cached_post_count
    posts_count      # coluna counter_cache: zero queries
  end
end
