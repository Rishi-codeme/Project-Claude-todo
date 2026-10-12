-- Run this once in Supabase: SQL Editor > New query > paste > Run

create table public.tasks (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null default auth.uid() references auth.users(id) on delete cascade,
  text       text not null check (char_length(text) between 1 and 200),
  done       boolean not null default false,
  priority   smallint not null default 0 check (priority between 0 and 2),
  created_at timestamptz not null default now()
);

create index tasks_user_created_idx on public.tasks (user_id, created_at desc);

-- Row Level Security: each user can only touch their own rows
alter table public.tasks enable row level security;

create policy "Read own tasks"   on public.tasks for select to authenticated using ((select auth.uid()) = user_id);
create policy "Insert own tasks" on public.tasks for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "Update own tasks" on public.tasks for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "Delete own tasks" on public.tasks for delete to authenticated using ((select auth.uid()) = user_id);


-- For an existing project that already has the tasks table.
-- Run once in Supabase: SQL Editor > New query > paste > Run
-- (priority already exists: 0 = low, 1 = medium, 2 = high)

alter table public.tasks_todo
  add column if not exists severity smallint not null default 0
  check (severity between 0 and 2);   -- 0 low, 1 medium, 2 high

-- Existing Row Level Security policies already cover the new column.