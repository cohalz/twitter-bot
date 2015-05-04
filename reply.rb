# coding: utf-8

require 'twitter'
require 'csv'
require_relative 'markov'
require_relative 'config'

class ReplyDaemon
  def initialize
    puts 'Start initialization of daemon...'

    @rest = Twitter::REST::Client.new do |config|
      config.consumer_key = YOUR_CONSUMER_KEY
      config.consumer_secret = YOUR_CONSUMER_SECRET
      config.access_token = YOUR_OAUTH_TOKEN
      config.access_token_secret = YOUR_OAUTH_TOKEN_SECRET
    end
    @stream = Twitter::Streaming::Client.new do |config|
      config.consumer_key = YOUR_CONSUMER_KEY
      config.consumer_secret = YOUR_CONSUMER_SECRET
      config.access_token = YOUR_OAUTH_TOKEN
      config.access_token_secret = YOUR_OAUTH_TOKEN_SECRET
    end

    tweets_table = Array.new
    CSV.foreach('tweets.csv', :headers => true) do |row|
      tweet = normalize_tweet(row['text'])
      next if !tweet
      tweets_table << tweet
    end

    @markov_table = create_markov_table(tweets_table)
    @pid_file_path = './reply_daemon.pid'
    @error_log_path = './reply_error.log'

    puts 'Finish initialization.'
  end

  def run
    daemonize
    begin
      @stream.filter(:track => BOT_SCREEN_NAME) do |object|
        if object.is_a?(Twitter::Tweet) && object.text.include?('@'+BOT_SCREEN_NAME)
          sleep(5)
          reply = '@' + object.user.screen_name + ' ' + generate_tweet(@markov_table)
          @rest.update(reply, { 'in_reply_to_status_id' => object.id })
        end
        if object.is_a?(Twitter::Tweet)
          CSV.open("streamlog.csv", "a") do |csv|
            csv << ["", "", "", "", "", object.text,"","","",""]
          end
        end
      end
    rescue => ex
      open(@error_log_path, 'w') { |f| 
        f.puts(ex.backtrace) 
        f.puts(ex.message) 
        f.puts('') } if @error_log_path
      # When something error occured, tell it by replying to admin
      @rest.update('@' + ADMIN_SCREEN_NAME + ' ')
    end
  end

  def daemonize
    exit!(0) if Process.fork
    Process.setsid
    exit!(0) if Process.fork
    open_pid_file
  end

  def open_pid_file
    open(@pid_file_path, 'w') {|f| f << Process.pid } if @pid_file_path
  end
end

ReplyDaemon.new.run
