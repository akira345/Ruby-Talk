require "rubygems"
gem "serialport",">=1.0.4"
require "serialport"

class Serial

  def self.open(port="/dev/ttyACM0", &block)
    port = new SerialPort.new(port, 9600, 8, 1,  SerialPort::NONE)
    if block_given?
      block.call port
      port.close
    end
    port
  end

  attr_reader :io

  def initialize(io)
    @io = io
    # すぐには接続が確立しないようなので、少し待つ
    sleep(0.5)
    init
  end

  # 初期化コマンド
  def init
    io.write "?\r\n"
  end

  def busy?
    io.write("\r\n")
    if ([io.getc].pack('c')==">")
      false
    else
      true
    end
  end

  def write(message)
    # タイミング調整
	io.write "\r\n"
    # Busy解除までまつ
	while busy?
       sleep(0.4)
       io.write "\r\n"
    end
    sleep(1)
    io.write msg + "\r\n"
  end

  def close
    io.close
  end

end
