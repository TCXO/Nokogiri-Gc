require './GetTopicInfo.rb'

$topicdata = Array.new()
$alldata_json = {topic_info: Hash.new()}

# [1, 38, 39, 1947117].each do |item|
[1, 2].each do |item|
  puts "item:  #{item}"
  GetTopicInfo(topicid: item)
  # puts "$page_info.to_json: #{$page_info.to_json}"
  # $alldata_json[:topic_info][item.to_s.to_sym] = JSON.pretty_generate($topicinfo)
  $alldata_json[:topic_info][item.to_s.to_sym] = $topicinfo.to_json
end


$alldata_json[:topic_info].each {|item| puts "item: #{item}"}


#Jsonファイル出力
json_filepath = %x{pwd}.chomp + "/alldata_json.json"
puts "json_filepath: #{json_filepath}"
open(json_filepath, 'w') do |io|
  JSON.dump($alldata_json, io)
end
