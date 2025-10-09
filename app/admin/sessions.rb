ActiveAdmin.register Session do
  permit_params :name, :start_date, :end_date, :description

  # Configuration Ransack pour les recherches et filtres
  config.sort_order = "start_date_desc"

  # Bouton global dans l'index pour lier toutes les orphelines
  action_item :link_all_orphans, only: :index do
    orphan_count = Programmation.without_session.count
    if orphan_count > 0
      link_to "Lier #{orphan_count} programmation(s) orpheline(s)",
              link_all_orphans_admin_sessions_path,
              method: :post,
              data: { confirm: "Cela va lier automatiquement #{orphan_count} programmation(s) aux sessions correspondantes. Continuer ?" },
              class: "button"
    end
  end

  # Bouton dans la page show d'une session spécifique
  action_item :link_orphans, only: :show do
    orphan_count = Programmation.without_session
                                .where("time >= ? AND time <= ?",
                                       resource.start_date.beginning_of_day,
                                       resource.end_date.end_of_day)
                                .count
    if orphan_count > 0
      link_to "Lier #{orphan_count} programmation(s) orpheline(s) à cette session",
              link_orphans_admin_session_path(resource),
              method: :post,
              data: { confirm: "Lier #{orphan_count} programmation(s) à la session '#{resource.name}' ?" },
              class: "button"
    end
  end

  # Action pour lier les orphelines d'une session spécifique
  member_action :link_orphans, method: :post do
    count = resource.link_orphan_programmations
    redirect_to admin_session_path(resource),
                notice: "✓ #{count} programmation(s) liée(s) à la session '#{resource.name}'"
  end

  # Action collection pour lier toutes les orphelines à toutes les sessions
  collection_action :link_all_orphans, method: :post do
    total = Session.link_all_orphan_programmations

    if total > 0
      redirect_to admin_sessions_path, notice: "✓ #{total} programmation(s) liée(s) automatiquement"
    else
      redirect_to admin_sessions_path, alert: "Aucune programmation orpheline trouvée"
    end
  end

  # Batch action pour lier les orphelines aux sessions sélectionnées
  batch_action :link_orphans do |ids|
    total = 0
    sessions = Session.where(id: ids)

    sessions.each do |session|
      count = session.link_orphan_programmations
      total += count
    end

    redirect_to collection_path, notice: "✓ #{total} programmation(s) liée(s) aux #{sessions.count} session(s) sélectionnée(s)"
  end

  index do
    selectable_column
    id_column
    column :name
    column :start_date
    column :end_date
    column :status do |session|
      status_tag session.status, class: session.status.to_s
    end
    column "Programmations" do |session|
      session.total_programmations
    end
    column "Orphelines disponibles" do |session|
      count = Programmation.without_session
                          .where("time >= ? AND time <= ?",
                                 session.start_date.beginning_of_day,
                                 session.end_date.end_of_day)
                          .count
      if count > 0
        status_tag count, type: :warning
      else
        status_tag "0", type: :ok
      end
    end
    column "Billets vendus" do |session|
      session.total_tickets_sold
    end
    actions
  end

  filter :name
  filter :start_date
  filter :end_date
  filter :created_at

  form do |f|
    f.inputs do
      f.input :name, hint: "Ex: Saison Automne 2024"
      f.input :start_date, as: :datepicker
      f.input :end_date, as: :datepicker
      f.input :description, as: :text
    end

    if f.object.persisted?
      f.inputs "Programmations orphelines dans cette période" do
        orphans = Programmation.without_session
                              .where("time >= ? AND time <= ?",
                                     f.object.start_date.beginning_of_day,
                                     f.object.end_date.end_of_day)
                              .includes(:movie)
                              .order(:time)

        if orphans.any?
          f.semantic_fields_for :programmations do
            para "#{orphans.count} programmation(s) orpheline(s) trouvée(s) pour cette période."
            para link_to("Lier automatiquement ces programmations",
                        link_orphans_admin_session_path(f.object),
                        method: :post,
                        data: { confirm: "Lier #{orphans.count} programmation(s) ?" },
                        class: "button")
          end
        else
          f.semantic_fields_for :programmations do
            para "Aucune programmation orpheline dans cette période."
          end
        end
      end
    end

    f.actions
  end

  show do
    attributes_table do
      row :name
      row :start_date
      row :end_date
      row :description
      row :status do |session|
        status_tag session.status
      end
      row :duration do |session|
        "#{session.duration_in_days} jours"
      end
      row :total_programmations do |session|
        session.total_programmations
      end
      row :total_tickets_sold do |session|
        session.total_tickets_sold
      end
    end

    # Afficher les programmations orphelines disponibles
    orphans = Programmation.without_session
                          .where("time >= ? AND time <= ?",
                                 session.start_date.beginning_of_day,
                                 session.end_date.end_of_day)
                          .includes(:movie)
                          .order(:time)

    if orphans.any?
      panel "⚠️ Programmations orphelines disponibles (#{orphans.count})" do
        table_for orphans do
          column :id
          column :time do |prog|
            l prog.time, format: :long
          end
          column :movie do |prog|
            prog.movie&.title || "Sans film"
          end
          column "Billets vendus" do |prog|
            prog.tickets_sold
          end
        end

        div style: "margin-top: 15px;" do
          link_to "Lier ces #{orphans.count} programmation(s) à cette session",
                  link_orphans_admin_session_path(session),
                  method: :post,
                  data: { confirm: "Lier #{orphans.count} programmation(s) à '#{session.name}' ?" },
                  class: "button"
        end
      end
    end

    panel "Programmations de cette session (#{session.programmations.count})" do
      if session.programmations.any?
        table_for session.programmations.includes(:movie).order(time: :asc) do
          column :id
          column :time do |prog|
            l prog.time, format: :long
          end
          column :movie do |prog|
            link_to prog.movie.title, admin_movie_path(prog.movie) if prog.movie
          end
          column "Billets vendus" do |prog|
            "#{prog.tickets_sold} / #{prog.max_tickets || '∞'}"
          end
          column "Actions" do |prog|
            link_to "Voir", admin_programmation_path(prog), class: "member_link"
          end
        end
      else
        para "Aucune programmation liée à cette session."
      end
    end
  end
end
