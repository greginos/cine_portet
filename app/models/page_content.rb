class PageContent < ApplicationRecord
  validates :key, presence: true, uniqueness: true

  def self.ransackable_attributes(auth_object = nil)
    %w[key label value created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end

  # Récupère la valeur d'une clé (avec fallback)
  def self.get(key)
    find_by(key: key)&.value.to_s
  end

  KEYS = {
    # Hero
    "hero_title"           => "Ciné à Portet de tous",
    "hero_subtitle"        => "Découvrez le cinéma autrement",
    "hero_button_text"     => "Voir la programmation",
    # À propos
    "about_title"          => "À propos de Ciné Portet",
    "about_description"    => "Ciné à Portet de tous est une association située à Portet-sur-Garonne. Nous proposons une programmation éclectique allant des films d'auteur aux blockbusters, en passant par des documentaires et des films pour enfants.",
    "about_card1_icon"     => "fa-solid fa-film",
    "about_card1_title"    => "Programmation Variée",
    "about_card1_text"     => "Des films pour tous les goûts et tous les âges",
    "about_card2_icon"     => "fa-solid fa-clock",
    "about_card2_title"    => "Horaires Flexibles",
    "about_card2_text"     => "Des séances à différents horaires pour s'adapter à tous",
    "about_card3_icon"     => "fa-solid fa-users",
    "about_card3_title"    => "Ambiance Conviviale",
    "about_card3_text"     => "Un accueil chaleureux dans un cadre agréable",
    # Services
    "services_title"       => "Nos Services",
    "services_subtitle"    => "Découvrez tous les services que nous proposons pour vous offrir la meilleure expérience cinématographique.",
    "service1_icon"        => "fa-solid fa-video",
    "service1_title"       => "Projection HD",
    "service1_text"        => "Qualité d'image optimale pour une expérience immersive",
    "service2_icon"        => "fa-solid fa-heart",
    "service2_title"       => "Tarifs réduits",
    "service2_text"        => "Des prix accessibles pour tous les publics",
    # Contact
    "contact_title"        => "Contactez-nous",
    "contact_subtitle"     => "Une question ? Un projet ? N'hésitez pas à nous contacter !",
    "contact_address"      => "Salle Angèle del Rio Bettini, Allée du Grand Chêne, 31120 Portet-sur-Garonne",
    "contact_email"        => "contact@portet-cine.fr",
    "contact_gmaps_url"    => "https://www.google.com/maps/dir//Salle+Ang%C3%A8le+del+Rio+Bettini,+All.+du+Grand+Ch%C3%AAne,+31120+Portet-sur-Garonne/@43.5419007,1.4072009,19z",
    "contact_waze_url"     => "https://waze.com/ul?ll=43.541115846729,1.40778794256&navigate=yes",
    # Footer
    "footer_copyright"     => "© 2024 Ciné Portet. Tous droits réservés."
  }.freeze
end
