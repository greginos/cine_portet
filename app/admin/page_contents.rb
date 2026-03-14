ActiveAdmin.register PageContent do
  permit_params :key, :value, :label

  menu label: "✏️ Contenu de la page", priority: 1

  actions :index, :edit, :update

  # ──────────────────────────────────────────────
  # INDEX
  # ──────────────────────────────────────────────
  index title: "Contenu de la page d'accueil" do
    column "Section" do |pc|
      status_tag pc.key.split("_").first.capitalize, class: "blue"
    end
    column "Champ", :label
    column "Aperçu" do |pc|
      truncate(strip_tags(pc.value.to_s), length: 80)
    end
    actions
  end

  filter :key_cont, label: "Clé contient"

  # Bouton visible dans l'index
  action_item :edit_all, only: :index do
    link_to "✏️ Tout modifier d'un coup", edit_all_admin_page_contents_path, class: "button"
  end

  # ──────────────────────────────────────────────
  # ACTION : affiche le formulaire global
  # ──────────────────────────────────────────────
  collection_action :edit_all, method: :get do
    @page_contents = PageContent.order(:key).all
  end

  # ──────────────────────────────────────────────
  # ACTION : sauvegarde tous les champs d'un coup
  # ──────────────────────────────────────────────
  collection_action :update_all, method: :post do
    (params[:page_contents] || {}).each do |key, value|
      PageContent.find_by(key: key)&.update(value: value)
    end
    redirect_to edit_all_admin_page_contents_path,
                notice: "✅ Contenu mis à jour avec succès !"
  end

  # ──────────────────────────────────────────────
  # Formulaire d'édition individuelle (inchangé)
  # ──────────────────────────────────────────────
  form title: "Modifier le champ" do |f|
    f.inputs do
      f.input :label, label: "Nom du champ", input_html: { disabled: true }
      f.input :key,   label: "Clé technique", input_html: { disabled: true }
      short_keys = %w[title subtitle button_text email address]
      if short_keys.any? { |k| f.object.key.include?(k) }
        f.input :value, label: "Valeur", as: :string
      else
        f.input :value, label: "Contenu", as: :text, input_html: { rows: 5 }
      end
    end
    f.actions
  end

  after_save do |pc|
    Rails.cache.delete("page_content_#{pc.key}") if defined?(Rails.cache)
  end
end
