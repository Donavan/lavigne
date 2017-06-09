namespace 'com.lavigne.cucumber'

record :scenario do
  optional :scenario_id, :string
  required :keyword, :string
  required :scenario_name, :string
  required :description, :string
  required :line, :long
  required :type, :string
  optional :tags, :array, items: :tag
  optional :output, :array, items: :string
  required :steps, :array, items: :step
end
