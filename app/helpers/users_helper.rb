module UsersHelper
  def role_options
    current_user.assignable_roles
  end
  
  def role_descriptions
    @@role_descriptions ||= {
      User::Role::ADMIN => 'Account Administrator',
      User::Role::RESELLER => 'Reseller Management',
      User::Role::BILLING => 'Billing Management',
      User::Role::USERS => 'User Management',
      User::Role::FLEET => 'Fleet Management',
      User::Role::LANDMARK => 'Landmark Management',
      User::Role::GEOFENCE => 'Geofence Management'
    }
  end

  def can_drag_user(user)
    can_edit(user) ? '' : 'undraggable'
  end

  def can_edit(user)
    user.id != current_user.id
  end
  
end
