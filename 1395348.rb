require './GetTopicInfo.rb'


GetTopicInfo(topicid: "1395348") #page: 3, life: ok
1.upto @max_pages do |i|
  # puts "i: #{i}"
  GetTopicPage("1395348", i)
  1.upto 500 do |j|
    # puts "i-j: #{i}-#{j}, #{j+((i-1)*500)}"
    GetComment(j+((i-1)*500))
  end
end

# GetTopicPage("1395348", 3)
# GetComment("1206")
# GetComment("1205")


# 1.upto @comments do |i|
#   puts "i: #{i}"
# end

# GetTopicPage("19872", "1")
# GetComment("2")
# GetComment("3")


# $current_page = 1
# $topicid = '1395348/' + $current_page
# GetTopicInfo($topicid, $current_page)
# @max_pages.times do |i|
#   GetTopicInfo($topicid, i)
#   @current_page_comments.times do |j|
#     GetComment(($current_page * i) + j)
#     puts "@comment_tmp[:name]: #{@comment_tmp[:name]}"
#     puts "@comment_tmp[:date]: #{@comment_tmp[:date]}"
#     puts "@comment_tmp[:plus]: #{@comment_tmp[:plus]}"
#     puts "@comment_tmp[:minus]: #{@comment_tmp[:minus]}"
#     puts "@comment_tmp[:body]: #{@comment_tmp[:body]}"
#     puts "@comment_tmp[:format]: #{@comment_tmp[:format]}"
#   end
# end

# GetTopicInfo("1395348", "1")
# puts "@current_page_comments: #{@current_page_comments}"
# GetComment("500")
# puts "@comment_tmp[:name]: #{@comment_tmp[:name]}"
# puts "@comment_tmp[:date]: #{@comment_tmp[:date]}"
# puts "@comment_tmp[:plus]: #{@comment_tmp[:plus]}"
# puts "@comment_tmp[:minus]: #{@comment_tmp[:minus]}"
# puts "@comment_tmp[:body]: #{@comment_tmp[:body]}"
# puts "@comment_tmp[:format]: #{@comment_tmp[:format]}"

# @current_page_comments.times do |i|
#   i += 1
#   GetComment(i)
#   puts "@comment_tmp[#{i}][:body]: #{@comment_tmp[:body]}"
# end
