namespace 'com.lavigne.cucumber'

record :step do
  required :keyword, :string
  required :name, :string
  required :line, :long
  required :location, :string
  required :status, :string
  required :background, :boolean, default: false
  optional :error_message, :string
  optional :duration, :long
  optional :embeddings, :array, items: :embedding
  optional :output, :array, items: :string
  optional :rows, :array, items: :row
  optional :before, :array, items: :hook
  optional :after, :array, items: :hook
  optional :around, :array, items: :hook
end
