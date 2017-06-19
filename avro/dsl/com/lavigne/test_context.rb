namespace 'com.lavigne'

record :test_context do
  required :context_id, :string
  optional :parent_context_id, :string
  optional :name, :string
  optional :line, :long
  optional :description, :string
  optional :passing_test_cases, :long, default: 0
  optional :failing_test_cases, :long, default: 0
  optional :other_test_cases, :long, default: 0
  optional :tags, :array, items: :string
  optional :test_cases, :array, items: :test_case
  optional :output, :array, items: :string
end
