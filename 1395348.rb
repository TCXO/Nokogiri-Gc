require 'nokogiri'
require 'open-uri'
require 'pp'

url = 'http://girlschannel.net/topics/1395348/'

charset = nil

html = open(url) do |f|
    charset = f.charset
    f.read
end

$doc = Nokogiri::HTML.parse(html, nil, charset)
$doc.xpath("/html/body/div[1]/div[1]/div/div[3]/ul").each do |node|
  # p node.css("comment-item")
  # p node.children
end

if $doc.xpath("/html/body/div[1]/div[1]/div/div[4]/ul/li")[0][:class].to_s.include?("first")
  @max_pages = $doc.xpath("/html/body/div[1]/div[1]/div/div[4]/ul/li").size - 4
else
  @max_pages = 1
end

# puts $doc.xpath("//*[@id=\"comment1\"]")
@current_page_comments = $doc.xpath("/html/body/div[1]/div[1]/div/div[3]/ul/li").size

def GetComment(comment_id)
  #Deleted comment
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
end

GetComment(501)
# puts "@comment_tmp: #{@comment_tmp.inspect}"
puts "@comment_tmp[:name]: #{@comment_tmp[:name]}"
puts "@comment_tmp[:date]: #{@comment_tmp[:date]}"
puts "@comment_tmp[:plus]: #{@comment_tmp[:plus]}"
puts "@comment_tmp[:minus]: #{@comment_tmp[:minus]}"
puts "@comment_tmp[:body]: #{@comment_tmp[:body]}"
puts "@comment_tmp[:format]: #{@comment_tmp[:format]}"

@current_page_comments.times do |i|
  i += 1
  GetComment(i)
  puts "@comment_tmp[#{i}][:body]: #{@comment_tmp[:body]}"
end




# puts "@current_page_comments: #{@current_page_comments}"
# puts "@comment_name: #{@comment_name}"
# puts "@comment_date: #{@comment_date}"
# puts "@comment_plus: #{@comment_plus}"
# puts "@comment_minus: #{@comment_minus}"
# puts "@commnet_body: #{@commnet_body}"
# puts "@commnet_wordstyle: #{@commnet_wordstyle}"
# puts "@max_pages: #{@max_pages}"
