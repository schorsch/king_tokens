require "digest/sha1"

# Class to handle polymorphic tokens
class TokenCode < ActiveRecord::Base

  # kick this stament if you dont uses uuids .. or better we make a check??

  usesguid if defined?(usesguid)

  belongs_to :object, :polymorphic => true
  before_create :set_token
  
  validates_presence_of :name
  validates_format_of :name, :with => /^[a-zA-Z0-9\_\-]+$/
  validates_uniqueness_of :name, :scope => [:object_id, :object_type] #second not really needed if uuid
  
  def to_s
    self.token
  end

  # Use a token for an object.
  # Sets the used_at field
  def use!
    update_attribute(:used_at,Time.now)
  end

  # Revoke the usage of a token by emptying its used_at field
  def unuse!
    update_attribute(:used_at,nil)
  end

  def used?
    !! read_attribute(:used_at)
  end

  # Check if the token has expired
  def expired?
    valid_until && valid_until < Time.now
  end

  # A token is valid to be used if:
  # - its has not been used
  # - its not expired
  # - its valid in terms of AR validation
  def valid_for_use?
    valid? && !used? && !expired?
  end
  
  
  def self.delete_used
    delete_all "used_at IS NOT NULL"
  end
  
  def self.delete_expired
    delete_all ["valid_until IS NOT NULL AND valid_until < ? ", Time.now] 
  end
  
  private

  # Generate a token with a default length of 12.
  # Takes a block to validate the token, which should return true/false
  # ==== Parameter
  # size<Integer>:: The length of the token. Defaults to 40
  # validity<Proc>:: A block to check the validity of the token, see #set_token for usage
  def generate_token(size = 40, &validity)
    begin
      token = secure_digest(Time.now, "#{self.object_type}#{self.object_id}", (1..10).map{ rand.to_s }).first(size)
    end while !validity.call(token) if block_given?
    token
  end
  
  def secure_digest(*args)
     Digest::SHA1.hexdigest(args.flatten.join('--'))
   end

  def set_token
    self.token = generate_token { |token| TokenCode.find_by_token(token).nil? }
  end
  
end