ActiveAdmin.register User do
  index do
    column :id
    column :email
    column :name
    column :created_at do |user|
      user.created_at.to_date.to_s
    end
    default_actions
  end
end
