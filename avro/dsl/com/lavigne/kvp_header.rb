namespace 'com.lavigne'
record :kvp_header do
  required :name, :string
  required :values, :array, items: :kv_pair
end