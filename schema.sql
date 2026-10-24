-- Cafe website Supabase schema
-- Run in Supabase Dashboard > SQL Editor.
-- IMPORTANT: This schema stores each row's payload in `data` JSONB.
-- Authenticated owner users can manage cafe content. Public visitors can read public content.
-- Reservation submissions are public inserts; only authenticated owners can read/update them.
-- For production, add rate limiting / CAPTCHA to reservation submissions and review any policies.

create table if not exists public.menu_items (
  id text primary key,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);
create table if not exists public.reviews (
  id text primary key,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);
create table if not exists public.cafe_settings (
  id text primary key,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);
create table if not exists public.offers (
  id text primary key,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);
create table if not exists public.reservations (
  id text primary key,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.menu_items enable row level security;
alter table public.reviews enable row level security;
alter table public.cafe_settings enable row level security;
alter table public.offers enable row level security;
alter table public.reservations enable row level security;

-- Public read access for menu, published reviews, cafe info and offers.
drop policy if exists "Public can read menu" on public.menu_items;
create policy "Public can read menu" on public.menu_items for select to anon, authenticated using (true);
drop policy if exists "Owner manages menu" on public.menu_items;
create policy "Owner manages menu" on public.menu_items for all to authenticated using (true) with check (true);

drop policy if exists "Public can read reviews" on public.reviews;
create policy "Public can read reviews" on public.reviews for select to anon, authenticated using (true);
drop policy if exists "Owner manages reviews" on public.reviews;
create policy "Owner manages reviews" on public.reviews for all to authenticated using (true) with check (true);

drop policy if exists "Public can read cafe settings" on public.cafe_settings;
create policy "Public can read cafe settings" on public.cafe_settings for select to anon, authenticated using (true);
drop policy if exists "Owner manages cafe settings" on public.cafe_settings;
create policy "Owner manages cafe settings" on public.cafe_settings for all to authenticated using (true) with check (true);

drop policy if exists "Public can read offers" on public.offers;
create policy "Public can read offers" on public.offers for select to anon, authenticated using (true);
drop policy if exists "Owner manages offers" on public.offers;
create policy "Owner manages offers" on public.offers for all to authenticated using (true) with check (true);

-- Anyone can submit a reservation request. Public cannot read or update reservations.
drop policy if exists "Visitors can submit reservations" on public.reservations;
create policy "Visitors can submit reservations" on public.reservations for insert to anon, authenticated with check (true);
drop policy if exists "Owner reads reservations" on public.reservations;
create policy "Owner reads reservations" on public.reservations for select to authenticated using (true);
drop policy if exists "Owner updates reservations" on public.reservations;
create policy "Owner updates reservations" on public.reservations for update to authenticated using (true) with check (true);
drop policy if exists "Owner deletes reservations" on public.reservations;
create policy "Owner deletes reservations" on public.reservations for delete to authenticated using (true);

-- Recommended: create the owner account in Authentication > Users.
-- Restrict authenticated database access to owner accounts only in a production deployment.
-- These broad authenticated policies assume this Supabase project is dedicated to one cafe
-- and that public sign-ups are disabled. Disable public sign-ups in Auth settings.
