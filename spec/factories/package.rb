FactoryGirl.define do
  # remember it depends on source with source_id
  factory :package do
    name        'test-name'
    short_description "I'm a short description"
    long_description  "I'm a\n  \ndescription\n\non three lines"
    depends     ""
    version     "1.2.3"
    aptsource
  end
end

