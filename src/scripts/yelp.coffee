# Allows hubot to search yelp for stuff
#
# where should we go for <search terms> - Pick a random result from a max of 20 results for the search term
# yelp <search term> - Return 5 results for the search term

# Make sure to install node-yelp
# Add the following line to the end of dependencies object in package.json
# "yelp": "0.1.0"
# then from the console run 'npm install'

# Get a Yelp API key here: http://www.yelp.com/developers
# You will need the following Yelp informationa as environment varaibles
# Yelp Info           environment variable
# consumer key        HUBOT_YELP_CONSUMER_KEY
# consumer secret     HUBOT_YELP_CONSUMER_SECRET
# token               HUBOT_YELP_TOKEN
# token secret        HUBOT_YELP_TOKEN_SECRET

# To add the environment variable to a Heroku instance use: 
# heroku config:add HUBOT_YELP_CONSUMER_KEY="SuperSecretConsumerKey"

yelp = require "yelp" 
env = process.env

module.exports = (robot) ->
    
    
    robot.respond /where should (i|we) go for (.*)/i, (msg) ->
        searchFor = msg.match[2]
        yelpIt msg, searchFor, 20, true

    robot.respond /yelp (me )?(.*)/i, (msg) ->
        searchFor = msg.match[2]
        yelpIt msg, searchFor, 5, false

starRating = (starScore, maxStars) ->
    stars = for x in [1..maxStars] 
        if starScore > x
            "★ "
        else if x - starScore == 0.5
            "½"
        else
            "☆ "
    stars.join('')

yelpIt = (msg, searchTerm, maxResults, randomize) ->
    unless env.HUBOT_YELP_CONSUMER_KEY and env.HUBOT_YELP_CONSUMER_SECRET and 
            env.HUBOT_YELP_TOKEN and env.HUBOT_YELP_TOKEN_SECRET
        msg.send "Bzzt buzz.  Missing Yelp keys.  Give me the codes."
        return
    
    inCity = "San Luis Obispo"
    
    yelpClient = yelp.createClient {
        consumer_key: env.HUBOT_YELP_CONSUMER_KEY, 
        consumer_secret: env.HUBOT_YELP_CONSUMER_SECRET,
        token: env.HUBOT_YELP_TOKEN,
        token_secret: env.HUBOT_YELP_TOKEN_SECRET
    }

    yelpClient.search {term: searchTerm, location: inCity, limit: maxResults}, (error, data) ->
        if not error
            locationDetails = for biz in data.businesses
                loc = biz.location
                rateStr = starRating biz.rating, 5
                "#{biz.name} [#{rateStr}]\n  #{loc.address}, #{loc.city}"
            
            if randomize
                locationDetails = msg.random locationDetails
            else
                locationDetails = locationDetails.join('\n')
                
            msg.send "#{searchTerm} near #{inCity}\n#{locationDetails}"
        else
            msg.send "Having a hard time talking to Yelp right now."
    