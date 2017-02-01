require './ratings.rb'

class Validator

  def initialize(u)
    @trainSet = Ratings.new("ml-100k/#{u}.base")
    @testSet = Ratings.new("ml-100k/#{u}.test")
  end

  def validate
    offByZero = 0
    offByOne  = 0
    offByTwo = 0
    offByThree = 0
    offByFour = 0
    #This will only happen if no one in top 20 similar users have watched the movie
    #and the user would have given it a perfect 5
    offByFive = 0
    arrOfDiff = Array.new()
    @testSet.user_hash.each do |u, movies|
      arr = @trainSet.most_similar(u)
      movies.each do |movie|
        m = movie["movie_id"]
        #instead of taking user, taking array of users to improve performance
        pScore = @trainSet.predict(arr, m)
        aScore = movie["rating"]
        puts "User: #{u}, Movie:#{m}, Predicted Score #{pScore}, Actual Score #{aScore}"
        diff = (pScore.to_i - aScore.to_i).abs
        arrOfDiff.push(diff)
        if diff == 0
          offByZero = offByZero + 1
        elsif diff == 1.0
          offByOne = offByOne + 1
        elsif diff == 2.0
          offByTwo = offByTwo + 1
        elsif diff == 3.0
          offByThree = offByThree + 1
        elsif diff == 4.0
          offByFour = offByFour + 1
        else
          offByFive = offByFive + 1
        end
      end
    end
    totalDiff = (1.0 * offByOne) + (2.0 * offByTwo) + (3.0 * offByThree) + (4.0 * offByFour) + (5.0 * offByFive)
    total = offByZero + offByOne + offByTwo + offByThree + offByFour + offByFive
    mean = totalDiff / total
    totalSqrDiff = 0
    arrOfDiff.each do |diff|
      totalSqrDiff = totalSqrDiff + ((diff - mean) ** 2)
    end
    stDev = Math.sqrt(totalSqrDiff / arrOfDiff.length)
    puts "Statistics: Ratings"
    puts "Accurate Ratings = #{offByZero}"
    puts "Off by one =  #{offByOne}"
    puts "Off by two #{offByTwo}"
    puts "Off by three #{offByThree}"
    puts "Off by four #{offByFour}"
    puts "Off by five #{offByFive}"
    puts "Mean of the differences = #{mean}"
    puts "Standard Deviation is #{stDev}"
  end

end
