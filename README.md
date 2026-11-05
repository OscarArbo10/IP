# 👑 Ilusion Perfumery – Tienda de Perfumes Masculinos

Sitio web y panel de administración para **Ilusion Perfumery**, diseñado en **Negro & Amarillo/Dorado (`#08080a` + `#f5c518`)**, 100% adaptable a móviles, conectado con **Supabase** y listo para desplegar en **Vercel** con **Git**.

---

## 📁 Estructura del Proyecto

- [`index.html`](./index.html) — Tienda principal dinámica (Hero con partículas doradas, filtro por ocasión y familia olfativa, vista rápida con notas olfativas, bolsa de consulta/pedido por WhatsApp, modalidades de entrega puerta a puerta y envíos).
- [`admin.html`](./admin.html) — Panel de administración completo (gestión de perfumes, interruptor de 1 clic para mostrar/ocultar precios individual o globalmente, subida de logo oficial, gestión de categorías, entregas y textos del sitio).
- [`login.html`](./login.html) — Acceso seguro de administrador con Supabase Auth y bloqueo temporal anti fuerza bruta.
- [`config.js`](./config.js) — Configuración de `SUPABASE_URL`, `SUPABASE_KEY`, número de WhatsApp y valores iniciales de la marca.
- [`supabase-setup.sql`](./supabase-setup.sql) — Script SQL todo-en-uno con tablas (`products`, `categories`, `site_settings`), políticas de seguridad RLS, bucket de Storage (`products`) y catálogo inicial masculino con precios ocultos por defecto.
- [`vercel.json`](./vercel.json) — Configuración de cabeceras de seguridad HTTP para Vercel.

---

## 🚀 Pasos para Configurar y Desplegar

### 1. Configurar la Base de Datos en Supabase
1. Crea un proyecto en [supabase.com](https://supabase.com).
2. Ve a **SQL Editor → New Query**, pega todo el contenido de [`supabase-setup.sql`](./supabase-setup.sql) y haz clic en **Run**.
3. Ve a **Authentication → Users → Add User → Create new user** y crea tu correo y contraseña de administrador.
4. En **Project Settings → API**, copia tu **Project URL** y tu clave pública **`anon` / `publishable`** y pégalas en [`config.js`](./config.js).

### 2. Subir a GitHub y Desplegar en Vercel
```bash
git init
git add .
git commit -m "Initial commit: Ilusion Perfumery"
git branch -M main
git remote add origin https://github.com/TU_USUARIO/ilusion-perfumery.git
git push -u origin main
```
Luego entra a [vercel.com](https://vercel.com), haz clic en **Add New → Project**, importa tu repositorio `ilusion-perfumery` y pulsa **Deploy**.
