# frozen_string_literal: true

puts 'Sleep for waiting documentserver start'
waiting_time = 90 # Timer limit for documentserver
def seconds_left(param)
  while param.positive?
    sleep 1
    puts param
    param -= 1
  end
end

puts seconds_left(waiting_time)
puts 'Waiting is end. Run tests'

exec('rspec')
