class ActiveDebianRepositoryMigration < ActiveRecord::Migration

  def self.up
    # Create all tables
    create_table :packages, :force => true do |t|
      t.integer "aptsource_id"
      t.string  "name",        :null => false
      t.string  "short_description"
      t.string  "homepage"
      t.text    "long_description"
      t.text    "depends"
      t.string  "version"
    end

    add_index "packages", ["name"], :name => "package_name"

    create_table :changelogs, :force => true do |t|
      t.integer "package_id",  :null => false
      t.string  "version"
      t.text    "description"
    end

    add_index "changelogs", ["package_id"], :name => "package_id"

    create_table :files, :force => true do |t|
      t.integer  "package_id",          :null =>     false
      t.string   "name",                :limit => 200
      t.string   "install_path"
      t.datetime "created_at"
      t.string   "attach_file_name",    :limit => 250
      t.string   "attach_content_type", :limit => 100
      t.integer  "attach_file_size"
      t.datetime "attach_updated_at"
    end

    create_table :scripts, :force => true do |t|
      t.integer  "package_id",          :null =>     false
      t.string   "name",                :null =>     false
      t.datetime "created_at"
      t.string   "attach_file_name",    :limit => 250
      t.string   "attach_content_type", :limit => 100
      t.integer  "attach_file_size"
      t.datetime "attach_updated_at"
    end

    create_table :aptsources, :force => true do |t| 
      t.string "uri",          :limit => 250 
      t.string "distribution", :limit => 50
      t.string "component",    :limit => 50
      t.string "arch",         :limit => 20
    end 

  end

  def self.down
    # delete all tables
    drop_table :packages
    drop_table :files
    drop_table :changelogs
    drop_table :aptsources
    drop_table :scripts
  end
end
