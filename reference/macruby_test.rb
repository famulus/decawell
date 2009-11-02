waiting_chairs = Dispatch::Queue.new('com.apple.waiting_chairs')
semaphore = Dispatch::Semaphore.new(3)
index = -1
while true
  index += 1
  if semaphore.wait(Dispatch::TIME_NOW) != 0
    puts "Customer turned away #{index}"
    next
  end
  waiting_chairs.dispatch do
    semaphore.signal
    puts "Shave and a haircut #{index}"
  end
end
