# The input will be an array of arrays representing the daily bird counts.
# The data is organized into weekly arrays.
# The data is organized chronologically: 
# - this week's data is the last element of the array, and 
# - today's count is the last element of this week's data

# The output of this exercise is a JSON object,
# one key:value pair per task.

{
  # Task 1: output the array for last week's data
  last_week: ((length - 2) as $l | .[$l]),

  # Task 2: output count for yesterday in this week's data
  yesterday: ((length - 1) as $l | .[$l] | (length - 1) as $l2 | .[$l2 - 1]),
  
  # Task 3: output sum of counts for this week's data
  total: ((length - 1) as $l | .[$l] | add),
  
  # Task 4: output number of days with 5 or more birds in this week's data
  busy_days: ((length - 1) as $l | .[$l] | map(select(. >= 5)) | length),
  
  # Task 5: output true if any day this week has zero birds
  has_day_without_birds: ((length - 1) as $l | .[$l] | map(select(. == 0)) | length > 0)
}
