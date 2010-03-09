require(File.join(File.dirname(__FILE__), 'test_helper'))

# TODO:
# - make some nice mock objects!
# - Tests still mixed for two classes
class User < ActiveRecord::Base
  can_has_tokens :forgot_password, :change_email
end
class Article < ActiveRecord::Base; end

class TokenizerTest < Test::Unit::TestCase
  include ActiveSupport::Testing::Assertions
  def test_should_respond_to_all_tokenizer_methods
    assert_respond_to User, "find_by_token"
    %w{set_forgot_password_token forgot_password_token forgot_password_token?}.each do |m|
      assert_respond_to User.new, m
    end
  end
  
  def test_should_set_the_token_automatically
    user = User.create(:name=>"joe")
    assert_difference "TokenCode.count" do
      user.set_forgot_password_token
    end
    assert user.forgot_password_token
  end

  def test_should_respond_to_token?
    user = User.create(:name=>"joe")
    assert_equal false, user.forgot_password_token?
    user.set_forgot_password_token
    assert user.forgot_password_token?
    
  end

  def test_unique_name_in_polymorphic_scope
    user = User.create(:name=>"joe")
    user.set_forgot_password_token
    assert_no_difference "TokenCode.count" do
      user.set_forgot_password_token
    end
  end
  
  def test_same_token_should_be_deleted
    user = User.create(:name=>"joe")
    user.set_forgot_password_token
    token1 = user.forgot_password_token
    assert_no_difference "TokenCode.count" do
      user.set_forgot_password_token
      token2 = user.forgot_password_token
      assert user.token('forgot_password').valid? # check unique name validation
      assert_not_equal token1, token2
    end
  end

  def test_token_should_only_valid_for_a_limited_time
    user = User.create(:name=>"joe")
    user.set_forgot_password_token
    assert_in_delta user.token(:forgot_password).valid_until.to_i, 5.days.from_now.to_i, 10
  end
  
  def test_token_to_string
    user = User.create(:name=>"joe")
    user.set_forgot_password_token(:valid=>2.days)
    assert_not_nil user.token(:forgot_password).to_s

  end
  def test_token_valid_until_should_be_editable
    user = User.create(:name=>"joe")
    user.set_forgot_password_token(:valid=>2.days)
    assert_in_delta user.token(:forgot_password).valid_until.to_i, 2.days.from_now.to_i,10
  end
  
  def test_should_use_and_return_unavailable
    user = User.create(:name=>"joe")
    user.set_forgot_password_token
    assert user.get_forgot_password_token.use!
    assert user.get_forgot_password_token.used?
    assert !user.get_forgot_password_token.valid_for_use?
  end

  def test_should_unuse_dates
    user = User.create(:name=>"joe")
    user.set_forgot_password_token
    assert user.get_forgot_password_token.use!
    assert user.get_forgot_password_token.unuse!
    assert user.get_forgot_password_token.valid_for_use?
  end

  def test_should_delete_all_used
    user = User.create(:name=>"joe")
    # set a couple of tokens
    user.set_forgot_password_token
    user.set_change_email_token
    cnt = TokenCode.count
    # use those tokens
    user.get_forgot_password_token.use!
    user.get_change_email_token.use!
    # now kick all used
    TokenCode.delete_used
    #tokens from other tests are still present, so we compare by count
    assert cnt > TokenCode.count
    assert_nil user.get_forgot_password_token
    assert_nil user.get_change_email_token
  end

  def test_should_delete_all_expired
    user = User.create(:name=>"joe")
    # set a couple of dead tokens
    token = user.create_token(:forgot_password, :valid_until=>1.year.ago)
    token1 = user.create_token(:change_email, :valid_until=>2.weeks.ago)
    cnt = TokenCode.count
    # now kick all expired
    TokenCode.delete_expired
    #tokens from other tests are still present, so we compare by count
    assert cnt > TokenCode.count
    assert_nil user.get_forgot_password_token
    assert_nil user.get_change_email_token
  end

  def test_should_find_polymorphic_object
    user = User.create(:name=>"joe")
    token = user.create_token(:forgot_password, :valid_until=>2.days.from_now)
    assert_kind_of User, User.find_by_token(:forgot_password, token.token)
  end

  def test_should_not_find_object_with_invalid_token
    user = User.create(:name=>"joe")
    token = user.create_token(:forgot_password, :valid_until=>1.days.ago)
    assert_nil User.find_by_valid_token(:forgot_password, token.token)
  end

  def test_should_find_object_with_valid_token
    user = User.create(:name=>"joe")
    token = user.create_token(:forgot_password, :valid_until=>2.days.from_now)
    assert_equal user, User.find_by_valid_token(:forgot_password, token.token)
  end
  def test_should_not_leak_token_options
    
  end
end
