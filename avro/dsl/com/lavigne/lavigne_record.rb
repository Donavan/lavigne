namespace 'com.lavigne'

enum :record_type, symbols: %i[header feature version_info_header run_info kvp headers_end]

record :lavigne_record do
  required :rec_type, :record_type
  optional :data, union(:run_info, :version_info_header, :kvp_header, :bytes)
end
