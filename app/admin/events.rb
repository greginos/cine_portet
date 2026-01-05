ActiveAdmin.register Event do
  menu priority: 3, label: "Événements"

  permit_params :title, :description, :start_time, :programmation_id, :session_id

  config.sort_order = "start_time_desc"

  # Bouton pour lier les événements orphelins
  action_item :link_all_orphan_events, only: :index do
    orphan_count = Event.without_session.count
    if orphan_count > 0
      link_to "Lier #{orphan_count} événement(s) orphelin(s)",
              link_all_orphans_admin_events_path,
              method: :post,
              data: { confirm: "Cela va lier automatiquement #{orphan_count} événement(s) aux sessions correspondantes. Continuer ?" },
              class: "button"
    end
  end

  collection_action :link_all_orphans, method: :post do
    total = Session.link_all_orphan_events
    if total > 0
      redirect_to admin_events_path, notice: "✓ #{total} événement(s) lié(s) automatiquement"
    else
      redirect_to admin_events_path, alert: "Aucun événement orphelin trouvé"
    end
  end

  index do
    selectable_column
    id_column
    column :title
    column :start_time
    column "Type" do |event|
      status_tag event.event_type, class: event.linked_to_screening? ? 'yes' : 'default'
    end
    column :session do |event|
      link_to event.session.name, admin_session_path(event.session) if event.session
    end
    column :programmation do |event|
      if event.programmation
        link_to event.programmation.movie&.title || "Projection ##{event.programmation.id}", 
                admin_programmation_path(event.programmation)
      end
    end
    column :created_at
    actions
  end

  filter :title
  filter :start_time
  filter :session
  filter :programmation
  filter :created_at

  scope :all, default: true
  scope :upcoming, -> { Event.upcoming }
  scope :past, -> { Event.past }
  scope("Indépendants") { |scope| scope.independent }
  scope("Liés à des projections") { |scope| scope.linked_to_screening }
  scope("Dans des sessions") { |scope| scope.where.not(session_id: nil) }
  scope("Orphelins") { |scope| scope.without_session }

  form do |f|
    f.inputs "Informations de l'événement" do
      f.input :title, label: "Titre", placeholder: "Ex: Débat après la projection, Atelier cinéma, Soirée spéciale..."
      f.input :description, label: "Description", 
              as: :text, 
              input_html: { rows: 8 },
              hint: "Décrivez l'événement (intervenants, thème, programme, etc.)"
      f.input :start_time, 
              as: :datetime_picker, 
              label: "Date et heure de début"
    end

    f.inputs "Associations (optionnelles)" do
      f.input :session, 
              label: "Session",
              as: :select,
              collection: Session.order(start_date: :desc).map { |s| 
                ["#{s.name} (#{s.start_date.strftime('%d/%m/%Y')} - #{s.end_date.strftime('%d/%m/%Y')})", s.id]
              },
              include_blank: "Aucune (sera assignée automatiquement selon la date)",
              hint: "La session sera automatiquement assignée selon la date de l'événement si vous ne la choisissez pas"
      
      f.input :programmation, 
              label: "Projection associée",
              as: :select,
              collection: Programmation.includes(:movie)
                                       .order(time: :desc)
                                       .limit(100)
                                       .map { |p| 
                                         movie_title = p.movie&.title || "Film ##{p.id}"
                                         time_str = p.time.strftime("%d/%m/%Y %H:%M")
                                         session_info = p.session ? " [#{p.session.name}]" : ""
                                         ["#{movie_title} - #{time_str}#{session_info}", p.id]
                                       },
              include_blank: "Aucune (événement indépendant)",
              hint: "Sélectionnez une projection si l'événement y est directement lié (ex: débat après le film)"
    end

    f.actions
  end

  show do
    attributes_table do
      row :title
      row :description do |event|
        simple_format(event.description)
      end
      row :start_time do |event|
        l event.start_time, format: :long
      end
      row :event_type do |event|
        status_tag event.event_type
      end
      row :session do |event|
        if event.session
          link_to event.session.name, admin_session_path(event.session)
        else
          status_tag "Aucune session", type: :warning
        end
      end
      row :programmation do |event|
        if event.programmation
          div do
            span link_to(event.programmation.movie&.title || "Projection ##{event.programmation.id}", 
                        admin_programmation_path(event.programmation))
            span " - "
            span l(event.programmation.time, format: :short)
          end
        else
          "Événement indépendant"
        end
      end
      row :created_at
      row :updated_at
    end
  end
end