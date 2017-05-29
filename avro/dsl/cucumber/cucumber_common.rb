# Common types for Lavigne files containing Cucumber results.
record :tag do
  required :name, :string
  required :line, :long
end

record :row do
  required :cells, :array, items: :string
end

record :embedding do
  required :mime_type, :string
  required :data, :string
end

record :match_rec do
  required :location, :string
end

record :result_rec do
  required :status, :string
  optional :duration, :long
end

record :hook do
  required :match, :match_rec
  required :result, :result_rec
  optional :output, :array, items: :string
end

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

record :scenario do
  optional :id, :string
  required :keyword, :string
  required :name, :string
  required :description, :string
  required :line, :long
  required :type, :string
  optional :tags, :array, items: :tag
  optional :output, :array, items: :string
  optional :before, :array, items: :hook
  optional :after, :array, items: :hook
  optional :around, :array, items: :hook
  required :steps, :array, items: :step
end

record :feature do
  required :uri, :string
  required :id, :string
  required :keyword, :string
  required :name, :string
  required :description, :string
  required :line, :long
  optional :tags, :array, items: :tag
  required :elements, :array, items: :scenario
  optional :output, :array, items: :string
  optional :before, :array, items: :hook
  optional :after, :array, items: :hook
  optional :around, :array, items: :hook
end