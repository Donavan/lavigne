namespace 'com.lavigne'
enum :header_type, symbols: %i[version_info run_info kvp headers_end]

record :lavigne_header do
  required :type, :header_type
  optional :header, union(:version_info_header, :run_info, :kvp_header)
end
