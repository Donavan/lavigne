namespace 'com.lavigne'
record :version_info_header do
  required :versions, :array, items: :version_info
end