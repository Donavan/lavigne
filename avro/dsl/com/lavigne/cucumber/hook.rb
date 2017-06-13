namespace 'com.lavigne.cucumber'

record :hook do
  required :location, :string
  required :status, :string
  optional :duration, :long
  optional :error_message, :string
  optional :output, :array, items: :string
end
