namespace 'com.lavigne.cucumber'

record :row do
  optional :number, :long
  optional :line, :long
  required :values, :array, items: :string
end
