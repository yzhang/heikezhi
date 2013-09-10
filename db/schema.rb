# encoding: UTF-8

ActiveRecord::Schema.define do

  create_table(:users) do |t|
    ## Database authenticatable
    t.string :email,              :null => false, :default => ""
    t.string :name,               :null => false, :default => ""
    t.string :encrypted_password, :null => false, :default => ""

    ## Recoverable
    t.string   :reset_password_token
    t.datetime :reset_password_sent_at

    ## Rememberable
    t.datetime :remember_created_at

    ## Confirmable
    t.string   :confirmation_token
    t.datetime :confirmed_at
    t.datetime :confirmation_sent_at

    ## Trackable
    t.integer  :sign_in_count, :default => 0
    t.datetime :current_sign_in_at
    t.datetime :last_sign_in_at
    t.string   :current_sign_in_ip
    t.string   :last_sign_in_ip

    t.timestamps
  end

  add_index :users, :email,                :unique => true
  add_index :users, :reset_password_token, :unique => true

  create_table(:admin_users) do |t|
    ## Database authenticatable
    t.string :email,              :null => false, :default => ""
    t.string :encrypted_password, :null => false, :default => ""

    ## Recoverable
    t.string   :reset_password_token
    t.datetime :reset_password_sent_at

    ## Rememberable
    t.datetime :remember_created_at

    ## Trackable
    t.integer  :sign_in_count, :default => 0
    t.datetime :current_sign_in_at
    t.datetime :last_sign_in_at
    t.string   :current_sign_in_ip
    t.string   :last_sign_in_ip

    t.timestamps
  end

  add_index :admin_users, :email,                :unique => true
  add_index :admin_users, :reset_password_token, :unique => true

  create_table :active_admin_comments do |t|
    t.string :resource_id, :null => false
    t.string :resource_type, :null => false
    t.string :namespace
    t.references :author, :polymorphic => true
    t.text :body
    t.timestamps
  end
  add_index :active_admin_comments, [:resource_type, :resource_id]
  add_index :active_admin_comments, [:namespace]
  add_index :active_admin_comments, [:author_type, :author_id]
  
  create_table :profiles do |t|
    t.integer  :user_id

    t.string   :bio

    t.string   :twitter
    t.string   :github
    t.string   :google_plus

    t.timestamps
  end
  
  add_index :profiles, :user_id, :unique => true
  
  create_table :articles do |t|
    t.integer  :user_id
    t.string   :title
    t.string   :permalink
    t.text     :content

    t.boolean  :recommended, :default => false
    t.string   :state,       :default => 'pending'

    t.datetime :published_at
    t.datetime :recommended_at

    t.integer  :reads, :default => 0

    t.timestamps
  end
  
  add_index :articles, :user_id
  add_index :articles, :permalink
  add_index :articles, [:published_at, :recommended_at]

  create_table :images do |t|
    t.integer  :user_id

    t.string  :image_file
    t.integer :image_width
    t.integer :image_height

    t.timestamps
  end
  add_index :images, :user_id
end
