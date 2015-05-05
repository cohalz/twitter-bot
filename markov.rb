# coding: utf-8

# require 'igo-ruby'
require 'natto'
require 'nkf'
require 'open-uri'
require 'json'

BEGIN_FLG = '[BEGIN]'
END_FLG = '[END]'

def normalize_tweet(tweet)
  tweet = tweet.to_s # 数字だけのツイートでunpack('U*')がエラーを吐くので全てtoString
  return nil if NKF.guess(tweet) != NKF::UTF8
  tweet.gsub!(/\.?@[0-9A-Za-z_]+/, '')  # リプライをすべて削除
  # tweet.gsub!(/(RT|QT)\s*@?[0-9A-Za-z_]+.*$/, '')  # RT/QT以降行末まで削除
  tweet.gsub!(/RT:?/, '')  # RT削除
  tweet.gsub!(/.*I'm\sat.*/, '')  # 4sq削除
  tweet.gsub!(/http:\/\/\S+/, '')  # URLを削除 スペースが入るまで消える
  tweet.gsub!(/#/, ' #') #ハッシュタグ化
  tweet.gsub!(/[「」【】『』）\(\)]/, '') #括弧削除
  # tweet.gsub!(/#[0-9A-Za-z_]+/, '')  # ハッシュタグを削除
  tweet
end

def create_markov_table(tweets)
  natto = Natto::MeCab.new
  # tagger = Igo::Tagger.new('./ipadic')

  # 3階のマルコフ連鎖
  markov_table = Array.new
  markov_index = 0

  # 形態素3つずつから成るテーブルを生成
  tweets.each do |tweet|
    tmp = []
    if tweet != nil
      natto.parse(tweet) do |n|
        tmp.push(n.surface)
      end
    end
    wakati_array = Array.new
    wakati_array << BEGIN_FLG
    wakati_array += tmp
    wakati_array << END_FLG

    # 要素は最低4つあれば[BEGIN]で始まるものと[END]で終わるものの2つが作れる　
    next if wakati_array.size < 4
    i = 0
    loop do
      markov_table[markov_index] = wakati_array[i..(i+2)]
      markov_index += 1
      break if wakati_array[i+2] == END_FLG
      i += 1
    end
  end
  markov_table
end

def generate_tweet(markov_table)
  while true
    # 先頭（[BEGIN]から始まるもの）を選択
    selected_array = Array.new
    markov_table.each do |markov_array|
      if markov_array[0] == BEGIN_FLG
        selected_array << markov_array
      end
    end
    selected = selected_array.sample
    markov_tweet = selected[1] + selected[2]
    # 以後、[END]で終わるものを拾うまで連鎖を続ける
    loop do
      selected_array = Array.new
      markov_table.each do |markov_array|
        if markov_array[0] == selected[2]
          selected_array << markov_array
        end
      end
      break if selected_array.size == 0 # 連鎖できなければ諦める
      selected = selected_array.sample
      if selected[2] == END_FLG
        markov_tweet += selected[1]
        break
      else
        markov_tweet += selected[1] + selected[2]
      end
    end
    markov_tweet = normalize_tweet(markov_tweet)
    # If generated tweet size is greater than 100, tweet random Kaomoji
    if markov_tweet.size > 100
      begin
        markov_tweet = get_kaomoji
        break
      rescue
        next
      end
    else
      break
    end
  end
  markov_tweet
end

def get_kaomoji
  open('http://kaomoji.n-at.me/random.json') do |f|
    JSON.load(f)['record']['text']
  end
end
