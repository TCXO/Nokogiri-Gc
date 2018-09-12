require 'nokogiri'
require 'open-uri'

# トピック情報の取得
def GetTopicInfo(topicid: )
  #トピック情報を取得
  url = 'http://girlschannel.net/topics/' + topicid.to_s
  charset = nil
  html = open(url) do |f|
      charset = f.charset
      f.read
  end

  #トピック情報格納
  $doc = Nokogiri::HTML.parse(html, nil, charset)


  #トピックのページ数取得
  # if $doc.xpath("/html/body/div[1]/div[1]/div/div[4]/ul/li")[0][:class].to_s.include?("first")
  #   @max_pages = $doc.xpath("/html/body/div[1]/div[1]/div/div[4]/ul/li").size - 4
  #   @max_pages = $doc.xpath("/html/body/div[1]/div[1]/div/div[2]/ul/li[9]/a").children if  @max_pages == 8
  # else
  #   @max_pages = 1
  # end
  #
  # puts "@max_pages: #{@max_pages}"

  @total_comments = $doc.xpath("/html/body/div[1]/div[1]/div/div[1]/p/span[2]").children.to_s.match(/\d*/).to_s.to_i
  @total_pages = (@total_comments/500.to_f).ceil

  $page_info = {topicid: topicid, total_comments: @total_comments, total_pages: @total_pages}

  p "$page_info: #{$page_info}"

end

# $docにページ情報を格納する
def GetTopicPage(topicid:, topic_page:)
  url = "https://girlschannel.net/topics/#{topicid.to_s}/#{topic_page.to_s}"
  html = open(url) do |f|
      charset = f.charset
      f.read
  end
  $doc = Nokogiri::HTML.parse(html, nil, 'utf-8')
end

# $docから各データを抽出する
def GetComment(comment_id:)
  #For Deleted comment, return nil.
  if $doc.xpath("//*[@id=\"comment#{comment_id}\"]").size == 0
    @comment_tmp = nil
    # @comment_tmp = {name: NIL, date: NIL, plus: NIL, minus: NIL, body: NIL, format: NIL}
    puts "comment nil."
    return
  end

  comment_name = $doc.xpath("//*[@id=\"comment#{comment_id}\"]").css("p").children[0].to_s.gsub!(/[[:space:]]$/, "").gsub!(/^.*[[:space:]]/, "")
  comment_date = $doc.xpath("//*[@id=\"comment#{comment_id}\"]").css("p").children[1].children.to_s
  comment_plus = $doc.xpath(%Q{//*[@id="vbox#{comment_id}"]/div[1]/p}).children[0].to_s.sub("+", "").to_i
  comment_minus = $doc.xpath(%Q{//*[@id="vbox#{comment_id}"]/div[3]/p}).children[0].to_s.sub("-", "").to_i
  comment_html = $doc.xpath("//*[@id=\"comment#{comment_id}\"]/div[1]").to_html

  #トピ主コメントにのみHTMLコメント有り
  if comment_id == 1
    comment_body = $doc.xpath("//*[@id=\"comment#{comment_id}\"]/div[1]").children.to_s.sub(/[\s\S]*<!-- logly_body_begin -->/, "").gsub(/<!-- logly_body_end -->[\s\S]*/, "")
  else
    comment_body = $doc.xpath("//*[@id=\"comment#{comment_id}\"]/div[1]").children.to_s.gsub(/\s/, "")
  end


  #コメントにリンクおよび画像が含まれている場合の置換処理
  $doc.xpath(%Q{//*[@id="comment#{comment_id}"]/div[1]/div}).each_with_index do |item, link_count|
    #リンク
    if item.to_s.include?(%Q{<div class="comment-url">})
      #リンク先タイトル
      title =  $doc.xpath(%Q{//*[@id="comment#{comment_id}"]/div[1]/div[#{link_count+1}]/div/div/a[1]}).children.text
      #リンク先URL
      url = $doc.xpath(%Q{//*[@id="comment#{comment_id}"]/div[1]/div[#{link_count+1}]/div/div/a[1]})[0][:href]

      #コメント内のHTMLと置換
      comment_include_url = "[LINK_TITLE: #{title}, URL: #{url}]\n"
      comment_body = comment_body.sub(%r{<divclass="comment-url"><divclass="comment-url-headflc">.*?</p></div></div></div>}, comment_include_url)
    #画像
    elsif item.to_s.include?(%Q{<div class="comment-img">})
      $doc.xpath(%Q{//*[@id="comment#{comment_id}"]/div[1]/div[#{link_count+1}]/img}).each_with_index do |item, idx|
        #up.gc-img.netの直リンURL
        data_src = item[:"data-src"]
        #画像のAlt情報
        alt = item[:alt]
        #外部画像リンク直接貼り付けの場合、出典元URLが含まれるため追加処理
        href = $doc.xpath(%Q{//*[@id="comment#{comment_id}"]/div[1]/div/a[1]})[0][:href] if $doc.xpath(%Q{//*[@id="comment#{comment_id}"]/div[1]/div/a[1]})[0]

        #コメント内のHTMLと置換
        comment_include_img = "[IMG: #{alt}, URL: #{data_src}, SOURCE: #{href}]\n"
        comment_body = comment_body.sub(%r{<divclass="comment-img">.*?</div>}, comment_include_img)

        #文字列の後尾に未改行で画像がついた場合の改行処理
        comment_body.lines do |line|
          comment_body.sub!(comment_include_img, "\n"+comment_include_img)　if line.match(%r{.+\[IMG:})
        end
      end
    else
      puts "uhh."
    end
  end

  #アンカーの置換処理
  $doc.xpath("//*[@id=\"comment#{comment_id}\"]/div[1]/span").each_with_index do |item, idx|
    #アンカー先の値とHTMLを取得
    html = $doc.xpath("//*[@id=\"comment#{comment_id}\"]/div[1]/span[#{idx+1}]")[0].to_html
    anchor = $doc.xpath("//*[@id=\"comment#{comment_id}\"]/div[1]/span[#{idx+1}]")[0].children.text

    #コメント内のHTMLと置換
    comment_include_anchor = "[ANCKER: #{anchor}]"
    comment_body = comment_body.sub(%r{<spanclass="res-anchor">.*?</span>}, comment_include_anchor)
  end


  # puts "com_orig: #{com_orig}"
  # while !($doc.xpath(%Q{//*[@id="comment#{comment_id}"]/div[1]/div/div/div/a[1]})[link_count].nil?)
  #   #リンク先タイトル
  #   title = $doc.xpath(%Q{//*[@id="comment#{comment_id}"]/div[1]/div/div/div/a[1]})[link_count].children.text
  #   # p $doc.xpath(%Q{//*[@id="comment#{comment_id}"]/div[1]/div/div/div/a[1]})[link_count].children.text
  #   #リンク先URL
  #   url = $doc.xpath(%Q{//*[@id="comment#{comment_id}"]/div[1]/div/div/div/a[2]})[link_count][:href]
  #   # p $doc.xpath(%Q{//*[@id="comment#{comment_id}"]/div[1]/div/div/div/a[2]})[link_count][:href]
  #
  #   comment_include_url << "[LINK_TITLE: #{title}, URL: #{url}]\n"
  #
  #   link_count += 1
  # end
  # puts "link_count: #{link_count}"

  #リンクソースをリンク情報に置換
  # link_count.times do |i|
  #   comment_body = comment_body.gsub(%r{<divclass="comment-url"><divclass="comment-url-headflc">.*?</p></div></div></div><br>}, comment_include_url[i])
  # end




  #HTMLの改行コードを文字列の改行コードに変換
  comment_body = comment_body.gsub("<br>", "\n")
  puts "comment_body(edited): \n#{comment_body}"

  # puts $doc.xpath(%Q{//*[@id="comment#{comment_id}"]/div[1]/div/div/div/a[1]})[1].nil?
  # unless $doc.xpath(%Q{//*[@id="comment#{comment_id}"]/div[1]/div/div/div/a[1]})[0].nil?
  #   #リンク先タイトル
  #   p $doc.xpath(%Q{//*[@id="comment#{comment_id}"]/div[1]/div/div/div/a[1]})[0].children.text
  #   #リンク先URL
  #   p $doc.xpath(%Q{//*[@id="comment#{comment_id}"]/div[1]/div/div/div/a[2]})[0][:href]
  # end

  # unless comment_body.nil?
  # if comment_body.include?(%Q{<divclass="comment-url">})
  #   puts "com: #{comment_id}, URL: #{$doc.xpath(%Q{//*[@id="comment#{comment_id}"]/div[1]/div/div/div/})}"
  # end
  # end

  commnet_wordstyle = $doc.xpath("//*[@id=\"comment#{comment_id}\"]/div[1]")[0][:class]

  @comment_tmp = {id: comment_id, name: comment_name, date: comment_date, plus: comment_plus, minus: comment_minus, body: comment_body, format: commnet_wordstyle}

  # p "@comment_tmp: #{@comment_tmp}"
  # puts "comment_body: #{comment_body}"

  $topicdata << @comment_tmp

  # puts @comment_tmp
  # puts "------------------------------------------------------------------------"
  # puts "@comment_tmp[:name]: #{@comment_tmp[:name]}"
  # puts "@comment_tmp[:date]: #{@comment_tmp[:date]}"
  # puts "@comment_tmp[:plus]: #{@comment_tmp[:plus]}"
  # puts "@comment_tmp[:minus]: #{@comment_tmp[:minus]}"
  # puts "@comment_tmp[:body]: #{@comment_tmp[:body]}"
  # puts "@comment_tmp[:format]: #{@comment_tmp[:format]}"
  # puts "------------------------------------------------------------------------"
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
