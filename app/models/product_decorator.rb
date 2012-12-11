Spree::Product.class_eval do
  attr_accessible :tire_speed_code_id, :tire_rf, :tire_innertube_id, :tire_width_id,
                  :tire_serial_id, :tire_gr, :tire_season, :tire_position, :tire_load_code_id
  attr_accessible :count_on_hand, :price_in_offert, :show_in_offert

  delegate_belongs_to :master, :tire_width_id, :tire_rf, :tire_innertube_id,
                    :tire_speed_code_id, :tire_serial_id, :tire_gr, :tire_season, :price_in_offert,
                    :tire_position, :tire_load_code_id

  scope :by_width, lambda { |width| joins(:master).where("spree_variants.tire_width_id = ?", width)}
  scope :by_serial, lambda { |serial| joins(:master).where("spree_variants.tire_serial_id = ?", serial)}
  scope :by_innertube, lambda { |innertube| joins(:master).where("spree_variants.tire_innertube_id = ?", innertube)}
  scope :by_gr, lambda { |gr| joins(:master).where("spree_variants.tire_gr = ?", gr) }
  scope :by_speed, lambda { |speed| joins(:master).where("spree_variants.tire_speed_code_id = ?", speed)}
  scope :by_load_code, lambda { |load_code| joins(:master).where("spree_variants.tire_load_code_id = ?", load_code)}
  scope :by_rf, lambda { |rf| joins(:master).where("spree_variants.tire_rf = ?", rf)}
  scope :by_position, lambda { |position| joins(:master).where("spree_variants.tire_position = ?", position)}
  scope :by_season, lambda { |season| joins(:master).where("spree_variants.tire_season = ?", season)}
  scope :in_offert, lambda { |offert| joins(:master).where(:show_in_offert =>  offert)}
  scope :by_supplier, lambda { |supplier| joins(:master).where(:supplier_id =>  supplier)}
  scope :by_price, lambda { |precio| joins([:master => :prices]).where("spree_prices.amount >= ?", precio)}

  add_search_scope :by_vehicle do |vehicle, marca|
    joins(:taxons).where("spree_taxons.id IN (:vehiculo) AND spree_products.id IN (SELECT spree_products.id FROM spree_products INNER JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id INNER JOIN spree_taxons ON spree_taxons.id = spree_products_taxons.taxon_id WHERE spree_taxons.id = :brand)", {:vehiculo => vehicle.map {|x| x.to_i}, :brand => marca})
  end

  def self.like_all(fields, values)
      where_str = fields.map { |field| Array.new(values.size, "#{self.quoted_table_name}.#{field} #{LIKE} ?").join(' AND ') }.join(' OR ')
      self.where([where_str, values.map { |value| "%#{value}%" } * fields.size].flatten)
    end

  def display_price_in_offert
    Spree::Money.new(price_in_offert).to_s
  end

  def calculate_tires
    variante = Spree::Variant.find_by_product_id(id)
    ancho = variante.tire_width
    perfil = variante.tire_serial
    llanta = variante.tire_innertube
    vel = variante.tire_speed_code
    load_code = variante.tire_load_code
    rf = variante.tire_rf
    position = variante.tire_position
    a = ancho.nil? ? "*" : ancho.name
    p = perfil.nil? ? "*" : perfil.name
    l = llanta.nil? ? "*" : llanta.name
    v = vel.nil? ? "*" : vel.name
    lo = load_code.nil? ? "*" : load_code.name
    r = rf.nil? ? "*" : TUBE_OPTIONS[rf-1][0]
    po = position.nil? ? "*" : POSITION_OPTIONS[position-1][2]
    if variante.product.taxons.first.permalink == "categorias/neumaticos/moto"
      a + "/" + p + "-" + l + " " + lo + v + " " + po + " " + r    
    else
      a + "/" + p + " " + l + v
    end
  end

end
