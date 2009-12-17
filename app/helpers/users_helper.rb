module UsersHelper
  def role_options
    list = current_user.roles.dup
    list.delete(User::Role::ADMIN)
    list.delete(User::Role::RESELLER) unless current_account.reseller?
    
    list
  end
  
  def role_descriptions
    @@role_descriptions ||= {
      User::Role::ADMIN => 'Account Administrator',
      User::Role::RESELLER => 'Reseller Management',
      User::Role::BILLING => 'Billing',
      User::Role::USERS => 'User Management',
      User::Role::FLEET => 'Fleet Management'
    }
  end
end
