-- CaKoBean Supabase schema.
-- Run this in the Supabase SQL editor (or via the CLI). It is idempotent:
-- run it on a fresh project, or re-run after pulling newer revisions.

-- ── Tables ────────────────────────────────────────────────────────────────

-- Public user profiles. `id` mirrors the auth.users id for real accounts,
-- but there is deliberately NO foreign key to auth.users so demo users can
-- be seeded with arbitrary ids. The trigger below auto-creates a profile row
-- for every real sign-up.
create table if not exists public.users (
  id          uuid primary key,
  first_name  text not null default '',
  middle_name text,
  last_name   text not null default '',
  email       text not null,
  avatar_url  text not null default 'https://i.pravatar.cc/100?img=68',
  role        text not null default 'farmer',
  created_at  timestamptz not null default now(),
  unique (email)
);

-- Add the column to databases created before middle_name existed.
alter table public.users add column if not exists middle_name text;

create table if not exists public.articles (
  id          uuid primary key default gen_random_uuid(),
  title       text not null,
  description text not null default '',
  image_url   text not null default '',
  media_urls  text[] not null default '{}',
  tags        text[] not null default '{}',
  author_id   uuid references public.users (id) on delete set null,
  created_at  timestamptz not null default now()
);

create table if not exists public.comments (
  id          uuid primary key default gen_random_uuid(),
  article_id  uuid not null references public.articles (id) on delete cascade,
  author_id   uuid references public.users (id) on delete set null,
  author_name text not null default 'Guest',
  avatar_url  text not null default 'https://i.pravatar.cc/100?img=68',
  text        text not null,
  posted_at   timestamptz not null default now()
);
create index if not exists comments_article_id_idx on public.comments (article_id);

-- One row per (article, user) like; the row's existence IS the like.
create table if not exists public.likes (
  article_id uuid not null references public.articles (id) on delete cascade,
  user_id    uuid references public.users (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (article_id, user_id)
);

create table if not exists public.farms (
  id             uuid primary key default gen_random_uuid(),
  owner_id       uuid references public.users (id) on delete cascade,
  address        text not null default '',
  size_hectares  double precision not null default 0,
  latitude       double precision,
  longitude      double precision,
  created_at     timestamptz not null default now()
);
create index if not exists farms_owner_id_idx on public.farms (owner_id);

create table if not exists public.trees (
  id         uuid primary key default gen_random_uuid(),
  farm_id    uuid not null references public.farms (id) on delete cascade,
  name       text not null default 'Cacao tree',
  variety    text,
  planted_on date,
  status     text not null default 'healthy',
  created_at timestamptz not null default now()
);
create index if not exists trees_farm_id_idx on public.trees (farm_id);

-- Auto-create a profile row for a new auth user, but ONLY once their email
-- is confirmed. Abandoned sign-ups (never verified) leave no row in `users`.
-- Fires on insert (already-confirmed users, e.g. admin-created) and when
-- `email_confirmed_at` is set during OTP verification.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.email_confirmed_at is null then
    return new;
  end if;
  insert into public.users (id, first_name, middle_name, last_name, email, avatar_url)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'first_name', ''),
    nullif(new.raw_user_meta_data ->> 'middle_name', ''),
    coalesce(new.raw_user_meta_data ->> 'last_name', ''),
    coalesce(new.email, ''),
    coalesce(
      new.raw_user_meta_data ->> 'avatar_url',
      'https://i.pravatar.cc/100?img=68'
    )
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- The profile appears at the moment the OTP is verified (email_confirmed_at
-- transitions from null to a timestamp), not at sign-up.
drop trigger if exists on_auth_user_email_confirmed on auth.users;
create trigger on_auth_user_email_confirmed
  after update of email_confirmed_at on auth.users
  for each row execute procedure public.handle_new_user();

-- ── Profile integrity guard ───────────────────────────────────────────────
-- Stops client apps (stale builds, or a hand-crafted REST call) from wiping
-- manually-maintained profile data:
--   * `role` may only be changed by an admin (service role / SQL editor);
--     a client upsert that sneaks in `role = 'farmer'` is silently ignored.
--   * an existing non-empty column is never nulled out (e.g. a login sync
--     that derives `middle_name` as null can't blank a dashboard-set name).
-- PostgREST sets `request.jwt.claims` per request; when it's absent (SQL
-- editor / direct DB access) the call is treated as an admin.

create or replace function public.guard_user_profile()
returns trigger
language plpgsql
as $$
declare
  v_jwt_role text := coalesce(
    current_setting('request.jwt.claims', true)::jsonb ->> 'role',
    'service_role'
  );
begin
  if v_jwt_role <> 'service_role' then
    new.role := old.role;
  end if;

  if nullif(new.first_name, '') is null and nullif(old.first_name, '') is not null then
    new.first_name := old.first_name;
  end if;
  if nullif(new.middle_name, '') is null and nullif(old.middle_name, '') is not null then
    new.middle_name := old.middle_name;
  end if;
  if nullif(new.last_name, '') is null and nullif(old.last_name, '') is not null then
    new.last_name := old.last_name;
  end if;
  if nullif(new.avatar_url, '') is null and nullif(old.avatar_url, '') is not null then
    new.avatar_url := old.avatar_url;
  end if;
  if nullif(new.email, '') is null and nullif(old.email, '') is not null then
    new.email := old.email;
  end if;

  return new;
end;
$$;

drop trigger if exists guard_user_profile on public.users;
create trigger guard_user_profile
  before update on public.users
  for each row execute procedure public.guard_user_profile();

-- ── Grants ────────────────────────────────────────────────────────────────
-- Restore the privileges Supabase ships by default. If the `public` schema is
-- ever dropped/recreated without these, every PostgREST call fails with
-- "permission denied for schema public" (a 42501/401) even though the API key
-- is valid. RLS policies still restrict row access below these grants.

grant usage on schema public to postgres, anon, authenticated, service_role;

grant all privileges on all tables in schema public to postgres, anon, authenticated, service_role;
grant all privileges on all sequences in schema public to postgres, anon, authenticated, service_role;
grant all privileges on all routines in schema public to postgres, anon, authenticated, service_role;

alter default privileges in schema public
  grant all privileges on tables to postgres, anon, authenticated, service_role;
alter default privileges in schema public
  grant all privileges on sequences to postgres, anon, authenticated, service_role;
alter default privileges in schema public
  grant all privileges on routines to postgres, anon, authenticated, service_role;

-- ── Row Level Security ────────────────────────────────────────────────────

alter table public.users    enable row level security;
alter table public.articles enable row level security;
alter table public.comments enable row level security;
alter table public.likes    enable row level security;
alter table public.farms    enable row level security;
alter table public.trees    enable row level security;

drop policy if exists "users select" on public.users;
drop policy if exists "users insert" on public.users;
drop policy if exists "users update" on public.users;
drop policy if exists "articles select" on public.articles;
drop policy if exists "articles insert" on public.articles;
drop policy if exists "comments select" on public.comments;
drop policy if exists "comments insert" on public.comments;
drop policy if exists "likes select" on public.likes;
drop policy if exists "likes insert" on public.likes;
drop policy if exists "likes delete" on public.likes;
drop policy if exists "farms select" on public.farms;
drop policy if exists "farms panuluyan read" on public.farms;
drop policy if exists "farms insert" on public.farms;
drop policy if exists "farms update" on public.farms;
drop policy if exists "farms delete" on public.farms;
drop policy if exists "trees select" on public.trees;
drop policy if exists "trees panuluyan read" on public.trees;
drop policy if exists "trees insert" on public.trees;
drop policy if exists "trees update" on public.trees;
drop policy if exists "trees delete" on public.trees;

-- Any signed-in user can read hub content and profiles (used to resolve
-- article/comment authors).
create policy "users select" on public.users
  for select to authenticated using (true);
create policy "articles select" on public.articles
  for select to authenticated using (true);
create policy "comments select" on public.comments
  for select to authenticated using (true);
create policy "likes select" on public.likes
  for select to authenticated using (true);

-- A user may write only their own profile.
create policy "users insert" on public.users
  for insert to authenticated
  with check (id = auth.uid());
create policy "users update" on public.users
  for update to authenticated
  using (id = auth.uid());

-- Only `panuluyan` role holders may publish articles (role set manually in
-- the table editor; the app's role field is never writable by clients).
create policy "articles insert" on public.articles
  for insert to authenticated
  with check (
    author_id = auth.uid() and
    exists (
      select 1 from public.users u
      where u.id = auth.uid() and u.role = 'panuluyan'
    )
  );

create policy "comments insert" on public.comments
  for insert to authenticated
  with check (author_id = auth.uid());

create policy "likes insert" on public.likes
  for insert to authenticated
  with check (user_id = auth.uid());
create policy "likes delete" on public.likes
  for delete to authenticated
  using (user_id = auth.uid());

-- Farms are private to their owner, but `panuluyan` monitors every farm in
-- read-only mode (no insert/update/delete — those stay owner-scoped above).
create policy "farms select" on public.farms
  for select to authenticated using (owner_id = auth.uid());
create policy "farms panuluyan read" on public.farms
  for select to authenticated
  using (
    exists (
      select 1 from public.users u
      where u.id = auth.uid() and u.role = 'panuluyan'
    )
  );
create policy "farms insert" on public.farms
  for insert to authenticated with check (owner_id = auth.uid());
create policy "farms update" on public.farms
  for update to authenticated using (owner_id = auth.uid());
create policy "farms delete" on public.farms
  for delete to authenticated using (owner_id = auth.uid());

create policy "trees select" on public.trees
  for select to authenticated
  using (
    exists (
      select 1 from public.farms f
      where f.id = trees.farm_id and f.owner_id = auth.uid()
    )
  );
create policy "trees panuluyan read" on public.trees
  for select to authenticated
  using (
    exists (
      select 1 from public.users u
      where u.id = auth.uid() and u.role = 'panuluyan'
    )
  );
create policy "trees insert" on public.trees
  for insert to authenticated
  with check (
    exists (
      select 1 from public.farms f
      where f.id = trees.farm_id and f.owner_id = auth.uid()
    )
  );
create policy "trees update" on public.trees
  for update to authenticated
  using (
    exists (
      select 1 from public.farms f
      where f.id = trees.farm_id and f.owner_id = auth.uid()
    )
  );
create policy "trees delete" on public.trees
  for delete to authenticated
  using (
    exists (
      select 1 from public.farms f
      where f.id = trees.farm_id and f.owner_id = auth.uid()
    )
  );

-- ── Realtime ───────────────────────────────────────────────────────────────
-- The app streams lists via PostgREST `.stream()` and re-fetches singles/
-- counts on change, so every table it listens to must be in the realtime
-- publication.

alter publication supabase_realtime add table public.users;
alter publication supabase_realtime add table public.articles;
alter publication supabase_realtime add table public.comments;
alter publication supabase_realtime add table public.likes;
alter publication supabase_realtime add table public.farms;
alter publication supabase_realtime add table public.trees;

-- ── Storage ───────────────────────────────────────────────────────────────
-- Public `media` bucket for article photos/videos. Objects are keyed
-- `{uid}/{timestamp}_{name}`; RLS below ties uploads to the caller's own
-- folder.

insert into storage.buckets (id, name, public)
values ('media', 'media', true)
on conflict (id) do nothing;

drop policy if exists "media public read" on storage.objects;
drop policy if exists "media authenticated upload" on storage.objects;
drop policy if exists "media owner update" on storage.objects;
drop policy if exists "media owner delete" on storage.objects;

create policy "media public read" on storage.objects
  for select using (bucket_id = 'media');

create policy "media authenticated upload" on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'media' and
    (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "media owner update" on storage.objects
  for update to authenticated
  using (
    bucket_id = 'media' and
    (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "media owner delete" on storage.objects
  for delete to authenticated
  using (
    bucket_id = 'media' and
    (storage.foldername(name))[1] = auth.uid()::text
  );
