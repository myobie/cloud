module Cloud::Wait
  def self.included(base)
    base.extend ClassMethods
  end

  def wait(num = 60, sleep_amount = 2, &blk)
    self.class.wait(num, sleep_amount, &blk)
  end

  module ClassMethods
    def wait(num = 60, sleep_amount = 2, &blk)
      Timeout.timeout(num) do
        while !blk.call
          sleep(sleep_amount)
          print "."
          $stdout.flush
        end
      end
      print "\n"
      true
    rescue Timeout::Error
      print "\n"
      false
    end
  end
end