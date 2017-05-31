namespace 'com.lavigne.cucumber'

record :step do
  required :keyword, :string
  required :name, :string
  required :line, :long
  required :match, :match_rec
  required :result, :result_rec
  optional :embeddings, :array, items: :embedding
  optional :output, :array, items: :string
  optional :rows, :array, items: :row
  optional :before, :array, items: :hook
  optional :after, :array, items: :hook
  optional :around, :array, items: :hook
end