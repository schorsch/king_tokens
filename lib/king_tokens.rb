require File.dirname(__FILE__) + '/king_tokens/token_code'
require File.dirname(__FILE__) + '/king_tokens/tokenizer'
ActiveRecord::Base.send(:include, KingTokens::Tokenizer)