#!/usr/bin/ruby
# -*- coding: utf-8 -*-
require "rubygems"
require "MeCab"
require "kakasi"
require "iconv"
include Kakasi
$KCODE= "UTF8"  
require "moji"
gem "serialport",">=1.0.4"
require "serialport"
gem("twitter4r")
require "twitter"
require "twitter/console"

def ruby_talk(in_str)
	port = "/dev/ttyACM0"
	sp = SerialPort.new(port, 9600, 8, 1, SerialPort::NONE)
	sleep(0.5) #すぐには接続が確立しないようなので、少し待つ
	sp.write "?\r\n"
	#sleep(1)
	
	#debug
	#str ="オープンソースカンファレンス 2012 Hiroshima http://www.ospn.jp/osc2012-hiroshima/ 10月20日 広島国際学院大学 中野キャンパス"
	str = in_str
	
	#入力文字を一旦すべて全角にする
	str = Moji.han_to_zen(str)
	
	  str_output = ""
	  sv_hinsi = ""
	  sv_hinsi_1 = ""
	  sv_type = ""
	  buf = ""  
	  sw = false
	  str_serial = ""
	
	#形態素解析
	  node = MeCab::Tagger.new.parseToNode(str)
	while node
	        if ((node.surface[0] == nil) || (Moji.type(str) == nil)) then       
	 		node = node.next 
			next
	        end
	#debug
		 puts "#{node.surface}\t#{node.feature}"
	
		 str_csv = node.feature.split(",")
		 yomi = str_csv[8]
		 hinsi = str_csv[0]
		 hinsi_1 = str_csv[1]
		 str = node.surface
		 #品詞が変わったか
		 if ((sv_hinsi != hinsi) || (sv_hinsi_1 != hinsi_1)) then
		 #if (sv_type != Moji.type(str)) then 
		  	sv_hinsi = hinsi
		   	sv_hinsi_1 = hinsi_1
		  # 	sv_type = Moji.type(str)
			if (sw == true) then
		   		str_output = str_output + buf
		   		str_output = str_output + ">/"
		   		buf = ""
		   		sw = false
		   	end
		 end
	
	
		#いくつかの固有名詞の読み
		if (((hinsi_1=="固有名詞") || (hinsi=="名詞" and hinsi_1=="一般")) and Moji.type?(str,Moji::ALPHA)) then
		#ここは外部ファイルで設定できるといいなぁ
			if (Moji.zen_to_han(str).downcase == "intel") then
				yomi = "インテル "
				str = yomi
			end
			if (Moji.zen_to_han(str).downcase == "twitter") then
				yomi = "ツイッター "
				str=yomi
			end
			if (Moji.zen_to_han(str).downcase == "city") then
				yomi = "シティ "
				str=yomi
			end
			if (Moji.zen_to_han(str).downcase == "akira") then
				yomi = "アキラ "
				str=yomi
			end
			if (Moji.zen_to_han(str).downcase == "tweet") then
				yomi = "ついーと "
				str=yomi
			end	
			if (Moji.zen_to_han(str).downcase=="hiroshima") then
				yomi = "ひろしま"
				str=yomi
			end
			if (Moji.zen_to_han(str).downcase=="ruby") then
				yomi = "ルビー"
				str=yomi
			end
			if (Moji.zen_to_han(str).downcase=="rubynews") then
				yomi = "ルビーニュース"
				str=yomi
			end
			if (Moji.zen_to_han(str).downcase=="rails") then
				yomi = "レールズ"
				str=yomi
			end
			if (Moji.zen_to_han(str).downcase=="ios") then
				yomi = "あいおーえす"
				str=yomi
			end
			if (Moji.zen_to_han(str).downcase=="net") then
				yomi = "ネット"
				str=yomi
			end
			if (Moji.zen_to_han(str).downcase=="mac") then
				yomi = "マック"
				str=yomi
			end
			if (Moji.zen_to_han(str).downcase=="linux") then
				yomi = "りなっくす"
				str=yomi
			end
			if (Moji.zen_to_han(str).downcase=="windows") then
				yomi = "ウインドーず"
				str=yomi
			end
			if (Moji.zen_to_han(str).downcase=="com") then
				yomi = "こむ"
				str=yomi
			end

	
		end
		#品詞分類１が数字
		if (hinsi_1 == "数") then
		#if (Moji.type?(str,Moji::NUMBER)) then #ドットの解釈が記号か数字か文脈で判断する為未使用
			if (sw == false) then
				sw = true
				buf = "<NUM VAL=" + Moji.zen_to_han(str)
		  	else
		    		buf = buf + Moji.zen_to_han(str)
		  		if (buf.length>50) then
		  			str_output = str_output + buf
		  			str_output = str_output + ">\n"
		  			buf = ""
		  			sw = false
		  		end
			end
		#アルファベット
		elsif (Moji.type?(str,Moji::ALPHA)) then #一部のアルファベット文字列が固有名詞と判定されるので、品詞情報を参照しない
	  		if (sw == false) then
	    			sw = true
	    			buf = "<ALPHA VAL=" + Moji.zen_to_han(str)
	  		else
	   			buf = buf + Moji.zen_to_han(str)
		  		if (buf.length>50) then
		  			str_output = str_output + buf
		  			str_output = str_output + ">\n"
		  			buf = ""
		  			sw = false
		  		end
			end
		#記号
		elsif (hinsi == "記号" ) then
	    		if (sw == true) then
	   			str_output = str_output + buf
	   			str_output = str_output + ">/"
	   			buf = ""
	   			sw = false
			end
	
			#記号などをちまちま変換
			#読めない記号は無視
			#ここは外部ファイルとかで設定できるといいなぁ。
			str = str.gsub(/＠/,"a'tto ")
			str = str.gsub(/＃/,"sya'-pu ")
			str = str.gsub(/＄/,"do'ru ")
			str = str.gsub(/％/,"pa'-sento ")
			str = str.gsub(/＆/,"ando' ")
			str = str.gsub(/＊/,"a'suta' ")
			str = str.gsub(/＋/,"pura'su ")
			str = str.gsub(/：/,"ko'ronn ")
			str = str.gsub(/／/,"sura'ssyu ")
			str = str.gsub(/．/,"dotto ")
			str = str.gsub(/－/,"haihunn")
			str = str.gsub(/。/,".")
			str = str.gsub(/、/,",")
			str_output = str_output + str
		else
		#漢字やひらがななど
	    		if (sw == true) then
	   			str_output = str_output + buf
	   			str_output = str_output + ">/"
	   			buf = ""
	   			sw = false
	   		end
	   		#変換しそこねたものを変換
	   		if (str == "－" || str == "ー") then
	   			yomi = "ハイフン"
	   		end
			if(str=="＃") then
				yomi = "しゃーぷ"
			end
	   		
	   		#kakasiがeucじゃないと動かないので変換
			yomi  = Iconv.conv("eucJP","UTF-8",yomi)
	  		str_output = str_output + Kakasi.kakasi("-Ha -Ka -Ja -Ea -ka -ja",yomi)
			#^は長音記号にしてみる
			str_output = str_output.gsub(/\^/,"-")
		end
		#長すぎる音声記号は改行
		if (str_output.length>100) then
			str_serial = str_serial + str_output + "\n"
			str_output = ""
		end
		#句点があればそこで改行
		if (str == ".") or (str==",") then
			str_serial = str_serial + str_output + "\n"
			str_output = ""
		end
	#
		node = node.next
	end
	
	#最後の処理
	 if (sw == true) then
		str_output = str_output + buf
	   	str_output = str_output + ">/"
	   	buf = ""
	   	sw = false
	 end
	
	#シリアルポートへ転送
	str_serial  = str_serial + str_output
	puts str_serial
	tmp = str_serial.split(/\n/)
	#puts "a"
	#転送タイミング調整
	sp.write("          \r\n")
	sp.write("\r\n")
	#debug
	puts [sp.getc].pack('c')
	#
	tmp.each do |line|
	#	puts "b"
		#タイミング調整
		sp.write("\r\n")
		#puts [sp.getc].pack('c')
		#debug
		puts "c"
			#コマンド受付まで待つ
			until([sp.getc].pack('c')== ">") do
				#puts [sp.getc].pack('c')
				#何かコマンドを送信しないと応答が帰ってこないので、改行を送信し続ける
				sp.write("\r\n")
				sleep(0.4) 
				#debug
				puts "wait"
			end
				#debug
				puts "OK"
				#タイミング調整
				sleep(1)
				sp.write line + "\r\n\r\n"
				sleep(1)
	end
	#ポートクローズ
	sp.close
end


#twitterから取得
c = Twitter::Client.new
 tmp = c.search(:q => '#ruby-test', :lang => 'ja', :rpp => 5)
tmp.each do |line|
puts line.text.chop
	ruby_talk(line.text.chop)
	sleep (5)
end

