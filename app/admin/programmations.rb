ActiveAdmin.register Programmation do
  permit_params :imdb_id, :titre, :description, :genre, :duree, :realisateur, :acteurs, :affiche_url, :date, :heure

  index do
    selectable_column
    id_column
    column :titre
    column :date
    column :heure
    column :duree
    column :genre
    column :realisateur
    actions
  end

  form do |f|
    f.inputs do
      f.input :imdb_id, placeholder: "ex: tt31193180"
      f.input :date, as: :date_picker
      f.input :heure, as: :time_picker
    end
    f.actions
  end

  show do
    attributes_table do
      row :titre
      row :description
      row :genre
      row :duree
      row :realisateur
      row :acteurs
      row :date
      row :heure
      row :imdb_id
      row :affiche_url do |prog|
        if prog.affiche_url.present?
          image_tag prog.affiche_url, style: "max-width: 200px"
        end
      end
    end
  end

  controller do
    def create
      super do |format|
        resource.fetch_movie_details if resource.persisted? && resource.imdb_id.present?
      end
    end

    def update
      super do |format|
        resource.fetch_movie_details if resource.imdb_id.present?
      end
    end
  end

  # Ajout du JavaScript pour la recherche de films
  before_action only: [ :new, :edit ] do
    @page_scripts = [ "active_admin/movie_search" ]
  end
end
