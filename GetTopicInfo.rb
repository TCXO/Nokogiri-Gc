require 'nokogiri'
require 'open-uri'
require 'time'

# トピック情報の取得
def GetTopicInfo(topicid: )
  #トピック情報を取得
  url = 'https://girlschannel.net/topics/' + topicid.to_s
  charset = nil
  html = open(url) do |f|
      charset = f.charset
      f.read
  end

  #トピック情報格納
  $doc = Nokogiri::HTML.parse(html, nil, charset)

  #トピックの全コメント数取得
  # @total_comments = 3
  @total_comments = $doc.xpath("/html/body/div[1]/div[1]/div/div[1]/p/span[2]").children.to_s.match(/\d*/).to_s.to_i
  #トピックのページ数取得
  @total_pages = (@total_comments/500.to_f).ceil
  #トピック名
  # @topic_name = $doc.xpath("/html/body/div[1]/div[1]/div/div[1]/h1").children.to_s.sub(/[\s\S]*<!-- logly_title_begin -->*[\s\S]/, "").sub(/[\s\S]<!-- logly_title_end -->/, "")
  @topic_name = $doc.title.gsub(" | ガールズちゃんねる - Girls Channel -", "")
  #トピック作成日時
  @topic_create = Time.parse($doc.xpath("/html/body/div[1]/div[1]/div/div[1]/p/span[3]").to_s.delete("^0-9"))
  # $doc.xpath("/html/body/div[1]/div[1]/div/div[1]/p/span[3]").children.to_s
  #トピック関連キーワード
  @topic_keywords = Array.new()
  $doc.xpath("/html/body/div[1]/div[1]/div/div[6]/div/ul").children.size.times do |i|
    @topic_keywords << $doc.xpath("/html/body/div[1]/div[1]/div/div[6]/div/ul/a[#{i+1}]/li/text()").to_s
    break if i == ($doc.xpath("/html/body/div[1]/div[1]/div/div[6]/div/ul").children.size / 2) - 1
  end

  @topic_img_url = $doc.xpath("/html/body/div[1]/div[1]/div/div[1]/img").attribute('src').value
  $page_info = {
    topicid: topicid,
    total_comments: @total_comments,
    total_pages: @total_pages,
    topic_name: @topic_name,
    topic_create: @topic_create,
    topic_keywords: @topic_keywords,
    topic_img_url: @topic_img_url
  }

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

  #コメント情報格納, 投稿日時はTimeで扱う
  comment_name = $doc.xpath("//*[@id=\"comment#{comment_id}\"]").css("p").children[0].to_s.gsub!(/[[:space:]]$/, "").gsub!(/^.*[[:space:]]/, "")
  comment_date = Time.parse($doc.xpath("//*[@id=\"comment#{comment_id}\"]").css("p").children[1].children.to_s.delete("^0-9"))
  comment_plus = $doc.xpath(%Q{//*[@id="vbox#{comment_id}"]/div[1]/p}).children[0].to_s.sub("+", "").to_i
  comment_minus = $doc.xpath(%Q{//*[@id="vbox#{comment_id}"]/div[3]/p}).children[0].to_s.sub("-", "").to_i
  comment_html_source = $doc.xpath("//*[@id=\"comment#{comment_id}\"]/div[1]").to_html

  #トピ主コメントのみHTMLコメント有り
  if comment_id == 1
    comment_body = $doc.xpath("//*[@id=\"comment#{comment_id}\"]/div[1]").children.to_s.sub(/[\s\S]*<!-- logly_body_begin -->/, "").gsub(/<!-- logly_body_end -->[\s\S]*/, "")

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
        link_html_source = $doc.xpath(%Q{//*[@id="comment1"]/div[1]/div[#{link_count+1}]}).to_html
        comment_body = comment_body.sub(link_html_source.to_s, comment_include_url)

        #空白文字列が入ったときの処理
        comment_body.gsub!("			", "")

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
          img_html_source = $doc.xpath(%Q{//*[@id="comment1"]/div[1]/div[#{link_count+1}]}).to_html
          puts "comment_include_img: #{comment_include_img}"
          comment_body = comment_body.sub(img_html_source, comment_include_img)

          #文字列の後尾に未改行で画像がついた場合の改行処理
          comment_body.lines do |line|
            comment_body.sub!(comment_include_img, "\n"+comment_include_img) if line.match(%r{.+\[IMG:})
          end
        end
      else
        puts "uhh."
      end
    end

  else
    comment_body = $doc.xpath("//*[@id=\"comment#{comment_id}\"]/div[1]").children.to_s.gsub(/\s/, "")

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
            comment_body.sub!(comment_include_img, "\n"+comment_include_img) if line.match(%r{.+\[IMG:})
          end
        end
      else
        puts "uhh."
      end
    end
  end
  #HTMLの改行コードを文字列の改行コードに変換
  comment_body = comment_body.gsub("<br>", "\n")


  #アンカーの置換処理
  $doc.xpath("//*[@id=\"comment#{comment_id}\"]/div[1]/span").each_with_index do |item, idx|
    #アンカー先の値とHTMLを取得
    html = $doc.xpath("//*[@id=\"comment#{comment_id}\"]/div[1]/span[#{idx+1}]")[0].to_html
    anchor = $doc.xpath("//*[@id=\"comment#{comment_id}\"]/div[1]/span[#{idx+1}]")[0].children.text

    #コメント内のHTMLと置換
    comment_include_anchor = "[ANCKER: #{anchor}]"
    comment_body = comment_body.sub(%r{<spanclass="res-anchor">.*?</span>}, comment_include_anchor)
  end



  puts "##{comment_id}: comment_name: #{comment_name}, comment_date: #{comment_date}, comment_plus: #{comment_plus}, comment_minus: #{comment_minus}"
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

def GetTopicAllData(topicid: )
  GetTopicInfo(topicid: topicid) #page: 3, life: ok
  puts "@total_pages: #{@total_pages}"
  1.upto @total_pages do |i|
    # puts "i: #{i}"
    GetTopicPage(topicid: topicid, topic_page: i)
    1.upto 500 do |j|
      comment_id = j+((i-1)*500)

      # puts "i-j: #{i}-#{j}, #{j+((i-1)*500)}"
      GetComment(comment_id: comment_id) if comment_id <= @total_comments
    end
  end
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
