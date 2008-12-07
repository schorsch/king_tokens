module KingTokens
  # Module which adds the token methods to the including class
  module Tokenizer
    
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    module ClassMethods

     # Define what kind of tokens the class should have
     # ==== Parameter
     # *tokens
     def can_has_tokens(*tokens)
      options = tokens.extract_options!
      options[:tokens] = tokens
      options[:days_valid] ||= 5
      options[:object_type] = ActiveRecord::Base.send(:class_name_of_active_record_descendant, self).to_s
      
      class_inheritable_accessor :can_has_tokens_options
      self.can_has_tokens_options = options
      
      has_many :token_codes, :as => :object, :dependent => :destroy

      extend KingTokens::Tokenizer::SingletonMethods
    	include KingTokens::Tokenizer::InstanceMethods
      # define getter/setter methods for each defined token
      tokens.each do |name|
        define_method("#{name}_token") do
          token = self.token(name)
          return token.token if token
        end
        define_method("get_#{name}_token") do
          self.token(name)
        end
        define_method("set_#{name}_token") do |*args|
          options = args.first || {}
          create_token(name,options)
        end
        define_method("#{name}_token?") do
          return !self.token(name).nil?
        end
      end
     end
     
    end
   
    module SingletonMethods

      # Find a token.
      #
      # ==== Parameter
      # args<Hash{Symbol=>}>:: arguments passed to the conditions of the TokenCode.find method
      # ==== Options (args)
      # :object_type<String>:: the name of the object tpye, normally the class name of the related object
      # 
      #
      # ==== Returns
      # Object:: the object to which the token belongs
      def find_token(args={})
        args.merge!({:object_type => can_has_tokens_options[:object_type]})
        TokenCode.find(:first, :conditions => args)
      end

      # Find an object by its token.
      #
      # ==== Parameter
      # name<String>:: the name of the token
      # token<String>:: the token
      #
      # ==== Returns
      # Object:: the object to which the token belongs
      def find_by_token(name,token)
        token = find_token(:name => "#{name}", :token => token)
        token.object if token
      end

      # Find an object by a valid token.
      #
      # ==== Parameter
      # name<String>:: the name of the token
      # token<String>:: the token
      #
      # ==== Returns
      # Object:: the object to which the token belongs
      def find_by_valid_token(name, token)
        token = find_token(:name => "#{name}", :token => token)
        return token.object if token && token.valid_for_use?
      end
    end
   
    module InstanceMethods
      # Create a token
      # ==== Parameter
      # name<String>:: the name of the token .. required
      # args<Hash{:Symbol=>String}>:: arguments for the create call of this token.
      # ==== Options (args)
      #   :valid_until =>
      #   :valid =>
      #   :days_valid =>
      def create_token(name, args={})
        # find an existing token and delete it
        unless self.token(name).nil?
          self.token(name).destroy
        end
        args[:name] = "#{name}"
        args[:valid_until] ||= (args.delete(:valid) || self.can_has_tokens_options[:days_valid].days).from_now
        self.token_codes.create(args)
      end

      # Return a token found by its name
      # ==== Parameter
      # name<String/Symbol>:: The name of the token
      def token(name)
        self.token_codes.find_by_name("#{name}")
      end
      
    end
    
  end #module
end # namespace