require 'token_code'
require 'tokenizer'
ActiveRecord::Base.send(:include, KingTokens::Tokenizer)