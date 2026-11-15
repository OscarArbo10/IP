-- ================================================================
--  ILUSION PERFUMERY – Script SQL Completo para Supabase
--  Ejecutar en: Supabase Dashboard → SQL Editor → New query
--  (Es idempotente: puedes ejecutarlo varias veces sin errores)
-- ================================================================

-- 1. TABLA DE CATEGORÍAS / FAMILIAS OLFATIVAS
CREATE TABLE IF NOT EXISTS categories (
  id         BIGSERIAL PRIMARY KEY,
  name       TEXT NOT NULL,
  slug       TEXT NOT NULL UNIQUE,
  emoji      TEXT NOT NULL DEFAULT '👑',
  active     BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. TABLA DE PERFUMES (PRODUCTOS)
CREATE TABLE IF NOT EXISTS products (
  id               BIGSERIAL PRIMARY KEY,
  name             TEXT        NOT NULL,
  brand            TEXT        NOT NULL DEFAULT 'Ilusion Perfumery',
  price            INTEGER     DEFAULT 0,         -- Precio numérico (opcional)
  old_price        INTEGER     DEFAULT NULL,      -- Precio anterior tachado
  discount_percent INTEGER     DEFAULT NULL CHECK (discount_percent IS NULL OR (discount_percent >= 0 AND discount_percent <= 95)),
  show_price       BOOLEAN     NOT NULL DEFAULT FALSE, -- Por defecto NO muestra precio (consulta por WhatsApp)
  category         TEXT        NOT NULL DEFAULT 'arabes',
  concentration    TEXT        DEFAULT 'Eau de Parfum (EDP)', -- EDP | Parfum | Elixir | EDT | Extrait
  size_ml          TEXT        DEFAULT '100 ml',              -- Presentación principal
  notes            TEXT        DEFAULT NULL,                  -- Notas olfativas (ej. Bergamota, Ámbar, Oud)
  occasion         TEXT        DEFAULT 'Noche & Citas',       -- Noche & Citas | Oficina & Poder | Fresco Diario | Eventos VIP
  emoji            TEXT        NOT NULL DEFAULT '🖤',
  badge            TEXT        DEFAULT NULL,                  -- "Top Ventas", "Árabe Exclusivo", "Nuevo", etc.
  stars            INTEGER     NOT NULL DEFAULT 5 CHECK (stars BETWEEN 1 AND 5),
  reviews          INTEGER     NOT NULL DEFAULT 24,
  description      TEXT        DEFAULT NULL,
  image_url        TEXT        DEFAULT NULL,
  images           JSONB       DEFAULT '[]'::jsonb,           -- Galería multi-imagen
  variants         JSONB       DEFAULT '[]'::jsonb,           -- Presentaciones (ej. 100ml, Decant 10ml, 200ml)
  featured         BOOLEAN     NOT NULL DEFAULT FALSE,
  active           BOOLEAN     NOT NULL DEFAULT TRUE,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Asegurar todas las columnas nuevas si la tabla ya existía con un esquema anterior
ALTER TABLE products ADD COLUMN IF NOT EXISTS brand TEXT NOT NULL DEFAULT 'Ilusion Perfumery';
ALTER TABLE products ADD COLUMN IF NOT EXISTS price INTEGER DEFAULT 0;
ALTER TABLE products ADD COLUMN IF NOT EXISTS old_price INTEGER DEFAULT NULL;
ALTER TABLE products ADD COLUMN IF NOT EXISTS show_price BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE products ADD COLUMN IF NOT EXISTS discount_percent INTEGER DEFAULT NULL;
ALTER TABLE products ADD COLUMN IF NOT EXISTS category TEXT NOT NULL DEFAULT 'arabes';
ALTER TABLE products ADD COLUMN IF NOT EXISTS concentration TEXT DEFAULT 'Eau de Parfum (EDP)';
ALTER TABLE products ADD COLUMN IF NOT EXISTS size_ml TEXT DEFAULT '100 ml';
ALTER TABLE products ADD COLUMN IF NOT EXISTS notes TEXT DEFAULT NULL;
ALTER TABLE products ADD COLUMN IF NOT EXISTS occasion TEXT DEFAULT 'Noche & Citas';
ALTER TABLE products ADD COLUMN IF NOT EXISTS emoji TEXT NOT NULL DEFAULT '🖤';
ALTER TABLE products ADD COLUMN IF NOT EXISTS badge TEXT DEFAULT NULL;
ALTER TABLE products ADD COLUMN IF NOT EXISTS stars INTEGER NOT NULL DEFAULT 5;
ALTER TABLE products ADD COLUMN IF NOT EXISTS reviews INTEGER NOT NULL DEFAULT 24;
ALTER TABLE products ADD COLUMN IF NOT EXISTS description TEXT DEFAULT NULL;
ALTER TABLE products ADD COLUMN IF NOT EXISTS image_url TEXT DEFAULT NULL;
ALTER TABLE products ADD COLUMN IF NOT EXISTS images JSONB DEFAULT '[]'::jsonb;
ALTER TABLE products ADD COLUMN IF NOT EXISTS variants JSONB DEFAULT '[]'::jsonb;
ALTER TABLE products ADD COLUMN IF NOT EXISTS featured BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE products ADD COLUMN IF NOT EXISTS active BOOLEAN NOT NULL DEFAULT TRUE;
ALTER TABLE products ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT NOW();
ALTER TABLE products ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

-- Índices para alto rendimiento
CREATE INDEX IF NOT EXISTS idx_products_category ON products (category);
CREATE INDEX IF NOT EXISTS idx_products_active ON products (active);
CREATE INDEX IF NOT EXISTS idx_products_images ON products USING gin (images);
CREATE INDEX IF NOT EXISTS idx_products_variants ON products USING gin (variants);

-- 3. TABLA DE AJUSTES DEL SITIO Y LOGO (una sola fila id = 1)
CREATE TABLE IF NOT EXISTS site_settings (
  id         INTEGER PRIMARY KEY DEFAULT 1 CHECK (id = 1),
  settings   JSONB NOT NULL DEFAULT '{}'::jsonb,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

INSERT INTO site_settings (id, settings)
VALUES (1, '{}'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- 4. TRIGGER AUTOMÁTICO DE UPDATED_AT
CREATE OR REPLACE FUNCTION public.update_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = ''
AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_products_updated_at ON products;
CREATE TRIGGER trg_products_updated_at
  BEFORE UPDATE ON products
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

DROP TRIGGER IF EXISTS trg_site_settings_updated_at ON site_settings;
CREATE TRIGGER trg_site_settings_updated_at
  BEFORE UPDATE ON site_settings
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

-- 5. SEGURIDAD: ROW LEVEL SECURITY (RLS)
-- ⚠️ IMPORTANTE: En Supabase Dashboard → Authentication → Providers → Email,
-- desactiva "Allow new users to sign up" para que solo los usuarios administradores
-- creados manualmente puedan autenticarse.
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE site_settings ENABLE ROW LEVEL SECURITY;

-- Políticas de Categorías
DROP POLICY IF EXISTS "Lectura publica de categorias" ON categories;
CREATE POLICY "Lectura publica de categorias"
  ON categories FOR SELECT
  TO anon
  USING (active = TRUE);

DROP POLICY IF EXISTS "Lectura admin de categorias" ON categories;
CREATE POLICY "Lectura admin de categorias"
  ON categories FOR SELECT
  TO authenticated
  USING ((SELECT auth.uid()) IS NOT NULL);

DROP POLICY IF EXISTS "Admin gestiona categorias" ON categories;
CREATE POLICY "Admin gestiona categorias"
  ON categories FOR ALL
  TO authenticated
  USING ((SELECT auth.uid()) IS NOT NULL)
  WITH CHECK ((SELECT auth.uid()) IS NOT NULL);

-- Políticas de Productos
DROP POLICY IF EXISTS "Lectura publica de productos" ON products;
CREATE POLICY "Lectura publica de productos"
  ON products FOR SELECT
  TO anon
  USING (active = TRUE);

DROP POLICY IF EXISTS "Lectura admin de productos" ON products;
CREATE POLICY "Lectura admin de productos"
  ON products FOR SELECT
  TO authenticated
  USING ((SELECT auth.uid()) IS NOT NULL);

DROP POLICY IF EXISTS "Solo admin puede insertar" ON products;
CREATE POLICY "Solo admin puede insertar"
  ON products FOR INSERT
  TO authenticated
  WITH CHECK ((SELECT auth.uid()) IS NOT NULL);

DROP POLICY IF EXISTS "Solo admin puede actualizar" ON products;
CREATE POLICY "Solo admin puede actualizar"
  ON products FOR UPDATE
  TO authenticated
  USING ((SELECT auth.uid()) IS NOT NULL)
  WITH CHECK ((SELECT auth.uid()) IS NOT NULL);

DROP POLICY IF EXISTS "Solo admin puede eliminar" ON products;
CREATE POLICY "Solo admin puede eliminar"
  ON products FOR DELETE
  TO authenticated
  USING ((SELECT auth.uid()) IS NOT NULL);

-- Políticas de Ajustes del Sitio (Logo, Textos, Configuración)
DROP POLICY IF EXISTS "Lectura publica de ajustes" ON site_settings;
CREATE POLICY "Lectura publica de ajustes"
  ON site_settings FOR SELECT
  TO anon, authenticated
  USING (TRUE);

DROP POLICY IF EXISTS "Admin inserta ajustes" ON site_settings;
CREATE POLICY "Admin inserta ajustes"
  ON site_settings FOR INSERT
  TO authenticated
  WITH CHECK (id = 1 AND (SELECT auth.uid()) IS NOT NULL);

DROP POLICY IF EXISTS "Admin actualiza ajustes" ON site_settings;
CREATE POLICY "Admin actualiza ajustes"
  ON site_settings FOR UPDATE
  TO authenticated
  USING (id = 1 AND (SELECT auth.uid()) IS NOT NULL)
  WITH CHECK (id = 1 AND (SELECT auth.uid()) IS NOT NULL);

-- 6. STORAGE BUCKET PARA FOTOS DE PERFUMES Y LOGO DEL SITIO
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'products',
  'products',
  TRUE,
  5242880, -- Límite de 5 MB por archivo para seguridad
  ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif', 'image/svg+xml']
)
ON CONFLICT (id) DO UPDATE SET
  public = TRUE,
  file_size_limit = 5242880,
  allowed_mime_types = ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif', 'image/svg+xml'];

DROP POLICY IF EXISTS "Lectura publica de imagenes" ON storage.objects;
CREATE POLICY "Lectura publica de imagenes"
  ON storage.objects FOR SELECT
  TO anon, authenticated
  USING (bucket_id = 'products');

DROP POLICY IF EXISTS "Admin sube imagenes" ON storage.objects;
CREATE POLICY "Admin sube imagenes"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'products' AND (SELECT auth.uid()) IS NOT NULL);

DROP POLICY IF EXISTS "Admin actualiza imagenes" ON storage.objects;
CREATE POLICY "Admin actualiza imagenes"
  ON storage.objects FOR UPDATE
  TO authenticated
  USING (bucket_id = 'products' AND (SELECT auth.uid()) IS NOT NULL)
  WITH CHECK (bucket_id = 'products' AND (SELECT auth.uid()) IS NOT NULL);

DROP POLICY IF EXISTS "Admin elimina imagenes" ON storage.objects;
CREATE POLICY "Admin elimina imagenes"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (bucket_id = 'products' AND (SELECT auth.uid()) IS NOT NULL);

-- 7. CATEGORÍAS INICIALES PARA ILUSION PERFUMERY
INSERT INTO categories (name, slug, emoji) VALUES
  ('Caballero',           'caballero',   '🕴️'),
  ('Dama',                'dama',        '👑'),
  ('Nicho',               'nicho',       '💎'),
  ('Splash',              'splash',      '🌸'),
  ('Perfumería Árabe',    'arabes',      '🕌'),
  ('Diseñador',           'disenador',   '👔'),
  ('Nocturnos & Citas',   'nocturnos',   '🔥'),
  ('Frescos & Versátiles','frescos',     '🌊'),
  ('Decants & Sets',      'decants',     '🧪')
ON CONFLICT (slug) DO NOTHING;

-- 8. CATÁLOGO INICIAL DE PERFUMES MASCULINOS (Precios ocultos por defecto: show_price = FALSE)
INSERT INTO products (
  name, brand, price, old_price, show_price, category, concentration, size_ml,
  notes, occasion, emoji, badge, stars, reviews, description, image_url, variants, featured
)
SELECT * FROM (VALUES
  (
    'Sauvage Elixir',
    'Dior',
    0, NULL::integer, FALSE,
    'disenador', 'Elixir Concentrado', '60 ml / 100 ml',
    'Canela, Nuez Moscada, Cardamomo, Lavanda, Regaliz, Sándalo y Ámbar',
    'Noche & Citas', '🔥', 'Top Ventas', 5, 342,
    'Una estela magnética, densa y ultra masculina. El rey indiscutible de la noche con una fijación superior a 14 horas.',
    'https://images.unsplash.com/photo-1594035910387-fea47794261f?auto=format&fit=crop&w=900&q=80',
    '[{"name": "60 ml Sellado"}, {"name": "100 ml Sellado"}, {"name": "Decant 10 ml"}]'::jsonb,
    TRUE
  ),
  (
    'Khamrah Qahwa',
    'Lattafa',
    0, NULL::integer, FALSE,
    'arabes', 'Eau de Parfum (EDP)', '100 ml',
    'Café Arábica, Canela, Cardamomo, Praliné, Dátiles, Vainilla y Habas Tonka',
    'Noche & Citas', '🕌', 'Árabe Exclusivo', 5, 418,
    'Joya de la perfumería árabe con un acorde adictivo de café especiado, dátiles dulces y maderas ambaradas. Cumplidos garantizados.',
    'https://images.unsplash.com/photo-1547887537-6158d64c35b3?auto=format&fit=crop&w=900&q=80',
    '[{"name": "100 ml Sellado"}, {"name": "Decant 10 ml"}]'::jsonb,
    TRUE
  ),
  (
    'Bleu de Chanel',
    'Chanel',
    0, NULL::integer, FALSE,
    'disenador', 'Eau de Parfum (EDP)', '100 ml',
    'Pomelo, Menta, Pimienta Rosa, Incienso, Jengibre y Cedro del Atlas',
    'Oficina & Poder', '👔', 'Clásico Elegante', 5, 289,
    'El estándar de oro de la elegancia masculina. Versátil, sofisticado e imponente para reuniones de negocios o eventos formales.',
    'https://images.unsplash.com/photo-1523293182086-7651a899d37f?auto=format&fit=crop&w=900&q=80',
    '[{"name": "100 ml EDP"}, {"name": "150 ml EDP"}]'::jsonb,
    TRUE
  ),
  (
    'Aventus',
    'Creed',
    0, NULL::integer, FALSE,
    'nicho', 'Eau de Parfum (EDP)', '100 ml',
    'Piña Imperial, Bergamota, Abedul Ahumado, Musgo de Roble y Ámbar Gris',
    'Eventos VIP', '👑', 'Nicho VIP', 5, 512,
    'El perfume del éxito y el liderazgo. Una combinación legendaria de frescura frutal y maderas ahumadas que proyecta autoridad.',
    'https://images.unsplash.com/photo-1585386959984-a4155224a1ad?auto=format&fit=crop&w=900&q=80',
    '[{"name": "100 ml Sellado"}, {"name": "Decant 10 ml"}]'::jsonb,
    TRUE
  ),
  (
    'Le Male Elixir',
    'Jean Paul Gaultier',
    0, NULL::integer, FALSE,
    'nocturnos', 'Parfum Elixir', '125 ml',
    'Miel Dorada, Tabaco, Vainilla, Habas Tonka, Lavanda y Menta',
    'Noche & Citas', '⚡', 'Tendencia', 5, 376,
    'Seductor, cálido y envolvente. Su fusión de miel dorada, tabaco y vainilla crea una estela irresistible en climas frescos y salidas nocturnas.',
    'https://images.unsplash.com/photo-1592945403244-b3fbafd7f539?auto=format&fit=crop&w=900&q=80',
    '[{"name": "75 ml"}, {"name": "125 ml"}]'::jsonb,
    TRUE
  ),
  (
    '9PM Rebel',
    'Afnan',
    0, NULL::integer, FALSE,
    'arabes', 'Eau de Parfum (EDP)', '100 ml',
    'Manzana Verde, Canela, Lavanda, Vainilla Negra, Ámbar y Pachulí',
    'Noche & Citas', '🌙', 'Best Seller', 5, 295,
    'Potencia nocturna con proyección explosiva. Ideal para fiestas, citas y hombres que buscan destacar desde el primer minuto.',
    'https://images.unsplash.com/photo-1615634260167-c8cdede054de?auto=format&fit=crop&w=900&q=80',
    '[{"name": "100 ml Sellado"}]'::jsonb,
    FALSE
  ),
  (
    'Acqua Di Giò Parfum',
    'Giorgio Armani',
    0, NULL::integer, FALSE,
    'frescos', 'Parfum', '100 ml',
    'Notas Marinas, Bergamota de Calabria, Romero, Incienso y Pachulí',
    'Fresco Diario', '🌊', 'Fresco Intenso', 5, 264,
    'Frescura oceánica con fondo de incienso mineral. Sofisticado para el día a día, clima cálido y oficina.',
    'https://images.unsplash.com/photo-1541643600914-78b084683601?auto=format&fit=crop&w=900&q=80',
    '[{"name": "75 ml"}, {"name": "125 ml"}]'::jsonb,
    FALSE
  ),
  (
    'Club de Nuit Intense Limited Edition',
    'Armaf',
    0, NULL::integer, FALSE,
    'arabes', 'Parfum Limited Edition', '105 ml',
    'Limón, Piña, Bergamota, Abedul, Jazmín, Almizcle y Ámbar Gris',
    'Oficina & Poder', '🖤', 'Edición Limitada', 5, 610,
    'La versión Parfum más refinada y potente de Armaf. Estela imponente de cítricos ahumados y maderas nobles.',
    'assets/perfumes/cdn-intense-man.jpg',
    '[{"name": "105 ml Parfum"}]'::jsonb,
    TRUE
  ),
  (
    'Club de Nuit Blue Iconic',
    'Armaf',
    0, NULL::integer, FALSE,
    'caballero', 'Eau de Parfum (EDP)', '105 ml',
    'Pomelo, Menta, Limón, Jengibre, Incienso, Cedro y Sándalo',
    'Oficina & Poder', '💎', 'Elegancia Azul', 5, 320,
    'Fresco, cítrico e inciensado. Sofisticación versátil para el día a día y negocios.',
    'assets/perfumes/cdn-iconic.jpg',
    '[{"name": "105 ml Sellado"}]'::jsonb,
    TRUE
  ),
  (
    'Club de Nuit Sillage',
    'Armaf',
    0, NULL::integer, FALSE,
    'caballero', 'Eau de Parfum (EDP)', '105 ml',
    'Bergamota, Grosella Negra, Hojas de Violeta, Iris, Ambroxan y Almizcle',
    'Fresco Diario', '🌊', 'Fresco Metálico', 5, 275,
    'Frescura limpia, ozónica y magnética de altísima fijación para destacar en cualquier clima.',
    'assets/perfumes/cdn-sillage.jpg',
    '[{"name": "105 ml Sellado"}]'::jsonb,
    FALSE
  ),
  (
    'Club de Nuit Untold',
    'Armaf',
    0, NULL::integer, FALSE,
    'nicho', 'Eau de Parfum (EDP)', '105 ml',
    'Azafrán, Jazmín, Amberwood, Ámbar Gris, Resina de Abeto y Cedro',
    'Eventos VIP', '🔥', 'Estela Bestia', 5, 410,
    'Acorde lujoso de azafrán y ámbar cristalino con una proyección envolvente e inolvidable.',
    'assets/perfumes/cdn-untold.jpg',
    '[{"name": "105 ml Sellado"}]'::jsonb,
    TRUE
  ),
  (
    'Royal Amber',
    'Orientica',
    0, NULL::integer, FALSE,
    'nicho', 'Luxury Collection EDP', '80 ml / 150 ml',
    'Bergamota, Notas Dulces, Melón, Ámbar, Vainilla y Maderas Preciosas',
    'Eventos VIP', '👑', 'Alta Perfumería', 5, 390,
    'Joya de alta perfumería árabe nicho con duración extrema de más de 14 horas en piel.',
    'assets/perfumes/orientica-royal-amber.jpg',
    '[{"name": "80 ml Sellado"}, {"name": "150 ml Sellado"}]'::jsonb,
    TRUE
  ),
  (
    'Amber Rouge',
    'Orientica',
    0, NULL::integer, FALSE,
    'nicho', 'Luxury Collection EDP', '80 ml',
    'Azafrán, Jazmín, Madera de Ámbar, Cedro y Resina de Abeto',
    'Noche & Citas', '💎', 'Lujo Árabe', 5, 280,
    'Cálido, seductor y opulento. Un elixir de azafrán y maderas ambaradas para ocasiones especiales.',
    'assets/perfumes/orientica-amber-rouge.jpg',
    '[{"name": "80 ml Sellado"}]'::jsonb,
    FALSE
  ),
  (
    'Oud Saffron',
    'Orientica',
    0, NULL::integer, FALSE,
    'nicho', 'Luxury Collection EDP', '80 ml',
    'Notas Orientales, Vainilla, Azafrán, Madera de Oud, Pachulí y Almizcle',
    'Noche & Citas', '🎩', 'Oud Imperial', 5, 245,
    'Imponente fusión de madera de Oud y azafrán especiado con fondo avainillado magnético.',
    'assets/perfumes/orientica-oud-saffron.png',
    '[{"name": "80 ml Sellado"}]'::jsonb,
    FALSE
  ),
  (
    'Yara Tous',
    'Lattafa',
    0, NULL::integer, FALSE,
    'dama', 'Eau de Parfum (EDP)', '100 ml',
    'Mango, Coco, Maracuyá, Jazmín, Flor de Azahar, Vainilla y Almizcle',
    'Fresco Diario', '👑', 'Favorito Dama', 5, 460,
    'Aroma tropical, cremoso y luminoso con notas de mango, flores blancas y vainilla suave.',
    'assets/perfumes/lattafa-yara-tous.jpg',
    '[{"name": "100 ml Sellado"}]'::jsonb,
    TRUE
  ),
  (
    'Yara Elixir',
    'Lattafa',
    0, NULL::integer, FALSE,
    'dama', 'Elixir EDP', '100 ml',
    'Frutos Rojos, Orquídea, Vainilla Cremosa, Sándalo y Almizcle Dulce',
    'Noche & Citas', '🌸', 'Dulce Seductor', 5, 385,
    'Dulce, envolvente y femenino. Una estela adictiva y elegante que roba miradas.',
    'assets/perfumes/lattafa-yara-elixir.jpg',
    '[{"name": "100 ml Sellado"}]'::jsonb,
    FALSE
  ),
  (
    'Club de Nuit Woman',
    'Armaf',
    0, NULL::integer, FALSE,
    'dama', 'Eau de Parfum (EDP)', '105 ml',
    'Bergamota, Pomelo, Durazno, Rosa, Jazmín, Pachulí, Vainilla y Almizcle',
    'Eventos VIP', '👑', 'Elegancia Dama', 5, 340,
    'Sofisticación floral-frutal con fondo de pachulí y vainilla de gran proyección.',
    'assets/perfumes/cdn-woman.jpg',
    '[{"name": "105 ml Sellado"}]'::jsonb,
    FALSE
  ),
  (
    'Club de Nuit Urban Man Elixir',
    'Armaf',
    0, NULL::integer, FALSE,
    'caballero', 'Eau de Parfum Elixir', '105 ml',
    'Bergamota, Pimienta Rosa, Lavanda, Ambroxan, Pachulí y Vetiver',
    'Noche & Citas', '🔥', 'Modo Bestia', 5, 395,
    'Fusión explosiva de frescura especiada y ambroxan magnético con duración extrema.',
    'assets/perfumes/cdn-elite.jpg',
    '[{"name": "105 ml Sellado"}]'::jsonb,
    TRUE
  ),
  (
    'Club de Nuit Overdose',
    'Armaf',
    0, NULL::integer, FALSE,
    'nicho', 'Parfum Intense', '105 ml',
    'Especias Cálidas, Notas Amaderadas, Ámbar Oscuro, Cuero y Resinas',
    'Noche & Citas', '🖤', 'Edición Exclusiva', 5, 260,
    'Aroma intenso, seductor y misterioso diseñado para dominar la noche.',
    'assets/perfumes/cdn-overdose.jpg',
    '[{"name": "105 ml Sellado"}]'::jsonb,
    FALSE
  ),
  (
    'Hawas Diva',
    'Rasasi',
    0, NULL::integer, FALSE,
    'dama', 'Eau de Parfum (EDP)', '100 ml',
    'Frutas Exóticas, Flores Blancas, Vainilla Ámbar y Almizcle Sensual',
    'Noche & Citas', '👑', 'Novedad VIP', 5, 310,
    'Femenino, audaz y envolvente con una estela dulce-floral de larga duración.',
    'assets/perfumes/hawas-diva.jpg',
    '[{"name": "100 ml Sellado"}]'::jsonb,
    TRUE
  ),
  (
    'Afeef',
    'Lattafa',
    0, NULL::integer, FALSE,
    'arabes', 'Eau de Parfum (EDP)', '100 ml',
    'Bergamota, Durazno, Pimienta Rosa, Jazmín, Flor de Azahar, Sándalo y Praliné',
    'Eventos VIP', '🕌', 'Joya Árabe', 5, 290,
    'Presentación de lujo con un aroma exquisito que combina notas frutales, florales y fondo cremoso de praliné.',
    'assets/perfumes/lattafa-afeef.jpg',
    '[{"name": "100 ml Sellado"}]'::jsonb,
    TRUE
  ),
  (
    'Victoria',
    'Lattafa',
    0, NULL::integer, FALSE,
    'dama', 'Eau de Parfum (EDP)', '100 ml',
    'Limón Confitado, Flor de Azahar, Vainilla Real y Almizcle Blanco',
    'Eventos VIP', '💎', 'Realeza Árabe', 5, 330,
    'Elegancia imperial con acordes cítricos dulces, flores blancas y vainilla adictiva.',
    'assets/perfumes/lattafa-victoria.jpg',
    '[{"name": "100 ml Sellado"}]'::jsonb,
    TRUE
  ),
  (
    'Rave Now Women',
    'Lattafa',
    0, NULL::integer, FALSE,
    'dama', 'Eau de Parfum (EDP)', '100 ml',
    'Frutos Rojos, Fresas, Malvavisco (Marshmallow), Vainilla y Almizcle',
    'Fresco Diario', '🌸', 'Tendencia', 5, 425,
    'Delicioso aroma frutal-gourmand de frutos rojos y malvavisco cremoso. Súper juvenil y halagado.',
    'assets/perfumes/rave-now-women.jpg',
    '[{"name": "100 ml Sellado"}]'::jsonb,
    FALSE
  ),
  (
    'Oud Wood',
    'Tom Ford',
    0, NULL::integer, FALSE,
    'nicho', 'Eau de Parfum (EDP)', '100 ml',
    'Madera de Oud, Palo de Rosa, Cardamomo, Sándalo, Vetiver y Ámbar',
    'Eventos VIP', '🎩', 'Alta Perfumería', 5, 198,
    'Misterioso, exótico y sumamente distinguido. Un aroma de maderas preciosas y especias cálidas para ocasiones de etiqueta.',
    'https://images.unsplash.com/photo-1588405748880-12d1d2a59f75?auto=format&fit=crop&w=900&q=80',
    '[{"name": "50 ml"}, {"name": "100 ml"}, {"name": "Decant 10 ml"}]'::jsonb,
    FALSE
  ),
  (
    'Born in Roma Uomo Intense',
    'Valentino',
    0, NULL::integer, FALSE,
    'nocturnos', 'Eau de Parfum Intense', '100 ml',
    'Vainilla Bourbon, Lavandín Aromático y Vetiver Ahumado',
    'Noche & Citas', '⚡', 'Nuevo', 5, 215,
    'Carismático, moderno y magnético. Una combinación vibrante entre frescura aromática y vainilla oscura.',
    'https://images.unsplash.com/photo-1563170351-be82bc888aa4?auto=format&fit=crop&w=900&q=80',
    '[{"name": "100 ml Sellado"}]'::jsonb,
    FALSE
  )
) AS v(name, brand, price, old_price, show_price, category, concentration, size_ml, notes, occasion, emoji, badge, stars, reviews, description, image_url, variants, featured)
WHERE NOT EXISTS (
  SELECT 1 FROM products p WHERE LOWER(TRIM(p.name)) = LOWER(TRIM(v.name))
);

-- Actualizar foto local si Club de Nuit Intense ya existía con imagen genérica
UPDATE products
SET image_url = 'assets/perfumes/cdn-intense-man.jpg'
WHERE LOWER(name) LIKE 'club de nuit intense%'
  AND (image_url IS NULL OR image_url LIKE 'https://images.unsplash.com%');
