ActiveAdmin.register Movie do
  menu priority: 3

  permit_params :title, :description, :duration, :genre, :director, :cast, :poster_url, :imdb_id

  index do
    selectable_column
    id_column
    column :title
    column :genre
    column :duration
    column :director do |movie|
      movie.director["name"] if movie.director.present?
    end
    column :created_at
    actions
  end

  filter :title
  filter :genre
  filter :duration
  filter :created_at

  show do
    attributes_table do
      row :id
      row :title
      row :description
      row :duration
      row :genre
      row :director do |movie|
        pre { movie.director.to_json }
      end
      row :cast do |movie|
        pre { movie.cast.to_json }
      end
      row :poster_url do |movie|
        image_tag(movie.poster_url) if movie.poster_url.present?
      end
      row :created_at
      row :updated_at
    end

    panel "Séances" do
      table_for movie.programmations do
        column :time
        column :max_tickets
        column :tickets_remaining
        column :normal_price
        column :member_price
        column :reduced_price
      end
    end
  end
end
