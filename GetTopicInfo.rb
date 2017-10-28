require 'nokogiri'
require 'open-uri'


def GetTopicInfo(topic_id)
  url = 'http://girlschannel.net/topics/' + topic_id
  charset = nil
  html = open(url) do |f|
      charset = f.charset
      f.read
  end
  $doc = Nokogiri::HTML.parse(html, nil, charset)


  # Get HowManyPages this topic
  if $doc.xpath("/html/body/div[1]/div[1]/div/div[4]/ul/li")[0][:class].to_s.include?("first")
    @max_pages = $doc.xpath("/html/body/div[1]/div[1]/div/div[4]/ul/li").size - 4
    @max_pages = $doc.xpath("/html/body/div[1]/div[1]/div/div[2]/ul/li[9]/a").children if  @max_pages == 8
  else
    @max_pages = 1
  end

  puts "@max: #{@max_pages}"

  @current_page_comments = $doc.xpath("/html/body/div[1]/div[1]/div/div[1]/p/span[2]").children.to_s.match(/\d*/)
  puts "com: #{@current_page_comments}"
end

def GetTopicPage(topic_id, topic_page)
  url = "http://girlschannel.net/topics/#{topic_id}/#{topic_page}"
  charset = nil
  html = open(url) do |f|
      charset = f.charset
      f.read
  end
  $doc = Nokogiri::HTML.parse(html, nil, charset)
end


def GetComment(comment_id)
  #For Deleted comment, return nil.
  if $doc.xpath("//*[@id=\"comment#{comment_id}\"]").size == 0
    @comment_tmp = {name: NIL, date: NIL, plus: NIL, minus: NIL, body: NIL, format: NIL}
    return
  end

  comment_name = $doc.xpath("//*[@id=\"comment#{comment_id}\"]").css("p").children[0]
  comment_date = $doc.xpath("//*[@id=\"comment#{comment_id}\"]").css("p").children[1].children

  if comment_id == 1
    comment_plus = $doc.xpath("//*[@id=\"comment#{comment_id}\"]").css("p").children[3]
    comment_minus = $doc.xpath("//*[@id=\"comment#{comment_id}\"]").css("p").children[4]
    commnet_body = $doc.xpath("//*[@id=\"comment#{comment_id}\"]/div[1]").children.to_s.gsub(/[\s\S]*<!-- logly_body_begin -->/, "").gsub(/<!-- logly_body_end -->[\s\S]*/, "")
  else
    comment_plus = $doc.xpath("//*[@id=\"comment#{comment_id}\"]").css("p").children[5]
    comment_minus = $doc.xpath("//*[@id=\"comment#{comment_id}\"]").css("p").children[6]
    commnet_body = $doc.xpath("//*[@id=\"comment#{comment_id}\"]/div[1]").children.to_s.gsub(/\s/, "")
  end
  commnet_wordstyle = $doc.xpath("//*[@id=\"comment#{comment_id}\"]/div[1]")[0][:class]

  @comment_tmp = {name: comment_name, date: comment_date, plus: comment_plus, minus: comment_minus, body: commnet_body, format: commnet_wordstyle}

  # puts @comment_tmp
  puts "------------------------------------------------------------------------"
  puts "@comment_tmp[:name]: #{@comment_tmp[:name]}"
  puts "@comment_tmp[:date]: #{@comment_tmp[:date]}"
  puts "@comment_tmp[:plus]: #{@comment_tmp[:plus]}"
  puts "@comment_tmp[:minus]: #{@comment_tmp[:minus]}"
  puts "@comment_tmp[:body]: #{@comment_tmp[:body]}"
  puts "@comment_tmp[:format]: #{@comment_tmp[:format]}"
  puts "------------------------------------------------------------------------"
end

# GetTopicInfo("1142480") #page: 604, life: end
# puts "------------------------------------------------------------------------"
# GetTopicInfo("1395446") #page: 1, life: ok
# puts "------------------------------------------------------------------------"
# GetTopicInfo("1405488") #page: 4, life: ok
# GetTopicPage("1405488", "1")
# GetComment("3")
# puts "------------------------------------------------------------------------"
# GetTopicInfo("1396506") #page: 7
# puts "------------------------------------------------------------------------"
# GetTopicInfo("1398331") #page: 8, life: ok
# puts "------------------------------------------------------------------------"
# GetTopicInfo("19872") #page: 1, del_com: position_2

# CommentCount("19872")
