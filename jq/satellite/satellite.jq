def precheck:
  if (.preorder | length) != (.inorder | length) then
    ("traversals must have the same length" | halt_error)
  elif (.preorder | sort) != (.inorder | sort) then
    ("traversals must have the same elements" | halt_error)
  else
    if ((.preorder | sort | join("") | test("(.)\\1")) or
        (.inorder  | sort | join("") | test("(.)\\1"))) then
      ("traversals must contain unique items" | halt_error)
    else
      .
    end
  end
;

def generate_tree:
  if .preorder == [] then
    {}
  else (
    . as $input
    | (.preorder | first) as $v
    | (.inorder | index($v)) as $b
    | .inorder[:(.inorder | index($v))] as $lefts
    | .inorder[(.inorder | index($v) + 1):] as $rights
    | {
        v: $v,
        l: (
          if $lefts == [] then
            {}
          else (
            {
              preorder: .preorder[1: ($lefts | length + 1)],
              inorder: $lefts
            } | generate_tree
          )
          end
        ),
        r: (
          if $rights == [] then
            {}
          else (
            {
              preorder: .preorder[($lefts | length + 1):],
              inorder: $rights
            } | generate_tree
          )
          end
        )
    }
  )
  end
;

precheck | generate_tree