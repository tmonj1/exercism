# get the day of the week from year, month and day of the month
def dayofweek_from_date:
  "\(.year)-\(.month)-\(.day)T00:00:00Z"
  | fromdate
  | gmtime[6]
;

# get the day of the week from its name
def dayofweek_from_name:
  {
    "Sunday": 0,
    "Monday": 1,
    "Tuesday": 2,
    "Wednesday": 3,
    "Thursday": 4,
    "Friday": 5,
    "Saturday": 6
  } as $dayofweektable
  | $dayofweektable[.]
;

def last_day_of_month:
  {
    "1": 31, "2": 28, "3": 31,  "4": 30,  "5": 31,  "6": 30,
    "7": 31, "8": 31, "9": 30, "10": 31, "11": 30, "12": 31
  } as $monthdaytable
  | if .month != 2 then
      .month | tostring | $monthdaytable[. | tostring]
    else
      if (.year % 4 == 0 and (.year % 100 != 0 or .year % 400 == 0)) then
        29
      else
        28
      end
    end
;

def to2digits:
  if . <= 9 then
    "0" + (. | tostring)
  else
    (. | tostring)
  end
;
      

. as $input
| if .week != "teenth" then (
    {
      year: .year,
      month: .month,
      day: 1
    }
  )
  else (# "first, second, .."
    {
      year: .year,
      month: .month,
      day: 13
    }
  )
  end
| dayofweek_from_date as $base_day_of_week
| $input.dayofweek
| dayofweek_from_name as $target_day_of_week
| $input
| if .week == "teenth" then (
    $target_day_of_week - $base_day_of_week + 13
    | (if . < 13 then . + 7 else . end)
  )
  else ( # first, second ..
    .week as $week
    | .year as $year
    | .month as $month
    # first date of the day of week
    | $target_day_of_week - $base_day_of_week + 1
    | (if . < 1 then . + 7 else . end)
    | if $week == "first" then
        .
      elif $week == "second" then
        . + 7
      elif $week == "third" then
        . + 14
      elif $week == "fourth" then
        . + 21
      else # $week == "last"
        (
          if (. + 28) > ({year: $year, month: $month} | last_day_of_month) then
            . + 21
          else
            . + 28
          end
        )
      end
  )
  end
| . as $dayofmonth
| $input
| "\(.year)-\(.month | to2digits)-\($dayofmonth | to2digits)"