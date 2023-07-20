# Create a main sample user.

User.create!(
  name: "Max Stark",
  email: "i@maxstrk.ru",
  password: "123qwe",
  password_confirmation: "123qwe",
  admin: true,
  activated: true,
  activated_at: Time.zone.now
)

# Generate a bunch of additional user.
99.times do |n|
  name = Faker::Name.name
  email = "example-#{n+1}@railstutorial.org"
  password = "password"
  User.create!(
    name: name,
    email: email,
    password: password,
    password_confirmation: password,
    activated: true,
    activated_at: Time.zone.now
  )
end

# Generate microposts for a subset of users.
users = User.order(:created_at).take(6)
50.times do
  content = Faker::Lorem.sentence(word_count: 5)
  users.each { |user| user.microposts.create!(content: content) }
end