# KingTokens

Tokens are a usefull way to give users access to an application. This can be for a limited time or just once.
Just think of password resets, changing email, protected rss feed urls, timed out private links, .. KingTokens are your easy way out in such cases

This plugin consists of two parts:

* an ActiveRecord model class TokenCode, which maps to the token table in the db
* a module Tokenizer mixed into ActiveRecord::Base, providing your models with the possibility to define tokens

KingTokens map polymorphic to other objects, through the can_has_tokens :a_tokens_name call

## Install

Get it as gem (hosted on gemcutter.org)
  gem install king_tokens

Or download it from github and use it as rails plugin

setup your token db like defined in the test schema => test/schema.rb

## Example

Define a token on a model
```ruby
  class User
    can_has_tokens :forgot_password
  end
```

Set and get a user by token in a controller

```ruby
  class UsersController
    # form with email so user can send himself a password reset link
    def lost_password
      if request.post?
          #create users forgot_password_token
          @user.set_forgot_password_token
          .....
      end
    end

    # Lookup user by lost_pass_code, send him to his password_edit page
    # params[:code] contains the forgot_passwd token
    def change_password
      # identify by forgot_password_token in params[:code]
      user = User.find_by_valid_token(:forgot_password,  params[:code])
      #expire token
      user.get_forgot_password_token.use!
      ...
    end
  end
```
## Docs

To get a full understanding of the usage also read the tests. For QM you might check the coverage report in coverage/index.html

### Token definition inside an ActiveRecord object:

```ruby
  class User
  
    # Adds token named forgot_pasword to an object.
    can_has_tokens :forgot_password
    
    # Token named change email valid for 3 days
    can_has_tokens :change_email, {:days_valid => 3}
  end
```

### Instance methods added to the ActiveRecord object:

```ruby
  user = User.new
  # Set a new token and removing any existing one
  user.set_forgot_password_token

  #Get the token string
  user.forgot_password_token

  # Check if the user has such a token, returns boolean true
  user.forgot_password_token?

  # Get the token object
  user.get_forgot_password_token

  # Get the token object by name
  user.token(:forgot_password)

  # Low level function to create a token with special options, 
  # overriding the ones set in the class definition
  user.create_token(:token_name, :valid => 2.days.from_now)
```

### Class methods

```ruby
  # Find user by specific token which must be valid
  User.find_by_valid_token(:token_name, 'a token string')
 
  # Find user by specific token, without validation check
  User.find_by_token(:forgot_password, 'a token string')

  User.find_token
```

Copyright (c) 2008-2013 Michael Bumann, Georg Leciejewski released under the MIT license
