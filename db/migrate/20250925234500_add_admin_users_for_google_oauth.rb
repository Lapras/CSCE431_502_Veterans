class AddAdminUsersForGoogleOauth < ActiveRecord::Migration[7.2]
  def up
    # Replace with your Gmail OAuth email
    email = 'jermurray2@tamu.edu'

    # Only create if it doesn't already exist
    user = User.find_or_initialize_by(email: email)
    
    user.save!

    user.add_role :admin unless user.has_role?(:admin)
  end

  def down
    email = 'jermurray2@tamu.edu'
    user = User.find_by(email: email)
    user.destroy if user
  end
end
