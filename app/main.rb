# app/main.rb
require 'fox16'
require_relative 'gui'

FXApp.new do |app|
  HabitTrackerApp.new(app)
  app.create
  app.run
end