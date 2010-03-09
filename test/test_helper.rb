require 'test/unit'
require 'rubygems'
require 'active_record'
require 'active_support'

# in active support 2.2.2 assert_difference helper has moved
# Must find a method to detect if method can be found
require 'active_support/test_case'
#require 'active_support/testing/assertions'
#require ActiveSupport::TestCase
require "#{File.dirname(__FILE__)}/../lib/king_tokens"

ActiveRecord::Base.establish_connection({
    'adapter' => 'sqlite3',
    'database' => ':memory:'
  })
load(File.join(File.dirname(__FILE__), 'schema.rb'))
