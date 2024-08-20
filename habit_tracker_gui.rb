begin
    require_relative 'app/main'
  rescue => e
    puts "An error occurred: #{e.message}"
    puts e.backtrace
    gets  # Pauses the script to keep the console window open
  end