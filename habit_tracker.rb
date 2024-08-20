require 'fox16'
require 'sqlite3'
include Fox

class HabitTrackerApp < FXMainWindow
  def initialize(app)
    super(app, "Habit Tracker", width: 600, height: 400)
    initialize_database
    create_interface
  end

  def initialize_database
    @db = SQLite3::Database.new "habit_tracker.db"
    @db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS habits (
        id INTEGER PRIMARY KEY,
        name TEXT,
        date TEXT,
        completed BOOLEAN
      );
    SQL
  end

  def create_interface
    # Main vertical frame
    main_frame = FXVerticalFrame.new(self, LAYOUT_FILL_X|LAYOUT_FILL_Y)

    # Title
    FXLabel.new(main_frame, "Healthy Habit Tracker", nil, JUSTIFY_CENTER_X|LAYOUT_FILL_X)

    # Habit Selection dropdown
    FXLabel.new(main_frame, "Select a Habit:", nil, JUSTIFY_LEFT|LAYOUT_FILL_X)
    @habit_selector = FXComboBox.new(main_frame, 20, nil, 0, COMBOBOX_STATIC|FRAME_SUNKEN|FRAME_THICK|LAYOUT_FILL_X)
    @habit_selector.numVisible = 5
    @habit_selector.appendItem("Drink Water")
    @habit_selector.appendItem("Exercise")
    @habit_selector.appendItem("Eat Fruits")
    @habit_selector.appendItem("Read")
    @habit_selector.appendItem("Meditate")

    # Button to mark habit as done
    @done_button = FXButton.new(main_frame, "Mark as Done", nil, nil, 0, FRAME_RAISED|FRAME_THICK|LAYOUT_FILL_X)
    @done_button.connect(SEL_COMMAND) do
      mark_habit_as_done
    end

    # Button to view progress
    @view_button = FXButton.new(main_frame, "View Progress", nil, nil, 0, FRAME_RAISED|FRAME_THICK|LAYOUT_FILL_X)
    @view_button.connect(SEL_COMMAND) do
      view_progress
    end
  end

  def mark_habit_as_done
    selected_habit = @habit_selector.text
    today = Time.now.strftime("%Y-%m-%d")
    @db.execute("INSERT INTO habits (name, date, completed) VALUES (?, ?, ?)", [selected_habit, today, true])
    FXMessageBox.information(self, MBOX_OK, "Habit Completed", "You've completed #{selected_habit} today!")
  end

  def view_progress
    result = @db.execute("SELECT name, date FROM habits WHERE completed = ?", [true])
    message = result.map { |row| "Habit: #{row[0]} - Date: #{row[1]}" }.join("\n")
    FXMessageBox.information(self, MBOX_OK, "Habit Progress", message.empty? ? "No progress yet." : message)
  end

  def create
    super
    show(PLACEMENT_SCREEN)
  end
end

if __FILE__ == $0
  FXApp.new do |app|
    HabitTrackerApp.new(app)
    app.create
    app.run
  end
end