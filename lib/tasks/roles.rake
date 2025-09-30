# frozen_string_literal: true

namespace :roles do
  desc "Assign the 'member' role to a user by email. Usage: rake roles:add_member[email@example.com]"
  task :add_member, [:email] => :environment do |_t, args|
    email = args[:email]
    if email.blank?
      puts "Usage: rake roles:add_member[email@example.com]"
      exit 1
    end

    user = User.find_by(email: email)
    unless user
      puts "User with email #{email} not found"
      exit 1
    end

    role = Role.find_or_create_by!(name: 'member')
    user.add_role(:member)
    puts "Added 'member' role to #{user.email}"
  end
end
