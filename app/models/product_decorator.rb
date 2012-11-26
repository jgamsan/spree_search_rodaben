Spree::Product.class_eval do
  attr_accessible :tire_speed_code_id, :tire_rf, :tire_innertube_id, :tire_width_id,
                  :tire_serial_id, :tire_gr, :tire_season
  attr_accessible :count_on_hand, :price_in_offert, :show_in_offert

  delegate_belongs_to :master, :tire_width_id, :tire_rf, :tire_innertube_id,
                    :tire_speed_code_id, :tire_serial_id, :tire_gr, :tire_season, :price_in_offert

  scope :by_width, lambda { |width| joins(:master).where("spree_variants.tire_width_id = ?", width)}
  scope :by_serial, lambda { |serial| joins(:master).where("spree_variants.tire_serial_id = ?", serial)}
  scope :by_innertube, lambda { |innertube| joins(:master).where("spree_variants.tire_innertube_id = ?", innertube)}
  scope :by_gr, lambda { |gr| joins(:master).where("spree_variants.tire_gr = ?", gr) }
  scope :by_speed, lambda { |speed| joins(:master).where("spree_variants.tire_speed_code_id = ?", speed)}
  scope :by_rf, lambda { |rf| joins(:master).where("spree_variants.tire_rf = ?", rf)}
  scope :by_season, lambda { |season| joins(:master).where("spree_variants.tire_season = ?", season)}
  scope :in_offert, lambda { |offert| joins(:master).where(:show_in_offert =>  offert)}
  scope :by_supplier, lambda { |supplier| joins(:master).where(:supplier_id =>  supplier)}
  scope :by_price, lambda { |precio| joins(:master).where("spree_variants.price >= ?", precio)}

  add_search_scope :by_vehicle do |vehicle, marca|
    products = Spree::Product.joins(:taxons).where(Spree::Taxon.table_name => {:id => marca}).map {|x| x.id}.flatten
    taxon = Spree::Taxon.table_name
    producto = Spree::Product.table_name
    joins(:taxons).where{:taxon => { :id => vehicle }, :producto => {:id => products}}
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
    a = ancho.nil? ? "*" : ancho.name
    p = perfil.nil? ? "*" : perfil.name
    l = llanta.nil? ? "*" : llanta.name
    v = vel.nil? ? "*" : vel.name
    return a + "/" + p + " " + l + v
  end

end
