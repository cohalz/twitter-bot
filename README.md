Markov Chain-based Japanese Twitter Bot
===

[![Build Status](https://travis-ci.org/takuti/twitter-bot.svg)](https://travis-ci.org/takuti/twitter-bot)

***Since this project is strongly optimized for Japanese, other languages are not supported :sushi:***

## Description

- Generate a tweet based on so-called **Markov Chain** from particular user's tweet history
- Sample: [@yootakuti](https://twitter.com/yootakuti)
- My Japanese article: [マルコフ連鎖でTwitter Botをつくりました - blog.takuti.me](http://blog.takuti.me/twitter-bot/)

## Usage

1. Download tweet history from your Twitter setting page
  - The program will use *text* column of **tweets.csv**
1. Install MeCab
  - good: [mecab-ipadic-neologd](https://github.com/neologd/mecab-ipadic-neologd)
1. Install twitter, tweetstream and natto
  - ```gem install twitter tweetstream natto```
1. Generate/Post tweet
  - Just generate: `ruby main.rb`
  - Post: write API keys in **config.rb**, and `ruby main.rb production`

If the length of generated tweet is greater than 100, this bot will post Kaomoji from [kaomoji.html](https://github.com/tatat/kaomoji.html) API because long tweets do not make sense.

<<<<<<< HEAD
- **reply.rb** can answer to replies found on your timeline
- Daemon
  - Run: `ruby reply.rb`
  - Stop: `cat reply_daemon.pid | xargs kill`
  - A file **reply_daemon.pid** will be generated automatically
  - Reference: [http://nuke.hateblo.jp/entry/2013/07/04/090917](http://nuke.hateblo.jp/entry/2013/07/04/090917)
=======
## TODO

- [ ] Improve performance (e.g. store tweets on DB)
- [ ] Realize more humanlike tweet
- [ ] Implement reply feature
	- **reply.rb** can answer to replies found on your timeline
	- Daemon
		- Run: `ruby reply.rb`
		- Stop: `cat reply_daemon.pid | xargs kill`
		- A file **reply_daemon.pid** will be generated automatically
		- Reference: [http://nuke.hateblo.jp/entry/2013/07/04/090917](http://nuke.hateblo.jp/entry/2013/07/04/090917)
>>>>>>> upstream/master

## License

MIT

## Author

<<<<<<< HEAD
- Improve performance (Currently, the program does A-to-Z of the tweet generation every time)
- More humanlike tweet
- Implement reply feature
=======
[takuti](http://github.com/takuti)
>>>>>>> upstream/master
