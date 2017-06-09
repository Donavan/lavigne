namespace 'com.lavigne.cucumber'

record :feature do
  required :uri, :string
  required :feature_id, :string
  required :keyword, :string
  required :feature_name, :string
  required :description, :string
  required :line, :long
  optional :tags, :array, items: :tag
  optional :scenarios, :array, items: :scenario
  optional :output, :array, items: :string
  optional :before, :array, items: :hook
  optional :after, :array, items: :hook
  optional :around, :array, items: :hook
end
