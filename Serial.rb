require "rubygems"
gem "serialport",">=1.0.4"
gem "serialport"
class Serial
#http://blog.goo.ne.jp/dak-ikd/e/56b622830aefd41435bc389c709a3a87���Q�l�Ɏ���

	@@obj = nil
	def initialize(port= "/dev/ttyACM0")
		if !@@obj then
			@@obj = SerialPort.new(port, 9600, 8, 1,  SerialPort::NONE)
			sleep(0.5) #�����ɂ͐ڑ����m�����Ȃ��悤�Ȃ̂ŁA�����҂�
			@@obj.write "?\r\n"	#�������R�}���h
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
		#�^�C�~���O����
		@@obj.write "\r\n"
		#Busy�����܂ł܂�
		while is_busy?
			sleep(0.4)
			@@obj.write "\r\n"
		end
		sleep(1)
		@@obj.write msg + "\r\n"
	end
end

