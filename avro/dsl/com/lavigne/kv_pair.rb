namespace 'com.lavigne'

# An environment variable and it's value
record :kv_pair do
  required :name, :string
  optional :value, :string
end
