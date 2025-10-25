Deploying the admin proxy

This file contains short instructions for deploying the admin Node/Express proxy that holds your Supabase
service role key. Choose one of the providers below and follow the steps.

Render (recommended)
1. Push the `admin_server` folder (or repository root) to GitHub.
2. Create a new Web Service on Render and connect your repo/branch.
3. Build command: `npm install` (Render will run this automatically).
4. Start command: `node server.js`.
5. In the Render dashboard set the following environment variables:
   - `SUPABASE_URL` = https://<your-project>.supabase.co
   - `SUPABASE_SERVICE_ROLE_KEY` = <your service role key>
6. Deploy. Render will assign an HTTPS URL like `https://your-service.onrender.com`.

Fly / Railway / Docker
- These platforms support deploying the provided `Dockerfile`.
- Build and push the image from your CI or use platform UI and set the same environment variables.

Notes
- Keep the service role key secret. Do not commit `.env` to version control.
- Ensure CORS in `server.js` allows requests from your admin UI origin (Vercel) if needed.
