# -*- coding: utf-8 -*-
require 'pry'
require 'twitter'
require 'dotenv'
Dotenv.load

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
  config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
  config.access_token        = ENV['TWITTER_OAUTH_TOKEN']
  config.access_token_secret = ENV['TWITTER_OAUTH_TOKEN_SECRET']
end

streaming_client = Twitter::Streaming::Client.new do |config|
  config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
  config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
  config.access_token        = ENV['TWITTER_OAUTH_TOKEN']
  config.access_token_secret = ENV['TWITTER_OAUTH_TOKEN_SECRET']
end

require "active_record"

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


# replyers' ids
reps = []

# streaming_client.sample({lang: 'ja'}) do |object|
streaming_client.sample do |o|
# streaming_client.user do |object|
  if o.is_a?(Twitter::Tweet) && o.lang == 'ja'

    begin
      Tweet.transaction do
        Tweet.create(marshal: Marshal.dump(o).force_encoding("utf-8"))
      end
    rescue SQLite3::BusyException => ex
      STDERR.puts ex
      sleep 1
      retry
    rescue => ex
      STDERR.puts ex
      sleep 1
      retry
    rescue ActiveRecord::StatementInvalid => ex
      STDERR.puts ex
      sleep 1
      retry
    rescue Timeout::Error => ex
      STDERR.puts ex
      sleep 1
      retry
    end
    

    # puts (b.classify object.text)
    # print %Q|\r\e[36m\e[40m■\e[0m #{o.text} (\e[35m\e[40m@#{o.user.screen_name}\e[0m)|
    print %Q|\r\e[36m\e[40m■\e[0m \e[35m\e[40m@#{o.user.screen_name}\e[0m|
    # puts "screen name = " + o.in_reply_to_screen_name if o.in_reply_to_screen_name?
    # puts "user id     = " + o.in_reply_to_user_id.to_s if o.in_reply_to_user_id?
    # puts "status id   = " + o.in_reply_to_status_id.to_s if o.in_reply_to_status_id?
    # puts "tweet id    = " + o.in_reply_to_tweet_id.to_s
    if o.in_reply_to_status_id?
      # puts "これへの返信:"
      # TODO: 100個たまったら取得する。
      reps.push o.in_reply_to_status_id
      if reps.length >= 100
        puts %Q|\e[36m\e[40mSave 100 tweets\e[0m|
        ActiveRecord::Base.transaction do
        # Tweet.transaction do
          client.statuses(reps).each do |t|
            Tweet.create(marshal: Marshal.dump(t).force_encoding("utf-8"))
            # puts "#{t.text} by #{t.user.screen_name}"
          end
        end
        reps = []
      end
    end
  end
end
binding.pry

