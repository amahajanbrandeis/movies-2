class Ratings

  attr_accessor :user_hash, :movie_hash, :fName

  def initialize(file)
      @fName = file
      load
  end


##get rating

  def load
    @user_hash = {}
    @movie_hash = {}
    #goes through specified file line by line
    File.open(@fName).each do |line|
      line = line.strip
      datum = line.split("\t") #assumes tabs between data, splits, puts line into array
      #since line is considered a string, converting all to integers, with rating being a float just in case
      user_id = datum[0].to_i
      movie_id = datum[1].to_i
      rating = datum[2].to_f #futureproofing if implementing average review for a movie
      time_stamp = datum[3].to_i
      #if user_id is not yet in user hash, create
      if user_hash[user_id] == nil
          user_hash[user_id] = []
      end
      #pushes array of data for given user_id
      user_hash_value = {"movie_id"=> movie_id, "rating"=> rating, "time_stamp"=> time_stamp}
      user_hash[user_id].push(user_hash_value)
      #works in same fashion as user_hash code above
      if movie_hash[movie_id] == nil
          movie_hash[movie_id] = []
      end
      movie_hash_value = {"user_id"=> user_id,  "rating"=> rating, "time_stamp"=> time_stamp}
      movie_hash[movie_id].push(movie_hash_value)
    end
  end

  def averageSimilarityScore(u)
    arr = Array.new()
    totalUsers = 0
    totalSimilarityScore = 0
    user_hash[u].each do |movies|
      movie_hash[movies["movie_id"]].each do |users|
        #checks if comparing to self user or if user is not compared yet
        if u != users["user_id"] && not_found(users["user_id"], arr)
          score = similarity(u, users["user_id"])
          totalUsers = totalUsers + 1
          totalSimilarityScore = totalSimilarityScore + score
          us = {"user_id"=> users["user_id"], "score"=> score}
          arr.push(us)
        end
      end
    end
    return totalSimilarityScore / totalUsers
  end

  def similarity(user1,user2)
    #similarity score count
    sCount = 0
    #organizing it so that user with smaller set of movies compares to larger set
    if user_hash[user2].length < user_hash[user1].length
        tempUser = user2
        user2 = user1
        user1 = tempUser
    end
    #check if they have watched the same movie
    user_hash[user1].each do |movies1|
      user_hash[user2].each do |movies2|
        if movies1["movie_id"] == movies2["movie_id"]
          #now we see if they gave a similar rating to the movie. Closer rating boosts sCount, greater than 1
          #point difference does not add to score
          x = movies1["rating"] - movies2["rating"]
          if x.abs  == 0
            sCount = sCount + 3
          elsif x.abs <= 1
            sCount = sCount + 1
          #elsif x.abs <= 2
            #sCount = sCount + 1
          end
          break
        end
      end
    end
    return sCount
  end


  #sees if user is in a given array
  def not_found(u, a)
    f = true
		a.each do |ss|
			if ss["user_id"] == u
				f = false
				break
			end
		end
		return f
  end

  def predict(arr, movie)
    totalSimilarityScore = 0
    totalRatingScore = 0
    #change arr to have both users and scores
    arr.each do |uaArr|
      user = uaArr["user_id"]
      simScore = uaArr["score"]
      array2 = user_hash[user]
      array2.each do |m|
        if m["movie_id"] == movie
          rating = m["rating"]
          ##get user rating, get user similarity score
          totalSimilarityScore = totalSimilarityScore + simScore
          totalRatingScore = totalRatingScore + simScore * rating
        end
      end
    end
    if totalSimilarityScore == 0
      return 0.0
    else
      return (totalRatingScore / totalSimilarityScore).round.to_f
    end
  end

  def most_similar(u) # this return a list of users whose tastes are most similar to the tastes of user
    #array will contain users and their similarity score in relation to user u
    arr = Array.new()
    user_hash[u].each do |movies|
      movie_hash[movies["movie_id"]].each do |users|
        #checks if comparing to self user or if user is not compared yet
        if u != users["user_id"] && not_found(users["user_id"], arr)
          score = similarity(u, users["user_id"])
          us = {"user_id"=> users["user_id"], "score"=> score}
          arr.push(us)
        end
      end
    end
    #sort by highest similarity score
    arr.sort! {|a1,a2| a2["score"] <=> a1["score"]}
    #the returned array will just be of users and not their scores. This will return top 10 users.
    ua = Array.new()
    count = 0
    arr.each do |uArray|
      info = {"user_id"=> uArray["user_id"], "score"=> uArray["score"]}
      ua.push(info)
      count = count + 1
      if count == 30
        break
      end
    end
    return ua
  end

end
