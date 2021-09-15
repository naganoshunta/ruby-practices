def fizzbuzz(num)
  case
  when num % 3 == 0 && num % 5 == 0
    "FizzBuzz"
  when num % 3 == 0
    "Fizz"
  when num % 5 == 0
    "Buzz"
  else
    num
  end
end

(1..20).each do |num|
  p fizzbuzz(num)
end
