module Lab
  class HomeController < ApplicationController
    def index
      @stats = {
        users:    User.count,
        posts:    Post.count,
        comments: Comment.count,
        tags:     Tag.count
      }
    end
  end
end
