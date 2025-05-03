ActiveAdmin.register Programmation do
  menu priority: 1

  permit_params :imdb_id, :time, :max_tickets, :normal_price, :member_price, :reduced_price,
                programmation_staff_attributes: [ :id, :user_id, :role, :_destroy ]

  index do
    selectable_column
    id_column
    column :movie
    column :time
    column :max_tickets
    column :tickets_remaining
    column :normal_price
    column :member_price
    column :reduced_price
    column :created_at
    actions
  end

  filter :movie
  filter :time
  filter :max_tickets
  filter :normal_price
  filter :member_price
  filter :reduced_price
  filter :created_at

  form do |f|
    f.inputs "Informations du film" do
      f.input :imdb_id, label: "ID IMDB (ex: tt0111161)", hint: "Entrez l'ID IMDB du film (commençant par 'tt') pour récupérer automatiquement les informations"
    end

    f.inputs "Informations de la séance" do
      f.input :time
      f.input :max_tickets
      f.input :normal_price
      f.input :member_price
      f.input :reduced_price
    end

    f.inputs "Personnel" do
      f.has_many :programmation_staffs, allow_destroy: true, heading: false do |staff|
        staff.input :user, label: "Membre"
        staff.input :role, as: :select, collection: ProgrammationStaff.roles.keys
      end
    end

    f.actions
  end

  show do
    attributes_table do
      row :id
      row :movie
      row :time
      row :max_tickets
      row :tickets_remaining
      row :normal_price
      row :member_price
      row :reduced_price
      row :created_at
      row :updated_at
    end

    panel "Personnel" do
      table_for programmation.programmation_staffs do
        column :user
        column :role
        column :actions do |staff|
          link_to "Supprimer", admin_programmation_staff_path(staff), method: :delete, data: { confirm: "Êtes-vous sûr ?" }
        end
      end
    end

    panel "Tickets vendus" do
      table_for programmation.tickets do
        column :id
        column :user
        column :quantity
        column :ticket_type
        column :status
        column :created_at
      end
    end
  end

  controller do
    def create
      @programmation = Programmation.new(permitted_params[:programmation])
      if @programmation.save
        @programmation.fetch_movie_details if @programmation.imdb_id.present?
        redirect_to admin_programmation_path(@programmation), notice: "Programmation créée avec succès"
      else
        render :new
      end
    end

    def update
      if resource.update(permitted_params[:programmation])
        resource.fetch_movie_details if resource.imdb_id.present? && resource.saved_change_to_imdb_id?
        redirect_to admin_programmation_path(resource), notice: "Programmation mise à jour avec succès"
      else
        render :edit
      end
    end
  end

  # Ajout du JavaScript pour la recherche de films
  action_item :search_movie, only: [ :new, :edit ] do
    link_to "Rechercher un film", "#", id: "search-movie-link"
  end

  sidebar "Recherche de film", only: [ :new, :edit ] do
    div id: "movie-search" do
      input type: "text", id: "movie-search-input", placeholder: "Rechercher un film..."
      div id: "movie-search-results"
    end
  end

  # Action membre pour la recherche de films
  member_action :search_movie, method: :get do
    query = params[:query]
    results = Programmation.search_tmdb(query)
    render json: results
  end

  before_action only: [ :new, :edit ] do
    @page_scripts = [ "active_admin/movie_search" ]
  end
end
