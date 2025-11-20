ActiveAdmin.register Session do
  permit_params :name, :start_date, :end_date, :description,
              session_staffs_attributes: [ :id, :user_id, :position, :_destroy ]

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

  member_action :link_orphans, method: :post do
    count = resource.link_orphan_programmations
    redirect_to admin_session_path(resource),
                notice: "✓ #{count} programmation(s) liée(s) à la session '#{resource.name}'"
  end

  collection_action :link_all_orphans, method: :post do
    total = Session.link_all_orphan_programmations
    if total > 0
      redirect_to admin_sessions_path, notice: "✓ #{total} programmation(s) liée(s) automatiquement"
    else
      redirect_to admin_sessions_path, alert: "Aucune programmation orpheline trouvée"
    end
  end

  batch_action :link_orphans do |ids|
    total = 0
    sessions = Session.where(id: ids)
    sessions.each do |session|
      total += session.link_orphan_programmations
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
      count > 0 ? status_tag(count, type: :warning) : status_tag("0", type: :ok)
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
    f.inputs "Informations de la session" do
      f.input :name, hint: "Ex: Saison Automne 2024"
      f.input :start_date, as: :datepicker
      f.input :end_date, as: :datepicker
      f.input :description, as: :text
    end

    f.has_many :session_staffs,
               heading: "Équipe de la session (ouverture / clôture)",
               allow_destroy: true,
               new_record: "➕ Ajouter un bénévole" do |staff|
      staff.input :user, label: "Bénévole",
                  as: :select,
                  collection: User.volunteers.order(:last_name).map { |u| [ "#{u.last_name} #{u.first_name}", u.id ] },
                  include_blank: "-- Choisir un bénévole --"
      staff.input :position, as: :select,
                  collection: [
                    [ "🚀 Ouverture de session", "start_session" ],
                    [ "🏁 Clôture de session", "end_session" ]
                  ],
                  label: "Poste",
                  include_blank: false
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

    # Panel Équipe de session (ouverture / clôture)
    panel "Équipe de session" do
      columns do
        column do
          h4 "🚀 Ouverture de session"
          start_staffs = session.session_staffs.includes(:user).where(position: :start_session)
          if start_staffs.any?
            table_for start_staffs do
              column "Bénévole" do |staff|
                link_to staff.user.full_name, admin_volunteer_path(staff.user)
              end
              column "Email" do |staff|
                staff.user.email
              end
            end
          else
            para "Aucun bénévole assigné à l'ouverture.", class: "empty"
          end
        end

        column do
          h4 "🏁 Clôture de session"
          end_staffs = session.session_staffs.includes(:user).where(position: :end_session)
          if end_staffs.any?
            table_for end_staffs do
              column "Bénévole" do |staff|
                link_to staff.user.full_name, admin_volunteer_path(staff.user)
              end
              column "Email" do |staff|
                staff.user.email
              end
            end
          else
            para "Aucun bénévole assigné à la clôture.", class: "empty"
          end
        end
      end
    end

    # Programmations orphelines disponibles
    orphans = Programmation.without_session
                          .where("time >= ? AND time <= ?",
                                 session.start_date.beginning_of_day,
                                 session.end_date.end_of_day)
                          .includes(:movie, programmation_staffs: :user)
                          .order(:time)

    if orphans.any?
      panel "⚠️ Programmations orphelines disponibles (#{orphans.count})" do
        table_for orphans do
          column :id
          column "Date/Heure" do |prog|
            l prog.time, format: :long
          end
          column "Film" do |prog|
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

    # Panel principal : Programmations avec bénévoles
    panel "Programmations de cette session (#{session.programmations.count})" do
      if session.programmations.any?
        table_for session.programmations.includes(:movie, programmation_staffs: :user).order(time: :asc) do
          column :id
          column "Date/Heure" do |prog|
            l prog.time, format: :long
          end
          column "Film" do |prog|
            link_to prog.movie.title, admin_movie_path(prog.movie) if prog.movie
          end
          column "Billets" do |prog|
            "#{prog.tickets_sold} / #{prog.max_tickets || '∞'}"
          end
          column "Bénévoles" do |prog|
            if prog.programmation_staffs.any?
              prog.programmation_staffs.map do |ps|
                role_name = ps.role_name || ps.role
                user_link = link_to(ps.user.full_name, admin_volunteer_path(ps.user))
                content_tag(:span, class: "volunteer-badge") do
                  "#{user_link} (#{role_name})".html_safe
                end
              end.join("<br>").html_safe
            else
              status_tag "Aucun bénévole", type: :warning
            end
          end
          column "Actions" do |prog|
            span link_to("Voir", admin_programmation_path(prog), class: "member_link")
            span link_to("Modifier", edit_admin_programmation_path(prog), class: "member_link")
          end
        end
      else
        para "Aucune programmation liée à cette session."
      end
    end

    # Panel récapitulatif des bénévoles
    panel "Récapitulatif des bénévoles impliqués" do
      volunteers_data = session.programmations
                               .includes(programmation_staffs: :user)
                               .flat_map(&:programmation_staffs)
                               .group_by(&:user)

      if volunteers_data.any?
        table_for volunteers_data.sort_by { |user, _| user.last_name } do
          column "Bénévole" do |user, _|
            link_to user.full_name, admin_volunteer_path(user)
          end
          column "Email" do |user, _|
            user.email
          end
          column "Équipes" do |user, _|
            user.teams.present? ? user.teams.map { |t| I18n.t("teams.#{t}") }.join(", ") : "-"
          end
          column "Participations" do |_, staffs|
            staffs.count
          end
          column "Rôles" do |_, staffs|
            staffs.map { |s| s.role_name || s.role }.uniq.join(", ")
          end
          column "Séances" do |_, staffs|
            staffs.map do |s|
              prog = s.programmation
              "#{prog.movie&.title} (#{l prog.time, format: :short})"
            end.join("<br>").html_safe
          end
        end
      else
        para "Aucun bénévole assigné aux programmations de cette session."
      end
    end
  end
end
