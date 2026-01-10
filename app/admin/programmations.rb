ActiveAdmin.register Programmation do
  menu priority: 2

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
          staff.input :user, label: "Membre", as: :select, collection: User.volunteers.map { |u| [ "#{u.first_name} #{u.last_name} - #{u.teams.to_sentence}", u.id ] }
          staff.input :role, as: :select,
          collection: ProgrammationStaff.roles.keys.map { |k|
            [ I18n.t("programmation_staff.roles.#{k}"), k ]
          },
          label: "Rôle"
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
    def update
      @programmation = Programmation.find(params[:id])
      programmation_params = permitted_params[:programmation].dup

      if programmation_params[:imdb_id].present?
        begin
          imdb_id = programmation_params[:imdb_id]
          movie = Movie.find_by(imdb_id: imdb_id)

          if movie.nil? || movie.title.blank?
            movie&.destroy if movie&.title.blank?

            movie_details = MovieService.fetch_movie_details(imdb_id)

            if movie_details
              movie = Movie.create!(
                title: movie_details["title"],
                description: movie_details["description"],
                duration: movie_details["duration"],
                genre: movie_details["genre"],
                director: movie_details["director"],
                cast: movie_details["actors"],
                poster_url: movie_details["poster_url"],
                imdb_id: imdb_id
              )

              programmation_params[:movie_id] = movie.id
              programmation_params.delete(:imdb_id)
            else
              flash[:error] = "Impossible de récupérer le film avec l'ID IMDB: #{imdb_id}"
              render :edit
              return
            end
          else
            programmation_params[:movie_id] = movie.id
            programmation_params.delete(:imdb_id)
          end
        rescue => e
          Rails.logger.error "Erreur: #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
          flash[:error] = "Erreur: #{e.message}"
          render :edit
          return
        end
      else
        programmation_params.delete(:imdb_id)
      end

      if @programmation.update(programmation_params)
        redirect_to admin_programmation_path(@programmation), notice: "Programmation mise à jour avec succès"
      else
        render :edit
      end
    end

    def create
      puts "=" * 50
      puts "DEBUT CREATE"
      programmation_params = permitted_params[:programmation].dup
      puts "Params: #{programmation_params.inspect}"

      if programmation_params[:imdb_id].present?
        puts "IMDB ID présent: #{programmation_params[:imdb_id]}"
        begin
          imdb_id = programmation_params[:imdb_id]
          puts "Recherche film..."
          movie = Movie.find_by(imdb_id: imdb_id)
          puts "Film trouvé: #{movie.inspect}"

          if movie.nil? || movie.title.blank?
            puts "Fetch nécessaire"
            movie&.destroy if movie&.title.blank?

            puts "Appel MovieService..."
            movie_details = MovieService.fetch_movie_details(imdb_id)
            puts "Résultat: #{movie_details.inspect}"

            if movie_details
              puts "Création du film..."
              movie = Movie.create!(
                title: movie_details["title"],
                description: movie_details["description"],
                duration: movie_details["duration"],
                genre: movie_details["genre"],
                director: movie_details["director"],
                cast: movie_details["actors"],
                poster_url: movie_details["poster_url"],
                imdb_id: imdb_id
              )
              puts "Film créé avec ID: #{movie.id}"

              programmation_params[:movie_id] = movie.id
            else
              puts "MovieService a retourné nil"
              flash[:error] = "Impossible de récupérer le film avec l'ID IMDB: #{imdb_id}"
              @programmation = Programmation.new
              render :new
              return
            end
          else
            puts "Film existe déjà"
            programmation_params[:movie_id] = movie.id
          end
        rescue => e
          puts "EXCEPTION: #{e.class} - #{e.message}"
          puts e.backtrace.first(5).join("\n")
          Rails.logger.error "Erreur: #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
          flash[:error] = "Erreur: #{e.message}"
          @programmation = Programmation.new
          render :new
          return
        end
      else
        flash[:error] = "L'ID IMDB est requis"
        @programmation = Programmation.new
        render :new
        return
      end

      puts "Suppression imdb_id et création programmation..."
      programmation_params.delete(:imdb_id)
      @programmation = Programmation.new(programmation_params)

      if @programmation.save
        puts "Programmation sauvegardée !"
        redirect_to admin_programmation_path(@programmation), notice: "Programmation créée avec succès"
      else
        puts "Erreurs de validation: #{@programmation.errors.full_messages}"
        render :new
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
