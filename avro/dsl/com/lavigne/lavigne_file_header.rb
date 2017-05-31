namespace 'com.lavigne'
record :lavigne_file_header do
  required :lavigne_version, :string
  required :ruby_version, :string
  optional :cucumber_version, :string
end