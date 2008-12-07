require 'test/unit'
require 'rubygems'
require 'active_record'
require 'active_support'

# in active support 2.2.2 assert_difference helper has moved
# Must find a method to detect if method can be found
require 'active_support/testing/core_ext/test/unit/assertions'

require "#{File.dirname(__FILE__)}/../lib/token_code"
require "#{File.dirname(__FILE__)}/../lib/tokenizer"

ActiveRecord::Base.send(:include, KingTokens::Tokenizer)

ActiveRecord::Base.establish_connection({
    'adapter' => 'sqlite3',
    'database' => ':memory:'
  })
load(File.join(File.dirname(__FILE__), 'schema.rb'))
