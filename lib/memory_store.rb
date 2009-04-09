begin 
      class MemoryStore < ActionController::Session::AbstractStore
        def initialize(app, options = {})
          # Support old :expires option
          options[:expire_after] ||= options[:expires]
          
          super        
          
          @pool = Hash.new
          @mutex = Mutex.new
          
          super
        end
        
        private
        def get_session(env, sid)
          sid ||= generate_sid  
            session = @pool[sid] || {}
           
           [sid, session]
        end
        
        def set_session(env, sid, session_data)
          
          options = env['rack.session.options']
          expiry  = options[:expire_after] || 0
          @pool[sid]=session_data
          return true         
        end
      end
 
rescue LoadError
  # MemCache wasn't available so neither can the store be
end
