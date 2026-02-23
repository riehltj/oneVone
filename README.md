# One V One

Denver Pickleball league MVP: rating-based pools, zone + availability, challenge matches, report results, standings. Monthly Stripe subscription per pool.

## Setup

```bash
bundle install
rails db:migrate
rails db:seed
```

## Run

Server runs on **port 3001** (to avoid conflict with other projects).

```bash
rails s -p 3001
# or: PORT=3001 bin/dev
```

Open http://localhost:3001

## Optional: Stripe

Without Stripe keys, joining a pool creates membership directly (no payment). To enable payments:

- `STRIPE_SECRET_KEY` — Join flow redirects to Stripe Checkout; success callback creates membership + PaymentSubscription.
- `STRIPE_WEBHOOK_SECRET` — Webhook at `POST /stripe_webhook` for `customer.subscription.updated` / `customer.subscription.deleted` to keep subscription status in sync.

Create a Product and recurring Price in Stripe Dashboard, or the app uses dynamic `price_data` from each league's `monthly_price_cents`.

## Tests

```bash
rails db:test:prepare
rails test
```

Uses Minitest and SimpleCov. No stubbing: tests use the real test DB and real requests. Coverage is ~93%; to approach 100% you can set `STRIPE_SECRET_KEY` (and optionally run the optional Stripe path tests).
