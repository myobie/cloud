module Cloud::Rescuer
  def self.included(base)
    base.extend ClassMethods
  end
  
  def rescuer(&blk)
    self.class.rescuer(&blk)
  end

  module ClassMethods

    def rescuer
      result = nil

      if block_given?
        begin

          result = yield

        rescue StandardError => e

          log "} failed, because of #{e}."
          log(e.backtrace.join("\n")) if $global_opts[:trace]
          unless $global_opts[:continue]
            log "exiting..."
            exit(1)
          end

        end
      end

      result
    end

  end
end