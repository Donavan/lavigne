namespace 'com.lavigne.cucumber'

record :result_rec do
  required :status, :string
  optional :duration, :long
end
