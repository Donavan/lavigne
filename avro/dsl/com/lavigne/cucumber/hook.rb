namespace 'com.lavigne.cucumber'

record :hook do
  required :match, :match_rec
  required :result, :result_rec
  optional :output, :array, items: :string
end
