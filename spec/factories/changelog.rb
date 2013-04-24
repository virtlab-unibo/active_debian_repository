FactoryGirl.define do
  # remember it depends on source with source_id
  factory :changelog do
    distributions "precise"
    description       "I'am a change description\n    * bla bla"
    date          "Tue, 23 04 2013 17:57:37 +0200"
    urgency       "high"
    version       "20130401-19"
    package 
  end
end

