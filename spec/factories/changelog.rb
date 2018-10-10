FactoryBot.define do
  factory :changelog do
    distributions { "precise" }
    description   { "I'am a change description\n    * bla bla" }
    date          { "Wed, 10 Oct 2018 17:57:37 +0200" }
    urgency       { "high" }
    version       { "2018101001-19" }
    package 
  end
end

