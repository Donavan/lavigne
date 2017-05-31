namespace 'com.lavigne.cucumber'

record :row do
  required :cells, :array, items: :string
end
