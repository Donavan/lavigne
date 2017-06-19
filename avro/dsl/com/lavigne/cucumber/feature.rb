namespace 'com.lavigne.cucumber'

record :feature do
  extends :test_context
  required :uri, :string
  optional :scenarios, :array, items: :scenario
  optional :before, :array, items: :hook
  optional :after, :array, items: :hook
  optional :around, :array, items: :hook
end
