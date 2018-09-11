str = "aaa!hogebbbpiyo!bbb"
re = Regexp.new('(hoge(.*)piyo)').match(str)

str = %Q{出来てますか？<br><divclass="comment-url"><divclass="comment-url-headflc"><imgsrc="http://up.gc-img.net/post_img_web/2018/06/1f57ad3662dd1cc8d5bd7bc235d703aa_263.jpeg"width="80"alt="ガルちゃんで画像（サイト）を貼り付ける方法＆練習Part19"><divclass="comment-url-title"><ahref="http://girlschannel.net/topics/1680466/4/"target="_blank">ガルちゃんで画像（サイト）を貼り付ける方法＆練習Part19</a><ahref="http://girlschannel.net/topics/1680466/4/"target="_blank">girlschannel.net</a><p>ガルちゃんで画像（サイト）を貼り付ける方法＆練習Part19ガルちゃんで画像（サイト）を貼り付ける方法＆練習Part19サイトや画像の貼り方、アンカーや絵の透過保存など色々練習しましょう！</p></div></div></div>
}
re = Regexp.new('(<divclass="comment-url"><divclass="comment-url-headflc"><imgsrc="(.*)"width="80"alt=".*</p></div></div></div>)').match(str)

str = %Q{練習<br><divclass="comment-url"><divclass="comment-url-headflc"><imgsrc="http://up.gc-img.net/post_img_web/2018/06/4b8ae667cffb4b81fbf8deec96c9de2c_394.png"width="80"alt="ガールズちゃんねる-GirlsChannel-"><divclass="comment-url-title"><ahref="http://girlschannel.net/make_comment/1680466/"target="_blank">ガールズちゃんねる-GirlsChannel-</a><ahref="http://girlschannel.net/make_comment/1680466/"target="_blank">girlschannel.net</a><p>女子の女子による女子のためのおしゃべりコミュニティ。女子の好きな話題にみんなでコメント、みんなで投票して盛り上がれる匿名掲示板「ガールズちゃんねる」へようこそ。</p></div></div></div><br><divclass="comment-url"><divclass="comment-url-headflc"><imgsrc="http://up.gc-img.net/post_img_web/2018/06/4b8ae667cffb4b81fbf8deec96c9de2c_394.png"width="80"alt="ガールズちゃんねる-GirlsChannel-"><divclass="comment-url-title"><ahref="http://girlschannel.net/make_comment/1680466/"target="_blank">ガールズちゃんねる-GirlsChannel-</a><ahref="http://girlschannel.net/make_comment/1680466/"target="_blank">girlschannel.net</a><p>女子の女子による女子のためのおしゃべりコミュニティ。女子の好きな話題にみんなでコメント、みんなで投票して盛り上がれる匿名掲示板「ガールズちゃんねる」へようこそ。</p></div></div></div><br>できた？<divclass="comment-img"><imgsrc="http://up.gc-img.net/post_img/2018/06/azF36d2X8CX1c4l_GNg6q_183.jpeg"data-src="http://up.gc-img.net/post_img/2018/06/azF36d2X8CX1c4l_GNg6q_183.jpeg"height="400"alt="ガルちゃんで画像（サイト）を貼り付ける方法＆練習Part19"></div>}

# puts "re: #{re.inspect}"
puts ""
puts "re: #{re[2]}"

puts str.gsub(%r{<divclass="comment-url"><divclass="comment-url-headflc">.*?</p></div></div></div><br>}, "URL")
puts str.gsub(%r{<divclass="comment-url"><divclass="comment-url-headflc">.*?</div></div></div>}, "URL")
