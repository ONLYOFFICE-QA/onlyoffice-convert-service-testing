# frozen_string_literal: true

puts 'Sleep for waiting documentserver start'
waiting_time = 120 # Timer limit for documentserver
waiting_time.times do |i|
  puts("Waiting for #{i} seconds")
  sleep 1
end

puts 'Waiting is end. Run tests'
