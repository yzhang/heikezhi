ActiveAdmin.register Article do
  index do
    column :id
    column :title
    column :user do |a|
      a.user.try(:name)
    end

    column :created_at do |a|
      a.created_at.to_date.to_s
    end
    default_actions
  end
end
