namespace 'com.lavigne.cucumber'

record :scenario do
  optional :scenario_id, :string
  required :keyword, :string
  required :scenario_name, :string
  required :description, :string
  required :line, :long
  required :type, :string
  required :status, :string
  required :steps, :array, items: :step
  required :passing_steps, :long, default: 0
  required :failing_steps, :long, default: 0
  required :other_steps, :long, default: 0
  optional :example_row, :row
  optional :error_message, :string
  optional :tags, :array, items: :tag
  optional :output, :array, items: :string
  optional :before, :array, items: :hook
  optional :after, :array, items: :hook
  optional :around, :array, items: :hook
end
