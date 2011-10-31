# Allows hubot to search yelp for stuff
#
# where should we go for <search terms>

# Make sure to install node-yelp
# Add the following line to the end of dependencies object in package.json
# "yelp": "0.1.0"
# then from the console run 'npm install'

# Get a Yelp API key here: http://www.yelp.com/developers
# You will need the following Yelp information stored as environment varaibles

# Yelp Info           environment variable
# consumer key        HUBOT_YELP_CONSUMER_KEY
# consumer secret     HUBOT_YELP_CONSUMER_SECRET
# token               HUBOT_YELP_TOKEN
# token secret        HUBOT_YELP_TOKEN_SECRET

# To add an environment variable to a Heroku instance use: 
# heroku config:add HUBOT_YELP_CONSUMER_KEY="SuperSecretConsumerKey"

yelp = require "yelp" 
env = process.env

module.exports = (robot) ->
    if env.HUBOT_YELP_CONSUMER_KEY and env.HUBOT_YELP_CONSUMER_SECRET and env.HUBOT_YELP_TOKEN and env.HUBOT_YELP_TOKEN_SECRET
        yelpClient = yelp.createClient {
            consumer_key: env.HUBOT_YELP_CONSUMER_KEY, 
            consumer_secret: env.HUBOT_YELP_CONSUMER_SECRET,
            token: env.HUBOT_YELP_TOKEN,
            token_secret: env.HUBOT_YELP_TOKEN_SECRET
        }
        robot.respond /where should (i|we) go for (.*)/i, (msg) ->
            goFor = msg.match[2]
            inCity = "San Luis Obispo"
            yelpClient.search {term: goFor, location: inCity, limit: 20}, (error, data) ->
                if not error
                    # Show all
                    #locationDetails = ("#{biz.name}\n#{biz.location.address}, #{biz.location.city}" for biz in data.businesses).join('\n')
                    # Pick one
                    locationDetails = msg.random ("#{biz.name}\n#{biz.location.address}, #{biz.location.city}" for biz in data.businesses)
                    msg.send "#{goFor} near #{inCity}\n#{locationDetails}"
                else
                    #console.log error
                    msg.send "Having a hard time talking to Yelp right now."