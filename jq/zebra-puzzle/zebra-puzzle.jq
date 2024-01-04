def debug1(level; message):
  . as $o
  | (level | tostring) + " " * (level + 1) + (message | tostring | gsub("\""; "")) | debug
  | $o
;

def debug2(level; message1; message2):
  . as $o
  | (level | tostring) + " " * (level + 1) + (message1 | tostring | gsub("\""; "")) + " " + (message2 | tostring | gsub("\""; "")) | debug
  | $o
;

#
# Functions
#

def assignable_positions1(constraint):
  . as $input
  | if (constraint | type) == "object" then
      constraint
      | to_entries
      | .[0].key as $key1 | .[0].value as $value1
      | .[1].key as $key2 | .[1].value as $value2
      | $input.state
      # position is alreadey specified => determined
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
    else # (constraint | type) == [] 横の関係の制約
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
          #debug1($input.depth; "a") |
          if $right_position == $left_position + 1 then
             [$left_position]
          else
            []
          end
        elif $left_position != null and $right_position == null then
          #debug1($input.depth; "b") |
          #debug2($input.depth; "left_position: "; $left_position) |
          #debug2($input.depth; "property_name(left): "; $key1) |
          #debug2($input.depth; "property_value(left): "; $value1) |
          #debug2($input.depth; "property_name(right): "; $key2) |
          #debug2($input.depth; "property_value(right): "; $value2) |
          #debug2($input.depth; "left_state: "; $states[$left_position]) |
          #debug2($input.depth; "right_state: "; $states[$left_position+1]) |
          if $left_position < (($states | length) - 1)
             and $states[$left_position + 1][$key2] == "" then
            [$left_position]
          else
            []
          end 
        elif $left_position == null and $right_position != null then
          #debug1($input.depth; "c") |
          #debug2($input.depth; "right_position: "; $right_position) |
          #debug2($input.depth; "property_name: "; $key2) |
          #debug2($input.depth; "property_value: "; $value2) |
          #debug2($input.depth; "left_state: "; $states[$right_position-1]) |
          #debug2($input.depth; "right_state: "; $states[$right_position]) |
          if $right_position > 0
             and $states[$right_position - 1][$key1] == "" then
             [$right_position - 1]
          else
            []
          end
        else # $left_position == null and $right_position == null
          #debug1($input.depth; "d") |
          [range(0; ($states |length) - 1)]
          | reduce .[] as $index(
            [];
            #debug2($input.depth; "property_name1: "; $key1) |
            #debug2($input.depth; "property_name2: "; $key2) |
            #debug2($input.depth; "left_state: "; $states[$index]) |
            #debug2($input.depth; "right_state: "; $states[$index+1]) |
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

def check_constraints(constraints):
  . as $input
  | reduce constraints[] as $constraint (
      true;
      .
    )
;

# apply_constraint:
#   割付可能な場所に割り付けてapplyを再帰コールする。
#
# parameters:
#   constraint: 制約(1つ)
#   index: OR制約の場合、N番目の要素を表す
#   position: 割り付け先のhouse_position
#
# input:
#   {state:[], constraints:[] history:[], depth:number}
#
# output:
#   更新後のinput。割付不可能なときはinputを更新しないで返す。
def apply_constraint(constraint; index; position):
  constraint[index] as $constraint
  | . as $input
  | if ($constraint | type) == "object" then 
      (position // $constraint["house_position"]) as $position
      | if $position != null then
          {
            state: (
              .state[:$position]
              + ([.state[$position] + $constraint] | debug2($input.depth; "assigned: "; .[0]))
              + .state[$position + 1:]
            ),
            constraints: (.constraints - [constraint]),
            history: (.history + [$constraint]),
            depth: (.depth)
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
              + ([.state[$position] + $constraint[0]] | debug2($input.depth; "assigned: "; .[0]))
              + ([.state[$position + 1] + $constraint[1]] | debug2($input.depth; "assigned: "; .[0]))
              + .state[$position + 2:]
            ),
            constraints: (.constraints - [constraint]),
            history: (.history + [$constraint]),
            depth: (.depth)
          }
      else
        .
      end
      # | debug2(.depth; "empty applied"; $constraint[0])
    end
;

# try_apply:
#   割付可能な場所に割り付けて自分自身を再帰コールする。
#
# input:
#   {state:[], constraints:[] history:[], depth:number}
#
# output:
#   更新後のinput。割付可能な場所がなかったらempty。
def try_apply:
  debug1(.depth; "TRY")
  | . + {depth: (.depth + 1)}
  | . as $input
  | if .depth > 20 then
      .
      | . as $o | "max depth reached" | debug | $o
    else
      if .constraints == [] then
        .
        | debug1(.depth; "goal!!!")
      else 
        (.constraints | first) as $constraint
        | assignable_positions($constraint)
        | . as $assignable_positions
        | ("assignable_at: " + (. | tostring)) as $debug_message
        | debug1($input.depth; $debug_message)
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
        # 割付可能な位置がなかったときはここで null になる
        | if . == null then
            debug1($input.depth; "backtrack!!")
            | empty
          else
            .
          end
      end
    end
;

# apply:
#   適用可能な制約をすべて適用し、try_applyを再帰コール。
#
# input:
#   {state:[], constraints:[] history:[], depth:number}
#
# output:
#   更新後のinput   
def apply:
  . as $input
  # 全制約を順に適用
  #| reduce .constraints[] as $constraint (
  #    $input;
  #    apply_constraint($constraint; 0; null)
  #  )
  | try_apply
;

#
# constraints
#

[
  # constraint #1:  There are five houses. --> $number_of_houses

  # constraint #2: The Englishman lives in the red house.
  [
    {
      house_color: "red",
      inhabitant: "Englishman"
    }
  ],
  # # constraint #3: The Spaniard owns the dog.
  [
    {
      inhabitant: "Spaniard",
      owns: "dog"
    }
  ],
  # # constraint #4: Coffee is drunk in the green house.
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
    {house_position: ., house_color: "", inhabitant: "", owns: "", smokes: "", drinks: "" }
  )
| . as $initial_state

# solve the problem -> $final_state
| {state: $initial_state, constraints: $constraints, history: [], depth: 0}
| apply
| .state as $final_state
| debug

#
# Answer questions (who owns zebra and who drinks water)
#
#| $input
#| .property |{key: match("[a-z]+").string, value: (match("[A-Z][a-z]+").string | ascii_downcase)} as $question
#| $final_state
#| reduce .[] as $house (
#    null;
#    ($house[$question["key"]] | ascii_downcase) as $value
#    | if $value == $question["value"] or ($value == "" and . == null) then
#        $house["inhabitant"]
#      else
#        .
#      end 
#  )