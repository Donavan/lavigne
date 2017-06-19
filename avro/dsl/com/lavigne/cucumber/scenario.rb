namespace 'com.lavigne.cucumber'

record :scenario do
  extends :test_case
  required :keyword, :string
  required :scenario_type, :string
  required :steps, :array, items: :step
  required :passing_steps, :long, default: 0
  required :failing_steps, :long, default: 0
  required :other_steps, :long, default: 0
  optional :example_row, :row
  optional :before, :array, items: :hook
  optional :after, :array, items: :hook
  optional :around, :array, items: :hook
end
