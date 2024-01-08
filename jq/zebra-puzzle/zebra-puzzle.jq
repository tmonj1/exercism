#
# Functions
#

# assignable_positions1:
#   find assignable positions.
#
# parameters:
#   constraint: a constraint
#
# input:
#   {state:[], constraints:[] history:[]}
# 
# output:
#   an array of assignable position (e.g. [0, 1, 3])
#
def assignable_positions1(constraint):
  . as $input
  | if (constraint | type) == "object" then # condition within a house
      constraint
      | to_entries
      | .[0].key as $key1 | .[0].value as $value1
      | .[1].key as $key2 | .[1].value as $value2
      | $input.state
      # position is alreadey specified -> determined
      | if $key1 == "house_position" or $key2 == "house_position" then
          if $key1 == "house_position" then
            if .[$value1][$key2] == "" then [constraint.house_position] else [] end
          else # $key2 == "house_position"
            if .[$value2][$key1] == "" then [constraint.house_position] else [] end
          end 
        # otherwise, recursively follow properties and determine all possible positions
        else
          reduce .[] as $state (
            {assignable_positions: [], found: false};
            if .found | not then
              if $state[$key1] == $value1 and ($key2 != null and $state[$key2] == $value2) then
                {
                  assignable_positions: [$state["house_position"]],
                  found: true
                }
              elif ($state[$key1] == "" and ($key2 == null or $state[$key2] == ""))
                or
                 ($state[$key1] == $value1 and ($key2 == null or $state[$key2] == ""))
                or
                 ($state[$key2] == $value2 and $state[$key1] == "") then
                    {
                      assignable_positions: (.assignable_positions + [$state["house_position"]]),
                      found: false
                    }
              else
                .
              end
            else
              .
            end
          )
          | .assignable_positions
        end
    else # (constraint | type) == []  # condition across two houses
      constraint
      | reduce .[] as $constraint (
         [];
         . as $o
         | $constraint
         | $o + to_entries
      )
      | .[0].key as $key1 | .[0].value as $value1
      | .[1].key as $key2 | .[1].value as $value2 
      | $input.state
      | reduce .[] as $state (null; if $state[$key1] == $value1 then $state["house_position"] else . end)
      | . as $left_position
      | $input.state
      | reduce .[] as $state (null; if $state[$key2] == $value2 then $state["house_position"] else . end)
      | . as $right_position
      | $input.state as $states
      | if $left_position != null and $right_position != null then
          if $right_position == $left_position + 1 then
             [$left_position]
          else
            []
          end
        elif $left_position != null and $right_position == null then
          if $left_position < (($states | length) - 1)
             and $states[$left_position + 1][$key2] == "" then
            [$left_position]
          else
            []
          end 
        elif $left_position == null and $right_position != null then
          if $right_position > 0
             and $states[$right_position - 1][$key1] == "" then
             [$right_position - 1]
          else
            []
          end
        else # $left_position == null and $right_position == null
          [range(0; ($states |length) - 1)]
          | reduce .[] as $index(
            [];
            if $states[$index][$key1] == "" and $states[$index + 1][$key2] == "" then
              . + [$index]
            else
              .
            end
          )
        end
    end
;

def assignable_positions(constraint):
  . as $input
  | constraint
  | reduce .[] as $c ([]; . + [$input | assignable_positions1($c)])
;

# apply_constraint:
#   assign a constraint at an assignable position and return the updated input.
#
# parameters:
#   constraint: a constraint
#   index: N th element in one or more conditions in a constraint
#   position: house position
#
# input:
#   {state:[], constraints:[] history:[]}
#
# output:
#   updated input.
#
def apply_constraint(constraint; index; position):
  constraint[index] as $constraint
  | . as $input
  | if ($constraint | type) == "object" then 
      (position // $constraint["house_position"]) as $position
      | if $position != null then
          {
            state: (
              .state[:$position]
              + ([.state[$position] + $constraint])
              + .state[$position + 1:]
            ),
            constraints: (.constraints - [constraint]),
            history: (.history + [$constraint])
          }
        else
          .
        end
    else
      if position != null then
        position as $position
        | {
            state: (
              .state[:$position]
              + ([.state[$position] + $constraint[0]])
              + ([.state[$position + 1] + $constraint[1]])
              + .state[$position + 2:]
            ),
            constraints: (.constraints - [constraint]),
            history: (.history + [$constraint])
          }
      else
        .
      end
    end
;

# try_apply:
#   assign a constraint to an assignable position and recursively call itself.
#
# input:
#   {state:[], constraints:[] history:[]}
#
# output:
#   update input if a constraint was assigned. empty if there is no assignable position.
def try_apply:
  . as $input
  | if .constraints == [] then
      .
    else 
      (.constraints | first) as $constraint
      | assignable_positions($constraint)
      | . as $assignable_positions
      | reduce [range(0;length)][] as $index (
          null;
          if . == null then
            reduce $assignable_positions[$index][] as $position (
              null;
              if . == null then
                . as $out
                | $input
                | apply_constraint($constraint; $index; $position)
                | if . != null then
                    try_apply
                  else
                    .
                  end
              else
                .
              end
            )
          else
            .
          end
        )
      # null if there's no assignable position
      | if . == null then
          empty
        else
          .
        end
    end
;

#
# constraints
#
#  * $constraint has all constraints
#  * each constraint consists of an array of "OR" conditions
#  * each condition is in the form of object or array;
#    the former is a condition within an house, the latter a condition across two houses.

[
  # constraint #1:  There are five houses. --> $number_of_houses

  # constraint #2: The Englishman lives in the red house.
  [
    {
      house_color: "red",
      inhabitant: "Englishman"
    }
  ],
  # constraint #3: The Spaniard owns the dog.
  [
    {
      inhabitant: "Spaniard",
      owns: "dog"
    }
  ],
  # constraint #4: Coffee is drunk in the green house.
  [
    {
      house_color: "green",
      drinks: "coffee"
    }
  ],
  # constraint #5: The Ukrainian drinks tea.
  [
    {
      inhabitant: "Ukrainian",
      drinks: "tea"
    }
  ],
  # constraint #6: The green house is immediately to the right of the ivory house.
  [
    [
      {
        house_color: "ivory"
      },
      {
        house_color: "green"
      }
    ]
  ],
  # constraint #7: The Old Gold smoker owns snails.
  [
    {
      owns: "snails",
      smokes: "Old Gold"
    }
  ],
  # constraint #8: Kools are smoked in the yellow house.
  [
    {
      house_color: "yellow",
      smokes: "Kools"
    }
  ],
  # constraint #9: Milk is drunk in the middle house.
  [
    {
      house_position: 2,
      drinks: "milk"
    }
  ],
  # constraint #10: The Norwegian lives in the first house.
  [
    {
      house_position: 0,
      inhabitant: "Norwegian"
    }
  ],
  # constraint #11: The man who smokes Chesterfields lives in the house next to the man with the fox.
  [
    [
      {
        smokes: "Chesterfields"
      },
      {
        owns: "fox"
      }
    ],
    [
      {
        owns: "fox"
      },
      {
        smokes: "Chesterfields"
      }
    ]
  ],
  # constraint #12: Kools are smoked in the house next to the house where the horse is kept.
  [
    [
      {
        smokes: "Kools"
      },
      {
        owns: "horse"
      }
    ],
    [
      {
        owns: "horse"
      },
      {
        smokes: "Kools"
      }
    ]
  ],
  # constraint #13: The Lucky Strike smoker drinks orange juice.
  [
    {
      smokes: "Lucky Strike",
      drinks: "orange juice"
    }
  ],
  # constraint #14: The Japanese smokes Parliaments.
  [
    {
      inhabitant: "Japanese",
      smokes: "Parliaments"
    }
  ],
  # constraint #15: The Norwegian lives next to the blue house.
  [
    [
      {
        inhabitant: "Norwegian"
      },
      {
        house_color: "blue"
      }
    ],
    [
      {
        house_color: "blue",
      },
      {
        inhabitant: "Norwegian"
      }
    ]
  ]
] as $constraints

#
# Solve the problem
#

# set up the initial state -> $initial_state
| . as $input
| 5 as $number_of_houses  # constraint #1
| [range(0;$number_of_houses)] | map(
    {
      house_position: .,
      house_color: "",
      inhabitant: "",
      owns: "",
      smokes: "",
      drinks: ""
    }
  )
| . as $initial_state

# solve the problem -> $final_state
| {state: $initial_state, constraints: $constraints, history: []}
| try_apply
| .state as $final_state

#
# Answer questions (who owns zebra and who drinks water)
#

| $input
| .property |{key: match("[a-z]+").string, value: (match("[A-Z][a-z]+").string | ascii_downcase)} as $question
| $final_state
| reduce .[] as $house (
    null;
    ($house[$question["key"]] | ascii_downcase) as $value
    | if $value == $question["value"] or ($value == "" and . == null) then
        $house["inhabitant"]
      else
        .
      end 
  )