ActiveAdmin.register Programmation do
  menu priority: 1

  permit_params :imdb_id, :time, :max_tickets, :normal_price, :member_price, :reduced_price,
                programmation_staffs_attributes: [ :id, :user_id, :role, :_destroy ]

  index do
    selectable_column
    id_column
    column :movie
    column :time
    column :max_tickets
    column :tickets_remaining
    column "Staffs" do |programmation|
      programmation.programmation_staffs.map do |ps|
        "#{ps.user.first_name} #{ps.user.last_name} (#{ps.role_name})"
      end.join(", ").html_safe
    end
    column :created_at
    actions
  end

  filter :movie
  filter :time
  filter :created_at

  form do |f|
    f.inputs "Informations du film" do
      f.input :imdb_id, hint: "Entrez l'ID IMDB du film (commençant par 'tt'). Les autres informations seront automatiquement remplies."
    end

    f.inputs "Informations de la séance" do
      f.input :time, as: :datetime_picker
      f.input :max_tickets
      f.input :normal_price
      f.input :member_price
      f.input :reduced_price
    end

    f.inputs "Équipe" do
      if User.count > 0
        f.has_many :programmation_staffs, allow_destroy: true, heading: false do |staff|
          staff.input :user, label: "Membre", as: :select, collection: User.where.not(teams: []).map { |u| [ "#{u.first_name} #{u.last_name} - #{u.teams.to_sentence}", u.id ] }
          staff.input :role, as: :select, collection: ProgrammationStaff.roles.map { |k, v| [ k.humanize, k ] }
        end
      else
        div class: "flash flash_warning" do
          "Aucun utilisateur n'est disponible. Veuillez d'abord créer des utilisateurs."
        end
      end
    end

    f.actions
  end

  show do
    attributes_table do
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

    panel "Équipe" do
      table_for programmation.programmation_staffs do
        column :user do |staff|
          staff.user.full_name
        end
        column :role do |staff|
          staff.role_name || staff.role
        end
      end
    end
  end

  controller do
    def create
      programmation_params = permitted_params[:programmation].dup

      # Traiter l'IMDB ID pour obtenir le movie_id
      if programmation_params[:imdb_id].present?
        begin
          movie = Movie.find_or_create_by(imdb_id: programmation_params[:imdb_id])
          if movie && movie.persisted?
            programmation_params[:movie_id] = movie.id
            # Supprimer imdb_id car ce n'est pas un attribut de Programmation
            programmation_params.delete(:imdb_id)
          else
            @programmation = Programmation.new(programmation_params)
            @programmation.imdb_id = programmation_params[:imdb_id]
            @programmation.create_movie_from_imdb
          end
        rescue => e
          Rails.logger.error "Erreur lors de la récupération du film: #{e.message}"
          flash[:error] = "Erreur lors de la récupération des informations du film"
          @programmation = Programmation.new(programmation_params)
          render :new
          return
        end
      else
        flash[:error] = "L'ID IMDB est requis"
        @programmation = Programmation.new(programmation_params)
        render :new
        return
      end

      @programmation = Programmation.new(programmation_params)

      if @programmation.save
        redirect_to admin_programmation_path(@programmation), notice: "Programmation créée avec succès"
      else
        render :new
      end
    end

    def update
      @programmation = Programmation.find(params[:id])
      programmation_params = permitted_params[:programmation].dup

      # Traiter l'IMDB ID pour la mise à jour si présent
      if programmation_params[:imdb_id].present?
        begin
          movie = Movie.find_or_create_by(imdb_id: programmation_params[:imdb_id])
          if movie && movie.persisted?
            programmation_params[:movie_id] = movie.id
            programmation_params.delete(:imdb_id)
          else
            @programmation.imdb_id = programmation_params[:imdb_id]
            @programmation.create_movie_from_imdb
            if @programmation.save
              nil
            else
              flash[:error] = "Impossible de récupérer le film avec l'ID IMDB: #{programmation_params[:imdb_id]}"
              render :edit
              return
            end
          end
        rescue => e
          Rails.logger.error "Erreur lors de la récupération du film: #{e.message}"
          flash[:error] = "Erreur lors de la récupération des informations du film"
          render :edit
          return
        end
      else
        # Si pas d'imdb_id, supprimer le paramètre pour éviter les erreurs
        programmation_params.delete(:imdb_id)
      end

      if @programmation.update(programmation_params)
        redirect_to admin_programmation_path(@programmation), notice: "Programmation mise à jour avec succès"
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
