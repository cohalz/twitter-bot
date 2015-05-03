# coding: utf-8

require 'twitter'
require 'csv'
require_relative 'markov'

tweets_table = Array.new
CSV.foreach('data/tweets/tweets.csv', :headers => true) do |row|
  tweet = normalize_tweet(row['text'])
  next if !tweet
  tweets_table << tweet
end

markov_table = create_markov_table(tweets_table)

if ARGV[0] == 'production'
  rest = Twitter::REST::Client.new do |config|
    config.consumer_key = ""
    config.consumer_secret = ""
    config.access_token = ""
    config.access_token_secret = ""
  end
  rest.update(generate_tweet(markov_table))
else
  puts "[tweet] #{generate_tweet(markov_table)}"
end
