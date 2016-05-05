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

# スキーマの設定
class InitialSchema < ActiveRecord::Migration
  def self.up
    create_table :tweets do |t|
      t.json :data
    end
  end

  def self.down
    drop_table :tweets
  end
end

# 1回目はマイグレーション
# InitialSchema.migrate(:up)

class Tweet < ActiveRecord::Base
end

# モデルを生成
# Tweet.create(marshal: 'hogehoge')
Tweet.first
Tweet.where("data->>'in_reply_to_status_id' = ?", false)
Tweet.where.not("data->>'in_reply_to_status_id' = ?", "nil").count
binding.pry
