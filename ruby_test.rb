require "date"   #DateTimeクラスを使えるようにする
nowTime = DateTime.now  #.DateTime.now(現在の時刻)を変数nowTimeに代入する
puts nowTime  #変数nowTimeを表示させる。(=変数nowTimeの中に格納されている今の時刻を表示する)
puts nowTime.inspect

require "time"
time = "20180320224618"
p Time.parse(time).inspect  #変数nowTimeを表示させる。(=変数nowTimeの中に格納されている今の時刻を表示する) 
