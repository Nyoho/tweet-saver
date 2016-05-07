# -*- coding: utf-8 -*-
require 'pry'
require 'active_record'
require 'twitter'

ActiveRecord::Base.establish_connection(
    adapter: 'postgresql',
    host: 'localhost',
    username: 'postgres'
  # host: <%= ENV.fetch('DATABASE_HOST', 'localhost') %>
  # 'postgres://localhost/mydb'
)

class Tweet < ActiveRecord::Base
end

# モデルを生成
# Tweet.create(marshal: 'hogehoge')
Tweet.first
Tweet.where("data->>'in_reply_to_status_id' = ?", false)
Tweet.where.not("data->>'in_reply_to_status_id' = ?", "nil").count
Tweet.where.not("data->>'in_reply_to_status_id' = ?", "nil").map{|t| t.data['in_reply_to_status_id']}
binding.pry
