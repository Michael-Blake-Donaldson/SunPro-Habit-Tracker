require 'fox16'
require_relative 'database'
include Fox

class HabitTrackerApp < FXMainWindow
  def initialize(app)
    super(app, "Healthy Habit Tracker", width: 700, height: 500)

    # Initialize the database connection
    @database = Database.new  

    # Load a custom font
    @font = FXFont.new(app, "Arial", 14)

    # Set a modern color scheme
    @primary_color = FXRGB(58, 175, 169)   # A teal color for buttons and highlights
    @secondary_color = FXRGB(38, 38, 38)   # Dark background color
    @text_color = FXRGB(255, 255, 255)     # White text color
    @background_color = FXRGB(245, 245, 245) # Light gray background

    self.backColor = @background_color

    create_interface
  end

  def create_interface
    # Main vertical frame with padding
    main_frame = FXVerticalFrame.new(self, LAYOUT_FILL_X|LAYOUT_FILL_Y, padding: 20)

    # Title with custom font and color
    title_font = FXFont.new(app, "Arial", 24, FONTWEIGHT_BOLD)
    title_label = FXLabel.new(main_frame, "Healthy Habit Tracker", nil, JUSTIFY_CENTER_X|LAYOUT_FILL_X)
    title_label.font = title_font
    title_label.textColor = @primary_color
    title_label.backColor = @background_color

    # Habit Selection dropdown with padding and custom style
    FXLabel.new(main_frame, "Select a Habit:", nil, JUSTIFY_LEFT|LAYOUT_FILL_X).tap do |label|
      label.font = @font
      label.textColor = @secondary_color
      label.backColor = @background_color
    end

    @habit_selector = FXComboBox.new(main_frame, 30, nil, 0, COMBOBOX_STATIC|FRAME_SUNKEN|FRAME_THICK|LAYOUT_FILL_X)
    @habit_selector.numVisible = 10
    @habit_selector.font = @font

    # List of 100 unique healthy habits
    habits = [
      "Drink Water", "Exercise", "Eat Fruits", "Read", "Meditate", "Stretch", "Go for a Walk",
      "Get 8 Hours of Sleep", "Cook a Healthy Meal", "Practice Deep Breathing", "Limit Screen Time",
      "Avoid Sugary Drinks", "Take Vitamins", "Practice Gratitude", "Eat Vegetables", "Spend Time Outdoors",
      "Avoid Junk Food", "Plan Tomorrow’s Meals", "Practice Yoga", "Drink Herbal Tea", "Limit Caffeine",
      "Write in a Journal", "Practice Mindfulness", "Do a Digital Detox", "Practice a New Skill",
      "Avoid Processed Foods", "Eat a Balanced Breakfast", "Stay Hydrated", "Avoid Alcohol",
      "Eat Whole Grains", "Floss Your Teeth", "Practice Good Posture", "Use Stairs Instead of Elevator",
      "Get Fresh Air", "Do 10 Minutes of Cardio", "Limit Sodium Intake", "Cook with Olive Oil",
      "Eat Fish", "Avoid Fast Food", "Practice Intermittent Fasting", "Drink Green Tea", "Eat a Salad",
      "Snack on Nuts", "Eat Dark Chocolate", "Practice Portion Control", "Try a New Healthy Recipe",
      "Incorporate Fiber into Your Diet", "Have a Meatless Meal", "Reduce Sugar Intake", "Add a Probiotic to Your Diet",
      "Eat a Healthy Snack", "Use Smaller Plates", "Avoid Late Night Snacks", "Stand Up Every Hour",
      "Practice Tai Chi", "Read a Self-Improvement Book", "Take a Cold Shower", "Try a New Exercise",
      "Take the Long Way Home", "Skip Dessert", "Drink a Smoothie", "Avoid Trans Fats", "Eat a High-Protein Breakfast",
      "Incorporate Leafy Greens", "Reduce Carb Intake", "Do a Plank", "Eat Slowly", "Limit Red Meat",
      "Practice Self-Care", "Have a Cheat Meal", "Try Meditation", "Avoid Eating Out", "Plan a Healthy Grocery List",
      "Cook at Home", "Focus on Whole Foods", "Drink a Glass of Water Before Meals", "Avoid Added Sugars",
      "Plan Healthy Snacks", "Limit Dairy Intake", "Avoid Overeating", "Eat Mindfully", "Practice Gratitude",
      "Limit Screen Time Before Bed", "Set a Sleep Routine", "Try a New Hobby", "Limit Artificial Sweeteners",
      "Spend Time with Family", "Volunteer", "Practice Forgiveness", "Reduce Stress", "Manage Time Effectively",
      "Practice Patience", "Stay Positive", "Practice Compassion", "Avoid Negativity", "Focus on Solutions",
      "Take Breaks During Work"
    ]

    habits.each { |habit| @habit_selector.appendItem(habit) }

    # Add buttons with improved style
    add_button(main_frame, "Mark as Done", method(:mark_habit_as_done))
    add_button(main_frame, "View Progress", method(:view_progress))
    add_button(main_frame, "View Achievements", method(:view_achievements))
    add_button(main_frame, "View FAQ", method(:view_faq))
  end

  def add_button(frame, text, action)
    FXButton.new(frame, text, nil, nil, 0, FRAME_RAISED|FRAME_THICK|LAYOUT_FILL_X|BUTTON_NORMAL).tap do |button|
      button.backColor = @primary_color
      button.textColor = @text_color
      button.font = @font
      button.padLeft = button.padRight = 10
      button.padTop = button.padBottom = 10
      button.connect(SEL_COMMAND) { action.call }
    end
  end

  def mark_habit_as_done
    selected_habit = @habit_selector.text
    today = Time.now.strftime("%Y-%m-%d")
    @database.add_habit(selected_habit, today)
    FXMessageBox.information(self, MBOX_OK, "Habit Completed", "You've completed #{selected_habit} today!")
  end

  def view_progress
    result = @database.get_habits
    message = result.map do |row|
      streak = @database.get_streak(row[0])
      "Habit: #{row[0]} - Date: #{row[1]} (Streak: #{streak} days)"
    end.join("\n")
    FXMessageBox.information(self, MBOX_OK, "Habit Progress", message.empty? ? "No progress yet." : message)
  end

  def view_achievements
    result = @database.get_achievements
    message = result.map { |row| "Achievement: #{row[1]} - Habit: #{row[0]}" }.join("\n")
    FXMessageBox.information(self, MBOX_OK, "Achievements", message.empty? ? "No achievements yet." : message)
  end

  def view_faq
    selected_habit = @habit_selector.text
    faq = @database.get_faq(selected_habit)
    FXMessageBox.information(self, MBOX_OK, "Habit FAQ", faq.nil? ? "No FAQ available for this habit." : faq)
  end

  def handle_error(e)
    puts "An error occurred: #{e.message}"
    puts e.backtrace.join("\n")
    File.open("error_log.txt", "a") do |file|
      file.puts "An error occurred: #{e.message}"
      file.puts e.backtrace.join("\n")
    end
    FXMessageBox.error(self, MBOX_OK, "Error", "An unexpected error occurred. Please check the error log.")
  end

  def create
    super
    show(PLACEMENT_SCREEN)
  end
end
