# combinations:
#   produce possible combinations of items as an array (each element is a combination,
#   so it it also an array)
#
# parameters:
#   left_capacity: left capacity
#   chosen_items: items already in the knapsack
#   used_items: items already included in other calculation branches
#
# description:
#   1. recursively pick up items one by one until the total weight reaches the limit.
#   2. when picking up, exclude items already included in other calculation branches
#      (This is necessary to keep the calculation cost within a reasonable range.)
def combinations(left_capacity; chosen_items; used_items):
  . as $input
  # exclude too heavy items and items which already used in other branches
  | map(
      select(
        . as $current_item
        | $current_item.weight <= left_capacity
          and
          ((used_items | index($current_item)) == null)
      )
    )
  | . as $items_to_add
  # recursively add possible combinations of items
  | reduce .[] as $item (
      # object to keep the all the combinations and used items
      {combinations: [], used_items: []};
      # add the current item to chosen items
      (chosen_items + [$item]) as $new_chosen_items
      # update capacity and item list which keeps the items not picked up yet
      | (left_capacity - $item.weight) as $new_left_capacity
      | ($items_to_add | index($item)) as $n
      | ($items_to_add[:$n] + $items_to_add[$n+1:]) as $new_items
      # if there's no items to pick up, keep the current state, otherwise make recursive calls
      | if $new_items == [] then
          . 
        else (
          .used_items as $used_items
          | {
            combinations: (
              .combinations
              + ($new_items | combinations($new_left_capacity; $new_chosen_items; $used_items))
            ),
            used_items: ($used_items + [$item])
          }
        )
        end
    )
  | .combinations as $more_combinations
  | $items_to_add
  | map(chosen_items + [.])
  | . as $current_combinations
  | $current_combinations + $more_combinations
;

.maximumWeight as $maximumWeight
| .items
| combinations($maximumWeight; []; [])
| reduce .[] as $ candidate_combination ([]; . + [([$candidate_combination | .[].value] | add)])
| max // 0

