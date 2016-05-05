# -*- coding: utf-8 -*-
require 'pry'
require 'active_record'
require 'twitter'

# データベースへの接続
ActiveRecord::Base.establish_connection(
  adapter:   'sqlite3',
  database:  'db/db.sqlite3' # ':memory:'
)

# スキーマの設定
class InitialSchema < ActiveRecord::Migration
  def self.up
    create_table :tweets do |t|
      t.string :marshal
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
binding.pry
