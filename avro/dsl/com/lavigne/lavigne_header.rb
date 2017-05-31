namespace 'com.lavigne'
enum :header_type, symbols: [:file_header, :run_info, :kvp, :headers_end]

record :lavigne_header do
  required :type, :header_type
  optional :header, union(:run_info, :lavigne_file_header, :kvp_header)
end
