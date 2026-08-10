-- CaKoBean demo data. Idempotent — safe to re-run (rows that already exist
-- are left untouched, so manual edits like role changes survive re-seeds).
-- Run after schema.sql.

-- ── Demo users (fixed ids; not auth accounts, just profiles for demo content)

insert into public.users (id, first_name, middle_name, last_name, username, email, avatar_url)
values
  ('00000000-0000-0000-0000-000000000001', 'Demo', NULL, 'Farmer', 'demo', 'demo@cakobean.app', NULL),
  ('00000000-0000-0000-0000-000000000002', 'Rosario', 'Lumaban', 'Domingo', 'rosario', 'rosario@cakobean.app', NULL),
  ('00000000-0000-0000-0000-000000000003', 'Ben', NULL, 'Tugon', 'ben', 'ben@cakobean.app', NULL),
  ('00000000-0000-0000-0000-000000000004', 'Marites', 'Santos', 'Aquino', 'marites', 'marites@cakobean.app', NULL),
  ('00000000-0000-0000-0000-000000000005', 'Junjun', NULL, 'Panganiban', 'junjun', 'junjun@cakobean.app', NULL)
on conflict (id) do nothing;

-- ── Demo articles

insert into public.articles
  (id, title, description, image_url, media_urls, tags, author_id, created_at)
values
  (
    '00000000-0000-0000-0000-000000000101',
    'Shade Tree Management for Sustainable Cacao Farming',
    'How intercropping with native shade trees improves soil health, '
    'moderates temperature swings, and boosts long-term yield stability. '
    'Farmers who paired their cacao rows with native canopy species '
    'reported steadier pod development through dry-season stretches, '
    'and the leaf litter buildup measurably improved topsoil retention '
    'over a single growing cycle.',
    'https://picsum.photos/seed/cacao1/200/200',
    array['https://picsum.photos/seed/cacao1/800/600','https://picsum.photos/seed/cacao1b/800/600','https://picsum.photos/seed/cacao1c/800/600'],
    array['regenerative','cultivation','weather','guides'],
    '00000000-0000-0000-0000-000000000002',
    '2026-08-01 09:00:00+00'
  ),
  (
    '00000000-0000-0000-0000-000000000102',
    'How to Identify and Treat Pod Borer in Cacao',
    'Early warning signs of pod borer infestation and the integrated '
    'pest management steps that keep your pods safe. This guide covers '
    'trap placement, natural predator support, and when a targeted '
    'spray is actually warranted versus when it does more harm than good.',
    'https://picsum.photos/seed/cacao2/200/200',
    array['https://picsum.photos/seed/cacao2/800/600','https://picsum.photos/seed/cacao2b/800/600'],
    array['pests','diseases','guides'],
    '00000000-0000-0000-0000-000000000005',
    '2026-07-30 08:00:00+00'
  ),
  (
    '00000000-0000-0000-0000-000000000103',
    'Post-Harvest Fermentation Techniques',
    'A step-by-step look at fermentation timing and turning frequency '
    'to develop the flavor precursors buyers pay a premium for. '
    'Watch the video to see the correct heap structure in action.',
    'https://picsum.photos/seed/cacao3/200/200',
    array['https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4','https://picsum.photos/seed/cacao3/800/600'],
    array['harvest','guides','nutrition'],
    '00000000-0000-0000-0000-000000000004',
    '2026-07-29 08:00:00+00'
  ),
  (
    '00000000-0000-0000-0000-000000000104',
    'Improving Yield with Proper Pruning',
    'Formative and maintenance pruning schedules that open up the '
    'canopy for light and airflow without stressing mature trees.',
    'https://picsum.photos/seed/cacao4/200/200',
    array['https://picsum.photos/seed/cacao4/800/600'],
    array['cultivation','regenerative','guides'],
    '00000000-0000-0000-0000-000000000003',
    '2026-07-28 08:00:00+00'
  ),
  (
    '00000000-0000-0000-0000-000000000105',
    'Recognizing Black Pod Disease Before It Spreads',
    'What early lesions look like, why humidity accelerates spread, '
    'and the sanitation routine that limits an outbreak.',
    'https://picsum.photos/seed/cacao5/200/200',
    array['https://picsum.photos/seed/cacao5/800/600','https://picsum.photos/seed/cacao5b/800/600'],
    array['diseases','weather','pests','guides'],
    '00000000-0000-0000-0000-000000000002',
    '2026-07-27 08:00:00+00'
  ),
  (
    '00000000-0000-0000-0000-000000000106',
    'Reading Wet-Season Forecasts for Spray Scheduling',
    'Why timing fungicide applications around rainfall windows matters '
    'more than the calendar, and how to plan around it. '
    'Includes a short walkthrough of reading the Doppler map.',
    'https://picsum.photos/seed/cacao6/200/200',
    array['https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4','https://picsum.photos/seed/cacao6/800/600','https://picsum.photos/seed/cacao6b/800/600'],
    array['weather','diseases'],
    '00000000-0000-0000-0000-000000000004',
    '2026-07-26 08:00:00+00'
  ),
  (
    '00000000-0000-0000-0000-000000000107',
    'Balancing Soil Nutrients for Healthier Pods',
    'A practical breakdown of potassium and magnesium ratios and '
    'what deficiency symptoms show up on the leaves first.',
    'https://picsum.photos/seed/cacao7/200/200',
    array['https://picsum.photos/seed/cacao7/800/600'],
    array['nutrition','cultivation'],
    '00000000-0000-0000-0000-000000000003',
    '2026-07-25 08:00:00+00'
  ),
  (
    '00000000-0000-0000-0000-000000000108',
    'A Beginner''s Guide to Starting a Cacao Nursery',
    'Everything from seed selection to shade-cloth setup for growers '
    'raising their first batch of seedlings.',
    'https://picsum.photos/seed/cacao8/200/200',
    array['https://picsum.photos/seed/cacao8/800/600'],
    array['guides','cultivation'],
    '00000000-0000-0000-0000-000000000001',
    '2026-07-24 08:00:00+00'
  )
on conflict (id) do nothing;

-- ── Demo comments

insert into public.comments
  (id, article_id, author_id, text, posted_at)
values
  (
    '00000000-0000-0000-0000-000000000201',
    '00000000-0000-0000-0000-000000000101',
    '00000000-0000-0000-0000-000000000002',
    'Tried this on my 2-hectare plot last season, soil moisture held up way better than expected.',
    '2026-07-28 09:15:00+00'
  ),
  (
    '00000000-0000-0000-0000-000000000202',
    '00000000-0000-0000-0000-000000000101',
    '00000000-0000-0000-0000-000000000003',
    'What spacing did you use between the shade trees and the cacao rows?',
    '2026-07-28 14:40:00+00'
  ),
  (
    '00000000-0000-0000-0000-000000000203',
    '00000000-0000-0000-0000-000000000101',
    '00000000-0000-0000-0000-000000000004',
    'Great breakdown, sharing this with our cooperative.',
    '2026-07-29 08:02:00+00'
  ),
  (
    '00000000-0000-0000-0000-000000000204',
    '00000000-0000-0000-0000-000000000102',
    '00000000-0000-0000-0000-000000000005',
    'The pheromone trap tip alone saved half my crop this season.',
    '2026-07-27 18:05:00+00'
  )
on conflict (id) do nothing;

-- ── Demo likes (article_id, user_id)

insert into public.likes (article_id, user_id)
values
  ('00000000-0000-0000-0000-000000000101', '00000000-0000-0000-0000-000000000001'),
  ('00000000-0000-0000-0000-000000000101', '00000000-0000-0000-0000-000000000003'),
  ('00000000-0000-0000-0000-000000000101', '00000000-0000-0000-0000-000000000004'),
  ('00000000-0000-0000-0000-000000000101', '00000000-0000-0000-0000-000000000005'),
  ('00000000-0000-0000-0000-000000000102', '00000000-0000-0000-0000-000000000001'),
  ('00000000-0000-0000-0000-000000000102', '00000000-0000-0000-0000-000000000002'),
  ('00000000-0000-0000-0000-000000000102', '00000000-0000-0000-0000-000000000003'),
  ('00000000-0000-0000-0000-000000000102', '00000000-0000-0000-0000-000000000004'),
  ('00000000-0000-0000-0000-000000000102', '00000000-0000-0000-0000-000000000005'),
  ('00000000-0000-0000-0000-000000000103', '00000000-0000-0000-0000-000000000001'),
  ('00000000-0000-0000-0000-000000000103', '00000000-0000-0000-0000-000000000002'),
  ('00000000-0000-0000-0000-000000000104', '00000000-0000-0000-0000-000000000001'),
  ('00000000-0000-0000-0000-000000000104', '00000000-0000-0000-0000-000000000004'),
  ('00000000-0000-0000-0000-000000000105', '00000000-0000-0000-0000-000000000001'),
  ('00000000-0000-0000-0000-000000000105', '00000000-0000-0000-0000-000000000002'),
  ('00000000-0000-0000-0000-000000000105', '00000000-0000-0000-0000-000000000003'),
  ('00000000-0000-0000-0000-000000000105', '00000000-0000-0000-0000-000000000004'),
  ('00000000-0000-0000-0000-000000000105', '00000000-0000-0000-0000-000000000005'),
  ('00000000-0000-0000-0000-000000000106', '00000000-0000-0000-0000-000000000001'),
  ('00000000-0000-0000-0000-000000000106', '00000000-0000-0000-0000-000000000003'),
  ('00000000-0000-0000-0000-000000000107', '00000000-0000-0000-0000-000000000002'),
  ('00000000-0000-0000-0000-000000000108', '00000000-0000-0000-0000-000000000001'),
  ('00000000-0000-0000-0000-000000000108', '00000000-0000-0000-0000-000000000003'),
  ('00000000-0000-0000-0000-000000000108', '00000000-0000-0000-0000-000000000005')
on conflict (article_id, user_id) do nothing;
