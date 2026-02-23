# frozen_string_literal: true

SEED_PASSWORD = "password123"

puts "Seeding leagues..."
leagues_data = [
  { name: "Denver 3.5–4.0", city: "Denver", region: "Denver Metro", rating_min: 3.5, rating_max: 4.0, prize_description: "Monthly t-shirt for top finisher; participation shirt for all", monthly_price_cents: 1999 },
  { name: "Denver 4.0–4.5", city: "Denver", region: "Denver Metro", rating_min: 4.0, rating_max: 4.5, prize_description: "Monthly t-shirt for top finisher; participation shirt for all", monthly_price_cents: 1999 },
  { name: "Denver 4.5", city: "Denver", region: "Denver Metro", rating_min: 4.5, rating_max: 4.5, prize_description: "Monthly t-shirt for top finisher; participation shirt for all", monthly_price_cents: 1999 },
  { name: "Denver 3.0–3.5", city: "Denver", region: "Denver Metro", rating_min: 3.0, rating_max: 3.5, prize_description: "Participation shirt for all", monthly_price_cents: 1499 },
]
leagues_data.each do |attrs|
  League.find_or_create_by!(name: attrs[:name]) { |l| l.assign_attributes(attrs) }
end
league_30_35 = League.find_by!(name: "Denver 3.0–3.5")
league_35_40 = League.find_by!(name: "Denver 3.5–4.0")
league_40_45 = League.find_by!(name: "Denver 4.0–4.5")
league_45 = League.find_by!(name: "Denver 4.5")
leagues = [league_30_35, league_35_40, league_40_45, league_45]

puts "Seeding users..."
users_data = [
  { email: "alice@example.com", name: "Alice Chen", zone: "North Denver", can_host: true },
  { email: "bob@example.com", name: "Bob Martinez", zone: "South Denver", can_host: false },
  { email: "carol@example.com", name: "Carol Kim", zone: "East Denver", can_host: true },
  { email: "dave@example.com", name: "Dave Wilson", zone: "West Denver", can_host: true },
  { email: "eve@example.com", name: "Eve Park", zone: "North Denver", can_host: false },
  { email: "frank@example.com", name: "Frank Nguyen", zone: "South Denver", can_host: true },
  { email: "grace@example.com", name: "Grace Lee", zone: "East Denver", can_host: false },
  { email: "henry@example.com", name: "Henry Torres", zone: "West Denver", can_host: true },
  { email: "ivy@example.com", name: "Ivy Johnson", zone: "North Denver", can_host: true },
  { email: "jack@example.com", name: "Jack Davis", zone: "South Denver", can_host: false },
]
users = users_data.map do |attrs|
  User.find_or_create_by!(email: attrs[:email]) do |u|
    u.assign_attributes(attrs)
    u.password = SEED_PASSWORD
    u.password_confirmation = SEED_PASSWORD
  end
  User.find_by!(email: attrs[:email])
end

# League 3.0–3.5, 3.5–4.0, 4.0–4.5, 4.5
league_30_35, league_35_40, league_40_45, league_45 = leagues

puts "Seeding league memberships and payment subscriptions..."
# Alice 3.8 -> 3.5-4.0; Bob 4.2 -> 4.0-4.5; Carol 4.5 -> 4.5; Dave 3.2 -> 3.0-3.5; Eve 4.1 -> 4.0-4.5; Frank 3.7 -> 3.5-4.0; Grace 4.5 -> 4.5; Henry 3.4 -> 3.0-3.5; Ivy 4.3 -> 4.0-4.5; Jack 4.5 -> 4.5
memberships_config = [
  [users[0], league_35_40, 3.8],
  [users[1], league_40_45, 4.2],
  [users[2], league_45, 4.5],
  [users[3], league_30_35, 3.2],
  [users[4], league_40_45, 4.1],
  [users[5], league_35_40, 3.7],
  [users[6], league_45, 4.5],
  [users[7], league_30_35, 3.4],
  [users[8], league_40_45, 4.3],
  [users[9], league_45, 4.5],
]
memberships_config.each do |user, league, dupr|
  LeagueMembership.find_or_create_by!(user: user, league: league) do |m|
    m.dupr_rating = dupr
    m.status = "active"
  end
  PaymentSubscription.find_or_create_by!(user: user, league: league) do |ps|
    ps.status = "active"
    ps.stripe_subscription_id = "sub_seed_#{user.id}_#{league.id}" if ps.stripe_subscription_id.blank?
  end
end

# Bob also in 3.5–4.0; Ivy also in 4.5
extra_members = [
  [users[1], league_35_40, 4.0],
  [users[8], league_45, 4.5],
]
extra_members.each do |user, league, dupr|
  next unless dupr >= league.rating_min && dupr <= league.rating_max
  LeagueMembership.find_or_create_by!(user: user, league: league) do |m|
    m.dupr_rating = dupr
    m.status = "active"
  end
  PaymentSubscription.find_or_create_by!(user: user, league: league) do |ps|
    ps.status = "active"
  end
end

puts "Seeding availabilities..."
availabilities_config = [
  [users[0], "Tuesday", "17:30", "22:00"],
  [users[0], "Thursday", "17:30", "22:00"],
  [users[1], "Saturday", "09:00", "14:00"],
  [users[2], "Wednesday", "18:00", "21:00"],
  [users[2], "Sunday", "10:00", "14:00"],
  [users[3], "Monday", "17:00", "20:00"],
  [users[4], "Tuesday", "17:30", "22:00"],
  [users[5], "Friday", "18:00", "22:00"],
  [users[6], "Saturday", "08:00", "12:00"],
  [users[7], "Thursday", "17:30", "21:00"],
  [users[8], "Tuesday", "17:00", "21:00"],
  [users[9], "Sunday", "09:00", "13:00"],
]
availabilities_config.each do |user, day, start_t, end_t|
  next if user.availabilities.exists?(day_of_week: day, start_time: start_t)
  user.availabilities.create!(day_of_week: day, start_time: start_t, end_time: end_t, timezone: "America/Denver")
end

puts "Seeding matches (4.0–4.5 pool)..."
league = league_40_45
pool_members = league.league_memberships.includes(:user).map(&:user)
# Bob, Eve, Ivy in 4.0-4.5
if pool_members.size >= 2
  u1, u2 = pool_members[0], pool_members[1]
  u3 = pool_members[2] || u1
  Match.find_or_create_by!(league: league, challenger: u1, opponent: u2) { |m| m.status = "pending" }
  Match.find_or_create_by!(league: league, challenger: u2, opponent: u3) { |m| m.status = "accepted" }
  m3 = Match.find_or_create_by!(league: league, challenger: u1, opponent: u3) do |m|
    m.status = "completed"
    m.winner_id = u1.id
    m.score = "11-9, 11-7"
  end
  m3.update!(status: "completed", winner_id: u1.id, score: "11-9, 11-7")
end

puts "Done. You can log in with any seeded user using password: #{SEED_PASSWORD}"
puts "Example: alice@example.com / #{SEED_PASSWORD}"
