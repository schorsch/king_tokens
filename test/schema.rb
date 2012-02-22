# encoding: utf-8
ActiveRecord::Schema.define(:version => 0) do

  create_table :token_codes do |t|
    t.integer :object_id
    t.string :object_type, :name, :token
    t.datetime :used_at, :valid_until
    t.timestamps
  end

  create_table :users do |t|
    t.string        :name
  end

end
