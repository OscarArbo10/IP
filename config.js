// ================================================================
//  ILUSION PERFUMERY – Configuración Principal y Supabase
//  ⚠️ Reemplaza SUPABASE_URL y SUPABASE_KEY con las credenciales
//     de tu proyecto en Supabase (Settings → API)
// ================================================================

const SUPABASE_URL  = 'https://zgostibqnwthplydducm.supabase.co';
const SUPABASE_KEY  = 'sb_publishable_kD7kQgNxD_kX7Vx5Dm5vvQ_yNcy2q9B';
const WHATSAPP_NUMBER = '573218885945'; // Código de país + número (sin + ni espacios)

// ================================================================
//  Valores por defecto de la tienda (Todo es 100% editable desde
//  el Panel de Administración → pestaña "Mi Página & Logo")
// ================================================================
const SITE_DEFAULTS = {
  // Identidad y Marca
  site_name: 'ILUSION PERFUMERY',
  site_subtitle: 'HIGH PERFUMERY FOR MEN',
  logo_url: '',
  logo_height: 58,
  primary_color: '#f5c518', // Amarillo / Dorado insignia

  // Control Global de Precios
  // 'per_product' = respeta el switch de cada perfume (por defecto ocultos)
  // 'hide_all'    = oculta absolutamente todos los precios en la tienda
  // 'show_all'    = muestra el precio en todos los perfumes que tengan valor > 0
  price_display_mode: 'per_product',
  no_price_label: 'Precio bajo consulta',
  whatsapp_inquire_btn: 'Consultar por WhatsApp',
  whatsapp_buy_btn: 'Pedir por WhatsApp',

  // Modalidades de Venta y Entrega
  whatsapp: WHATSAPP_NUMBER,
  door_delivery_enabled: true,
  door_delivery_title: 'Entrega en la Puerta de tu Casa',
  door_delivery_desc: 'Recibe tu fragancia directamente en tu domicilio con atención prioritaria y pago seguro.',
  door_delivery_badge: 'Domicilio Express',
  national_shipping_enabled: true,
  national_shipping_title: 'Envíos Seguros a Todo el País',
  national_shipping_desc: 'Embalaje blindado anti-impacto y guía de rastreo en tiempo real hasta tu ciudad.',
  national_shipping_badge: 'Cobertura Nacional',
  whatsapp_sales_title: 'Asesoría & Ventas por WhatsApp',
  whatsapp_sales_desc: '¿No sabes qué perfume elegir o deseas consultar disponibilidad? Te asesoramos al instante.',
  shipping_cost: 0,
  free_shipping_min: 200000,

  // Barra superior de anuncio
  announcement: '⚡ PERFUMERÍA MASCULINA EXCLUSIVA · 🏠 ENTREGA EN LA PUERTA DE TU CASA · 📦 ENVÍOS A TODO EL PAÍS',

  // Hero Dinámico
  hero_tag: '👑 COLECCIÓN MASCULINA EXCLUSIVA',
  hero_title: 'Domina cada instante con tu',
  hero_accent: 'Ilusión.',
  hero_words: 'Presencia, Carácter, Seducción, Elegancia, Poder',
  hero_subtitle: 'Fragancias masculinas de diseñador, árabes y nicho seleccionadas para hombres que dejan huella. Recibe en la puerta de tu casa o pide envío a todo el país.',
  hero_cta: 'Explorar Catálogo 🔥',
  hero_secondary_cta: 'Asesoría por WhatsApp 💬',
  hero_badge_1: '100% Originales & Garantizados',
  hero_badge_2: 'Entrega Puerta a Puerta',
  hero_badge_3: 'Atención VIP por WhatsApp',

  // Secciones del Catálogo
  products_title: 'Catálogo de Fragancias',
  products_subtitle: 'Perfumes masculinos diseñados para proyectar poder, elegancia y magnetismo',
  offers_title: '🔥 Destacados de la Semana',

  // Fotos y Configuración de las 4 Categorías Principales del Index (100% escogibles y editables en el Admin)
  cat_img_caballero: 'https://images.unsplash.com/photo-1594035910387-fea47794261f?auto=format&fit=crop&w=700&q=80',
  cat_img_dama: 'https://images.unsplash.com/photo-1541643600914-78b084683601?auto=format&fit=crop&w=700&q=80',
  cat_img_nicho: 'https://images.unsplash.com/photo-1585386959984-a4155224a1ad?auto=format&fit=crop&w=700&q=80',
  cat_img_splash: 'https://images.unsplash.com/photo-1592945403244-b3fbafd7f539?auto=format&fit=crop&w=700&q=80',
  featured_categories: [
    {
      slug: 'caballero',
      title: 'Caballero',
      subtitle: 'Fragancias masculinas de carácter y seducción',
      image: 'https://images.unsplash.com/photo-1594035910387-fea47794261f?auto=format&fit=crop&w=700&q=80'
    },
    {
      slug: 'dama',
      title: 'Dama',
      subtitle: 'Aromas femeninos elegantes, dulces y envolventes',
      image: 'https://images.unsplash.com/photo-1541643600914-78b084683601?auto=format&fit=crop&w=700&q=80'
    },
    {
      slug: 'nicho',
      title: 'Nicho',
      subtitle: 'Alta perfumería de autor y lujo exclusivo',
      image: 'https://images.unsplash.com/photo-1585386959984-a4155224a1ad?auto=format&fit=crop&w=700&q=80'
    },
    {
      slug: 'splash',
      title: 'Splash',
      subtitle: 'Body mists frescos, ligeros e irresistibles',
      image: 'https://images.unsplash.com/photo-1592945403244-b3fbafd7f539?auto=format&fit=crop&w=700&q=80'
    }
  ],

  // Banner Promocional
  promo_enabled: true,
  promo_tag: 'EDICIÓN LIMITADA · ENTREGA INMEDIATA',
  promo_title: '¿Buscas un perfume específico o necesitas asesoría?',
  promo_text: 'Escríbenos directamente a nuestro WhatsApp. Te ayudamos a elegir la fragancia ideal para tu estilo y te la llevamos hasta la puerta de tu casa.',
  promo_cta: 'Hablar con un Asesor Ahora',

  // Banner Exclusivo de Descuento Web (5%)
  web_discount_enabled: true,
  web_discount_tag: 'BENEFICIO EXCLUSIVO WEB',
  web_discount_percent: '5%',
  web_discount_title: '5% de Descuento por Compras o Consultas desde la Página',
  web_discount_text: 'Cotiza, consulta disponibilidad o realiza tu pedido directamente desde nuestra tienda online y obtén un 5% OFF en tu fragancia.',
  web_discount_code: 'WEB5',
  web_discount_cta: 'Reclamar 5% OFF por WhatsApp',

  // Testimonios de Clientes
  testimonials_title: 'Hombres que ya dejan huella',
  testimonials_subtitle: 'Experiencias reales de clientes con Ilusion Perfumery',
  testimonials: [
    {
      name: 'Andrés V.',
      role: 'Cliente VIP · Entrega en Casa',
      avatar: '🧔🏻‍♂️',
      text: 'Pedí asesoría por WhatsApp para un perfume nocturno y me recomendaron Khamrah y Sauvage Elixir. Me llegó a la puerta de la casa el mismo día. Fijación brutal.'
    },
    {
      name: 'Carlos M.',
      role: 'Envío Nacional',
      avatar: '🕴🏻',
      text: 'El empaque viene súper protegido y la atención por WhatsApp es inmediata. Pregunté por el precio de Bleu de Chanel y en minutos coordinamos todo.'
    },
    {
      name: 'Sebastián R.',
      role: 'Coleccionista de Fragancias',
      avatar: '👑',
      text: 'Excelente catálogo masculino. Me encanta poder consultar disponibilidad directo por WhatsApp y pagar al recibir en mi domicilio.'
    }
  ],

  // Redes Sociales y Footer
  instagram_title: '📸 Síguenos en Redes Sociales',
  instagram_text: 'Descubre reseñas olfativas, nuevos lanzamientos y promociones exclusivas.',
  instagram_handle: 'ilusion.perfumery',
  tiktok_handle: 'ilusion.perfumery',
  footer_slogan: 'El arte de la perfumería masculina. Proyecta poder, elegancia y distinción en cada gota.',
  footer_location: '📍 Entregas a Domicilio Puerta a Puerta & Envíos Nacionales'
};
