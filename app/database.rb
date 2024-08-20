require 'sqlite3'
require 'date'

class Database
  def initialize
    @db = SQLite3::Database.new "habit_tracker.db"
    create_tables
  end

  def create_tables
    @db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS habits (
        id INTEGER PRIMARY KEY,
        name TEXT,
        date TEXT,
        completed BOOLEAN
      );
    SQL

    @db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS achievements (
        id INTEGER PRIMARY KEY,
        habit_name TEXT,
        description TEXT,
        unlocked BOOLEAN
      );
    SQL
  end

  def add_habit(name, date)
    completed = 1  # Use 1 for true
    @db.execute("INSERT INTO habits (name, date, completed) VALUES (?, ?, ?)", [name, date, completed])
  end

  def get_habits
    @db.execute("SELECT name, date FROM habits WHERE completed = ?", [1])
  end

  def get_achievements
    @db.execute("SELECT habit_name, description FROM achievements WHERE unlocked = ?", [1])
  end

  def get_streak(habit_name)
    # Example logic to calculate streak (you can replace this with your own logic)
    rows = @db.execute("SELECT date FROM habits WHERE name = ? ORDER BY date ASC", [habit_name])
    streak = 0
    rows.each_cons(2) do |previous, current|
      if Date.parse(current[0]) - Date.parse(previous[0]) == 1
        streak += 1
      else
        streak = 0
      end
    end
    streak
  end

  def get_faq(habit_name)
    faqs = {
      "Drink Water" => "Staying hydrated is essential for overall health. It helps regulate body temperature, keeps joints lubricated, and aids in nutrient transport.",
      "Exercise" => "Regular exercise helps maintain a healthy weight, strengthens muscles, and improves cardiovascular health.",
      "Eat Fruits" => "Fruits are rich in essential vitamins, minerals, and fiber. They are vital for maintaining good health and preventing diseases.",
      "Read" => "Reading improves cognitive function, reduces stress, and expands your knowledge and vocabulary.",
      "Meditate" => "Meditation helps reduce stress, control anxiety, and promotes emotional health and self-awareness.",
      "Stretch" => "Stretching increases flexibility, improves posture, and reduces the risk of injury.",
      "Go for a Walk" => "Walking boosts cardiovascular health, strengthens muscles, and can improve mood and mental well-being.",
      "Get 8 Hours of Sleep" => "Adequate sleep is crucial for cognitive function, mood regulation, and overall health.",
      "Cook a Healthy Meal" => "Cooking at home allows you to control ingredients, making it easier to eat nutritious and balanced meals.",
      "Practice Deep Breathing" => "Deep breathing reduces stress, lowers blood pressure, and improves lung function.",
      "Limit Screen Time" => "Limiting screen time can reduce eye strain, improve sleep, and encourage more physical activity.",
      "Avoid Sugary Drinks" => "Sugary drinks contribute to weight gain and increase the risk of chronic diseases like diabetes and heart disease.",
      "Take Vitamins" => "Vitamins support various bodily functions and can help fill nutritional gaps in your diet.",
      "Practice Gratitude" => "Practicing gratitude enhances emotional well-being, reduces stress, and improves overall happiness.",
      "Eat Vegetables" => "Vegetables are packed with essential nutrients and fiber, supporting overall health and reducing disease risk.",
      "Spend Time Outdoors" => "Spending time outdoors boosts vitamin D levels, improves mood, and enhances physical fitness.",
      "Avoid Junk Food" => "Junk food is often high in unhealthy fats, sugar, and salt, leading to weight gain and increased disease risk.",
      "Plan Tomorrow’s Meals" => "Meal planning helps you maintain a balanced diet, save time, and reduce food waste.",
      "Practice Yoga" => "Yoga improves flexibility, strengthens muscles, and promotes mental clarity and relaxation.",
      "Drink Herbal Tea" => "Herbal teas are rich in antioxidants and can aid digestion, improve sleep, and reduce stress.",
      "Limit Caffeine" => "Limiting caffeine intake can improve sleep quality and reduce anxiety.",
      "Write in a Journal" => "Journaling helps process emotions, improve mental clarity, and track personal growth.",
      "Practice Mindfulness" => "Mindfulness enhances focus, reduces stress, and promotes emotional balance.",
      "Do a Digital Detox" => "A digital detox can improve sleep, reduce stress, and increase time for physical activities.",
      "Practice a New Skill" => "Learning new skills stimulates the brain, improves confidence, and enhances creativity.",
      "Avoid Processed Foods" => "Processed foods often contain unhealthy additives and are linked to chronic health issues.",
      "Eat a Balanced Breakfast" => "A balanced breakfast provides essential nutrients and energy to start your day.",
      "Stay Hydrated" => "Proper hydration is key to maintaining energy levels, brain function, and overall health.",
      "Avoid Alcohol" => "Reducing alcohol intake lowers the risk of liver disease, cancer, and mental health issues.",
      "Eat Whole Grains" => "Whole grains are rich in fiber and nutrients, supporting digestion and heart health.",
      "Floss Your Teeth" => "Flossing prevents gum disease and tooth decay by removing plaque between teeth.",
      "Practice Good Posture" => "Good posture reduces the risk of back pain, improves breathing, and enhances confidence.",
      "Use Stairs Instead of Elevator" => "Taking the stairs improves cardiovascular health and strengthens leg muscles.",
      "Get Fresh Air" => "Fresh air improves mood, boosts energy, and enhances overall well-being.",
      "Do 10 Minutes of Cardio" => "Short bursts of cardio improve heart health, burn calories, and boost mood.",
      "Limit Sodium Intake" => "Reducing sodium intake helps lower blood pressure and reduces the risk of heart disease.",
      "Cook with Olive Oil" => "Olive oil is rich in healthy fats and antioxidants, supporting heart health and reducing inflammation.",
      "Eat Fish" => "Fish is a good source of omega-3 fatty acids, which support heart and brain health.",
      "Avoid Fast Food" => "Fast food is often high in unhealthy fats, sugars, and calories, contributing to weight gain and chronic disease.",
      "Practice Intermittent Fasting" => "Intermittent fasting can support weight loss, improve metabolic health, and extend lifespan.",
      "Drink Green Tea" => "Green tea is rich in antioxidants and can improve brain function, fat loss, and reduce the risk of cancer.",
      "Eat a Salad" => "Salads are packed with nutrients, fiber, and healthy fats, supporting digestion and overall health.",
      "Snack on Nuts" => "Nuts are a good source of healthy fats, protein, and fiber, supporting heart health and weight management.",
      "Eat Dark Chocolate" => "Dark chocolate is rich in antioxidants and can improve heart health and brain function.",
      "Practice Portion Control" => "Portion control helps maintain a healthy weight and prevents overeating.",
      "Try a New Healthy Recipe" => "Exploring new recipes keeps meals exciting and encourages healthy eating habits.",
      "Incorporate Fiber into Your Diet" => "Fiber supports digestion, helps control blood sugar levels, and reduces the risk of heart disease.",
      "Have a Meatless Meal" => "Meatless meals can reduce your risk of chronic diseases and support environmental sustainability.",
      "Reduce Sugar Intake" => "Reducing sugar helps control weight, lowers the risk of diabetes, and improves dental health.",
      "Add a Probiotic to Your Diet" => "Probiotics support gut health, improve digestion, and boost the immune system.",
      "Eat a Healthy Snack" => "Healthy snacks provide sustained energy and can help prevent overeating at meals.",
      "Use Smaller Plates" => "Using smaller plates can help control portion sizes and reduce calorie intake.",
      "Avoid Late Night Snacks" => "Avoiding late-night snacks improves digestion and supports weight management.",
      "Stand Up Every Hour" => "Standing up regularly reduces the risks associated with prolonged sitting and improves circulation.",
      "Practice Tai Chi" => "Tai Chi improves balance, flexibility, and mental focus, reducing the risk of falls and stress.",
      "Read a Self-Improvement Book" => "Self-improvement books provide insights and strategies for personal growth and development.",
      "Take a Cold Shower" => "Cold showers can improve circulation, reduce muscle soreness, and boost mental clarity.",
      "Try a New Exercise" => "Variety in exercise routines prevents boredom and promotes overall fitness and muscle growth.",
      "Take the Long Way Home" => "Walking more each day boosts cardiovascular health and helps manage weight.",
      "Skip Dessert" => "Skipping dessert reduces sugar intake and helps maintain a healthy weight.",
      "Drink a Smoothie" => "Smoothies are a convenient way to consume a variety of fruits, vegetables, and nutrients.",
      "Avoid Trans Fats" => "Trans fats increase the risk of heart disease, stroke, and type 2 diabetes.",
      "Eat a High-Protein Breakfast" => "A high-protein breakfast helps build muscle, reduces appetite, and supports weight management.",
      "Incorporate Leafy Greens" => "Leafy greens are rich in vitamins, minerals, and fiber, promoting overall health.",
      "Reduce Carb Intake" => "Reducing carb intake can help control blood sugar levels and support weight loss.",
      "Do a Plank" => "Planks strengthen the core, improve posture, and reduce the risk of back injuries.",
      "Eat Slowly" => "Eating slowly helps improve digestion, enhances satiety, and prevents overeating.",
      "Limit Red Meat" => "Limiting red meat intake reduces the risk of heart disease, stroke, and certain cancers.",
      "Practice Self-Care" => "Self-care activities enhance physical and mental well-being, reducing stress and improving life satisfaction.",
      "Have a Cheat Meal" => "Occasional cheat meals can prevent diet burnout and help sustain long-term healthy eating habits.",
      "Try Meditation" => "Meditation helps reduce stress, improve concentration, and enhance emotional well-being.",
      "Avoid Eating Out" => "Eating at home allows you to control ingredients and portion sizes, promoting healthier eating.",
      "Plan a Healthy Grocery List" => "Planning a grocery list helps ensure you buy nutritious foods and avoid unhealthy impulse purchases.",
      "Cook at Home" => "Cooking at home promotes healthier eating, saves money, and provides an opportunity for family bonding.",
      "Focus on Whole Foods" => "Whole foods are nutrient-dense and provide essential vitamins, minerals, and fiber.",
      "Drink a Glass of Water Before Meals" => "Drinking water before meals can help control appetite and support weight management.",
      "Avoid Added Sugars" => "Avoiding added sugars helps control weight, reduce the risk of chronic diseases, and improve dental health.",
      "Plan Healthy Snacks" => "Planning healthy snacks ensures you have nutritious options available and prevents unhealthy snacking.",
      "Limit Dairy Intake" => "Limiting dairy can reduce the risk of lactose intolerance symptoms and improve digestion.",
      "Avoid Overeating" => "Avoiding overeating helps maintain a healthy weight and supports digestive health.",
      "Eat Mindfully" => "Mindful eating enhances the enjoyment of food, improves digestion, and prevents overeating.",
      "Practice Gratitude" => "Gratitude improves emotional well-being, reduces stress, and fosters positive relationships.",
      "Limit Screen Time Before Bed" => "Limiting screen time before bed improves sleep quality and reduces the risk of insomnia.",
      "Set a Sleep Routine" => "A consistent sleep routine supports better sleep quality and overall health.",
      "Try a New Hobby" => "Trying new hobbies can reduce stress, improve creativity, and provide a sense of accomplishment.",
      "Limit Artificial Sweeteners" => "Limiting artificial sweeteners can help reduce cravings for sweet foods and support weight management.",
      "Spend Time with Family" => "Spending time with family strengthens relationships, improves emotional well-being, and provides support.",
      "Volunteer" => "Volunteering boosts mental well-being, provides a sense of purpose, and builds social connections.",
      "Practice Forgiveness" => "Forgiveness reduces stress, improves mental health, and strengthens relationships.",
      "Reduce Stress" => "Reducing stress improves overall health, supports better sleep, and enhances mental clarity.",
      "Manage Time Effectively" => "Effective time management reduces stress, improves productivity, and creates more free time.",
      "Practice Patience" => "Patience enhances emotional well-being, improves relationships, and reduces stress.",
      "Stay Positive" => "Positive thinking improves mental health, reduces stress, and increases resilience.",
      "Practice Compassion" => "Compassion enhances emotional well-being, fosters positive relationships, and reduces stress.",
      "Avoid Negativity" => "Avoiding negativity supports better mental health, reduces stress, and promotes positive relationships.",
      "Focus on Solutions" => "Focusing on solutions improves problem-solving skills, reduces stress, and increases productivity.",
      "Take Breaks During Work" => "Regular breaks during work improve focus, reduce stress, and enhance productivity."
    }
    faqs[habit_name]
  end
end
