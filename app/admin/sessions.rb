ActiveAdmin.register Session do
  permit_params :name, :start_date, :end_date, :description

  index do
    selectable_column
    id_column
    column :name
    column :start_date
    column :end_date
    column :status do |session|
      status_tag session.status, class: session.status.to_s
    end
    column :programmations do |session|
      session.total_programmations
    end
    column :tickets_sold do |session|
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
      f.input :name
      f.input :start_date, as: :datepicker
      f.input :end_date, as: :datepicker
      f.input :description
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
    end

    panel "Programmations" do
      table_for session.programmations.includes(:movie).order(time: :asc) do
        column :time
        column :movie
        column "Billets vendus" do |prog|
          prog.tickets_sold
        end
      end
    end
  end
end
