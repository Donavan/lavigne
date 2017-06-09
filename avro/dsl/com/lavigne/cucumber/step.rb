namespace 'com.lavigne.cucumber'

record :step do
  required :keyword, :string
  required :name, :string
  required :line, :long
  required :location, :string
  required :status, :string
  optional :error_message, :string
  optional :duration, :long
  optional :embeddings, :array, items: :embedding
  optional :output, :array, items: :string
  optional :rows, :array, items: :row
end
