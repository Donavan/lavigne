namespace 'com.lavigne'

record :tag do
  required :tag_name, :string
  optional :line, :long  # TODO: Do we care?  Couldn't these just be strings?
end
