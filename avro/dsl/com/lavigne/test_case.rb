namespace 'com.lavigne'

enum :test_case_type, symbols: %i[other cucumber]

record :test_case do
  required :test_case_type, :test_case_type
  required :test_case_id, :string
  required :name, :string
  required :keyword, :string
  required :status, :string
  optional :parent_context_id, :string
  optional :line, :long                 # TODO: Make an optional file string here?
  optional :description, :string
  optional :error_message, :string
  optional :tags, :array, items: :string
  optional :output, :array, items: :string
  optional :meta, :array, items: :kv_pair
end