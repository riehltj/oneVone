# Pre-deploy checklist

## Must fix before first deploy

### 1. Set production env vars (e.g. in `.kamal/secrets` or your host)
- **`APP_HOST`**: Your public domain (e.g. `app.yourdomain.com`). Used for mailer links and should match Host authorization.
- **`MAILER_FROM`**: From address for all email (e.g. `noreply@yourdomain.com`). Used by Devise and MatchMailer so password reset and challenge emails don’t bounce or get marked spam.

### 2. Host authorization
- In **`config/environments/production.rb`**, uncomment and set `config.hosts` to your domain(s) so Rails rejects bad Host headers. Example: `config.hosts << "app.yourdomain.com"` or use the same value as `APP_HOST`.

### 3. SSL (if using Kamal proxy with Let’s Encrypt)
- **`config/environments/production.rb`**: Uncomment `config.assume_ssl = true` and `config.force_ssl = true` so cookies and redirects use HTTPS.

### 4. Stripe (if you take payments)
- Set **`STRIPE_SECRET_KEY`** and **`STRIPE_WEBHOOK_SECRET`** in production (e.g. `.kamal/secrets`). Without the webhook secret, subscription events won’t be verified (controller allows unsigned events when secret is blank).
- Point Stripe Dashboard webhook URL to `https://yourdomain.com/stripe_webhook`.

---

## Configure for production (optional but recommended)

### Email delivery
- Production does **not** configure SMTP (commented out). Either:
  - Uncomment and set `config.action_mailer.smtp_settings` (e.g. from credentials), or
  - Use a provider (SendGrid, Postmark, etc.) and set `delivery_method` + their config.
- Without this, challenge/accept/reminder and Devise emails won’t be sent in production.

### Database
- App uses **SQLite** in production (Kamal volume `one_vone_storage`). Fine for low traffic; for multiple servers or higher concurrency, switch to Postgres and point `config/database.yml` production to it (and run Solid Queue/cache/cable on the same or dedicated DB as needed).

### Seeds
- **Do not** run `rails db:seed` in production by default. Seeds create example users (e.g. alice@example.com / password123). If you ever seed prod, use a separate task and real data.

### Deploy target
- **`config/deploy.yml`**: `servers.web` is `192.168.0.1` and registry `localhost:5555`. Replace with your real server(s) and registry before running Kamal.

---

## Already in good shape

- **Flash messages**: Alert/notice use controller-set strings (no user input), so no XSS from flash.
- **Stripe redirect**: `redirect_to session.url, allow_other_host: true` is correct for Stripe Checkout.
- **Parameter filtering**: `filter_parameter_logging` redacts password, token, etc.
- **404/500**: `public/404.html` and `public/500.html` exist.
- **Health check**: `/up` for load balancers.
- **Solid Queue**: Runs in Puma (`SOLID_QUEUE_IN_PUMA: true`) so reminder emails are processed.
