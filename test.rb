def score(dice)# You need to write this method
  score = 0
  count_hash = {:ones => 0, :twos=> 0, :threes=> 0, :fours=> 0, :fives=> 0, :sixs=> 0}
  dice.each {|n| case n
    when 1
      count_hash[ones] += 1
    when 2
      count_hash[twos] += 1
    when 3
      count_hash[threes] += 1
    when 4
      count_hash[fours] += 1
    when 5
      count_hash[fives] += 1
    when 6
      count_hash[sixs] += 1
    end
}
count_hash.each {|key, value| puts "#{key} and #{value}"}
count_hash.each {|key, value| case key
when :ones
  if value == 3
    score +=1000
  end
when :twos
  if value == 3
    score += 200
  end
when :threes
  if value == 3
    score += 300
  end
when :fours
  if value == 3
    score += 400
  end
when :fives
  if value == 3
    score += 500
  end
when :sixs
  if value == 3
    score += 600
  end
end

return score
}
end