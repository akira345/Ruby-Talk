require "rubygems"
gem "serialport",">=1.0.4"
gem "serialport"
class Serial
#http://blog.goo.ne.jp/dak-ikd/e/56b622830aefd41435bc389c709a3a87を参考に実装

	@@obj = nil
	def initialize(port= "/dev/ttyACM0")
		if !@@obj then
			@@obj = SerialPort.new(port, 9600, 8, 1,  SerialPort::NONE)
			sleep(0.5) #すぐには接続が確立しないようなので、少し待つ
			@@obj.write "?\r\n"	#初期化コマンド
			ObjectSpace.define_finalizer(@@obj,Serial.finalizer)
		end
	end
	def Serial.finalizer()
		proc do
			@@obj.close
		end
	end
	def isbusy?
		@@obj.write("\r\n")
		if ([@@obj.getc].pack('c')==">") then
			return false
		else
			return true
		end
	end
	def out_msg(str_msg)
		#タイミング調整
		@@obj.write "\r\n"
		#Busy解除までまつ
		while is_busy?
			sleep(0.4)
			@@obj.write "\r\n"
		end
		sleep(1)
		@@obj.write msg + "\r\n"
	end
end

