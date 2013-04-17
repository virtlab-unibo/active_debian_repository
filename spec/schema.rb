ActiveRecord::Schema.define do

  create_table "aptsources", :force => true do |t|
    t.string  "uri",          :limit => 250
    t.string  "distribution", :limit => 50
    t.string  "component",    :limit => 50
    t.string  "arch",         :limit => 20
  end

  create_table "packages", :force => true do |t|
    t.integer "aptsource_id"
    t.integer "course_id"
    t.string  "name",        :null => false
    t.string  "short_description"
    t.string  "homepage"
    t.text    "long_description"
    t.text    "depends"
    t.string  "version"
    t.string  "filename"
  end

  create_table "documents", :force => true do |t|
    t.integer  "package_id",                         :null => false
    t.string   "name",                :limit => 200
    t.text     "description"
    t.datetime "created_at"
    t.string   "attach_file_name",    :limit => 250
    t.string   "attach_content_type", :limit => 100
    t.integer  "attach_file_size"
    t.datetime "attach_updated_at"
  end
end
