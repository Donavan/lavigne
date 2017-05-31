namespace 'com.lavigne.cucumber'

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