module Itamae
  class HandlerProxy
    def initialize
      @instances = []
    end

    def register_instance(instance)
      @instances << instance
    end

    def event(*args, &block)
      if block_given?
        _event_with_block(*args, &block)
      else
        _event(*args)
      end
    end

    private

    def _event(*args)
      @instances.each do |i|
        i.event(*args)
      end
    end

    def _event_with_block(event_name, *args, &block)
      event("#{event_name}_started".to_sym, *args)
      block.call
    rescue
      event("#{event_name}_failed".to_sym, *args)
      raise
    else
      event("#{event_name}_completed".to_sym, *args)
    end
  end
end

