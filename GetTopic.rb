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

# GetTopicInfo("1142480") #page: 604
# puts "------------------------------------------------------------------------"
# GetTopicInfo("1395446") #page: 1
# puts "------------------------------------------------------------------------"
# GetTopicInfo("1405488") #page: 4
# puts "------------------------------------------------------------------------"
# GetTopicInfo("1396506") #page: 7
# puts "------------------------------------------------------------------------"
# GetTopicInfo("1398331") #page: 8
# puts "------------------------------------------------------------------------"
# GetTopicInfo("19872") #page: 1, del_com: position_2

# CommentCount("19872")
