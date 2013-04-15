FactoryGirl.define do
  # remember it depends on source with source_id
  factory :package do
    name        'test-name'
    description "Breve descrizione"
    body        "Una lunga description\n  \nsu tre righe\n\nho detto tre"
    depends     ""
    version     "1.2.3"
    source
  end
end

