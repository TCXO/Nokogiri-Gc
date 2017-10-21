require 'nokogiri'
require 'open-uri'

url = 'http://girlschannel.net/topics/1175980/'

charset = nil

html = open(url) do |f|
    charset = f.charset
    f.read
end

doc = Nokogiri::HTML.parse(html, nil, charset)
doc.xpath("/html/body/div[1]/div[1]/div/div[3]/ul").each do |node|
  # p node.css("comment-item")
  # p node.children
end

# puts doc.xpath("//*[@id=\"comment1\"]")
puts doc.xpath("/html/body/div[1]/div[1]/div/div[3]/ul/li").size
@comment_name = doc.xpath("//*[@id=\"comment1\"]").css("p").children[0]
@comment_date = doc.xpath("//*[@id=\"comment1\"]").css("p").children[1].children
@comment_plus = doc.xpath("//*[@id=\"comment1\"]").css("p").children[3]
@comment_minus = doc.xpath("//*[@id=\"comment1\"]").css("p").children[4]
@commnet_body = doc.xpath("//*[@id=\"comment3\"]/div[1]").children.to_s.gsub(/[\s\S]*<!-- logly_body_begin -->/, "").gsub(/<!-- logly_body_end -->[\s\S]*/, "")
puts "@comment_name: #{@comment_name}"
puts "@comment_date: #{@comment_date}"
puts "@comment_plus: #{@comment_plus}"
puts "@comment_minus: #{@comment_minus}"

# puts "@commnet_body: #{@commnet_body}"
puts doc.xpath("//*[@id=\"comment2\"]/div[1]").children.to_s.gsub(/\s/, "")
puts doc.xpath("//*[@id=\"comment2\"]/div[1]")[0][:class]
# puts doc.xpath("/html/body/div[1]/div[1]/div/div[4]/ul").class("pager pager-topic").size
# puts doc.xpath("/html/body/div[1]/div[1]/div/div[4]/ul/li")[0][:class]
puts doc.xpath("/html/body/div[1]/div[1]/div/div[4]/ul/li")[0][:class].to_s.include?("first")
