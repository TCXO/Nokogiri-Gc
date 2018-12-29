require './GetTopicInfo.rb'


json_data = open('/Users/mbp13/Documents/github/Nokogiri-Gc/alldata_json.json') do |io|
  JSON.load(io)
  # JSON.load(io, nil,{ :symbolize_names=>true })
end

puts json_data
puts JSON.parse(json_data.to_s, symbolize_names: true)

# puts "json_data: #{JSON.parse(json_data, symbolize_names: true)}"

# File.open('/Users/mbp13/Documents/github/Nokogiri-Gc/alldata_json.json') do |file|
#   @hash = JSON.load(file)
#   puts "-"*80
#   puts "hash: #{@hash["topic_info"]["1"]}"
#   puts "-"*80
#   # @json = @hash.to_json
#   @json = JSON.parse(@hash["topic_info"]["1"], symbolize_names: true)
# end
#
# puts "hash: #{@hash["topic_info"]}"
# puts "json: #{@json}"
