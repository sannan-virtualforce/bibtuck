class RebuildMessages < ActiveRecord::Migration
  def self.up
    drop_table :messages
    drop_table :message_recipients

    create_table "conversations", :force => true do |t|
      t.string   "subject"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "messages", :force => true do |t|
      t.integer  "user_id"
      t.integer  "conversation_id"
      t.text     "body"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "user_conversations", :force => true do |t|
      t.integer  "user_id"
      t.integer  "conversation_id"
      t.boolean  "deleted"
      t.boolean  "read"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end

  def self.down
  end
end
