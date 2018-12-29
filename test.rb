require './GetTopicInfo.rb'

puts JSON.parse('{"key": {"key2": "value2"}}', symbolize_names: true)

File.open('/Users/mbp13/Documents/github/Nokogiri-Gc/alldata_json.json') do |file|
  @hash = JSON.load(file)
  # @json = @hash.to_json
  @json = JSON.parse(@hash["topic_info"], {:symbolize_names => true})
end

puts "hash: #{@hash["topic_info"][1]}"
puts "json: #{@json}"

# GetTopicInfo(topicid: 17) #page: 3, life: ok
# GetTopicPage(topicid: 17, topic_page: 1)
#
# 1.upto(10) do |i|
#   puts "i : #{i}"
#   GetComment(comment_id: i)
# end

# GetTopicPage(topicid: 1680466, topic_page: 1)
#
# 395.upto(397) do |i|
#   puts "------------------------- i : #{i} ------------------------- \n"
#   GetComment(comment_id: i)
# end

# 1.upto $page_info[:total_pages] do |i|
#   # puts "i: #{i}"
#   GetTopicPage(topicid: 1791173, topic_page: i)
#
#   1.upto 500 do |j|
#     # puts "i-j: #{i}-#{j}, #{j+((i-1)*500)}"
#     GetComment(j+((i-1)*500))
#     # return if (i-1)*500 > $page_info[:total_comments]
#   end
# end
#
# p $topicdata
# GetTopicAllData(topicid: "1694702")



#以下の183, 397は2リンク+1画像を保有
#http://girlschannel.net/topics/1680466/

# 183: //*[@id="comment183"]/div[1]/div[3]/img
# 185: //*[@id="comment185"]/div[1]/div/img

# id=1にリンクと画像1ヶあり
# https://girlschannel.net/topics/1694702/

#1694702 -> Real: 5m40s
# $page_info: {:topicid=>\"1694702\", :total_comments=>1394, :total_pages=>3}"
