Admin React upload UI (Supabase)
================================

This project contains a minimal React admin UI at `admin_server/react_admin` that uploads files to Supabase Storage and inserts metadata rows into a Supabase table named `content`.

Quick setup
-----------

1. Create a Supabase project at https://app.supabase.com
2. Create a storage bucket named `content` (make public or configure appropriate policies)
3. Create the `content` table. Example SQL:

```sql
create table public.content (
	id uuid default gen_random_uuid() primary key,
	title text,
	description text,
	url text,
	path text,
	mime_type text,
	size bigint,
	tags jsonb,
	created_at timestamptz default now()
);
```

4. Configure Row-Level Security (RLS) and policies if you plan to use anon keys. For a simple setup during development you can use a service role key in the admin app, but be careful — do not commit service-role keys to the repo.

Run the admin UI locally
------------------------

Open a terminal in `admin_server/react_admin` and run:

```powershell
npm install
npm run dev
```

Copy `.env.example` to `.env` (or set environment variables) and fill `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY`.

How it works
------------

- The React app uploads the selected file to the `content` bucket in Supabase Storage.
- After upload it obtains a public URL and inserts a metadata row into the `content` table with fields: title, description, url, path, mime_type, size, tags.
- The mobile app can fetch the content list using the Supabase client or REST API:

Example (JS):

```js
const { data, error } = await supabase.from('content').select('*').order('created_at', { ascending: false })
```

Security notes
--------------

- For production, prefer to use RLS policies and short-lived tokens rather than embedding a service role key in a client app.
- Make sure uploaded files are stored and served according to your privacy and CDN needs.

Next steps
----------
- Wire the mobile app to fetch from Supabase (Flutter example included in the repo next if desired).
- Add authentication for the admin UI (Supabase Auth or an external identity provider).

Admin proxy server (optional but recommended for secure inserts)
---------------------------------------------------------

If your Supabase project enforces Row-Level Security (RLS) the anon key used in the browser may not be allowed to INSERT rows into the `content` table. For a secure admin upload flow we provide a small local proxy server at `admin_server/server.js` which uses a SUPABASE_SERVICE_ROLE_KEY to insert metadata server-side.

1. Create a file `admin_server/.env` based on `.env.example` and set:

```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
```

2. Install and run the proxy server:

```powershell
cd "admin_server"
npm install
npm start
```

3. Keep the proxy running while using the admin UI. The React admin app will POST metadata to `http://localhost:3000/api/content-metadata` which the proxy will insert into the `content` table.

Server-side upload (recommended)
------------------------------

For a permanent and secure solution, the proxy also exposes a single endpoint which uploads files using the service role key and inserts metadata in one step:

- `POST /api/upload-file` — multipart/form-data with a `file` field and optional `title`, `description`, `tags` fields. The server uploads the file to the `content` bucket, inserts a metadata row into `content`, and returns the inserted row with `publicUrl`.

The React admin UI included in this repo is updated to call this endpoint by default. This keeps your service role key out of the browser and avoids RLS and client-side upload issues.

Security notes:
- The service role key grants elevated privileges; keep it on a secure server and do not commit it to source control.
- For production, run this proxy on a secure server or implement server-side logic inside a trusted environment (API server, serverless function, etc.).

