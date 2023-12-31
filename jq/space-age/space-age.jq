{
  "Mercury": 0.2408467,
  "Venus": 0.61519726,
  "Earth": 1.0,
  "Mars": 1.8808158,
  "Jupiter": 11.862615,
  "Saturn": 29.447498,
  "Uranus": 84.016846,
  "Neptune": 164.79132
} as $ratio
| try (
    .seconds / (31557600 * $ratio[.planet])
    | . * 100 | round | . / 100
  ) catch (
    "not a planet" | halt_error
  ) 
