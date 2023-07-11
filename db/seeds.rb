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