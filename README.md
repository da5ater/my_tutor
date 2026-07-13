# MyTutor

MyTutor is a Rails learning marketplace demo with role-based course publishing,
enrollments, lesson progress, reviews, activity tracking, and an admin analytics
dashboard.

## Local setup

```sh
bin/setup
bin/rails server
```

Run the test suite with:

```sh
bin/rails test
```

## Portfolio demo data

The demo seed imports real public learning-path metadata from the
[Microsoft Learn Catalog API](https://learn.microsoft.com/en-us/training/support/catalog-api-developer-reference).
A learning path becomes a course and its modules become lessons. Every imported
description includes a link to the original Microsoft Learn material.

Users, instructors, marketplace prices, enrollments, reviews, progress, and
impressions are synthetic portfolio data. This keeps the analytics realistic
without using private user information or presenting demo purchases as real.

To replace the local database contents with the demo catalog:

```sh
DEMO_RESET=1 \
DEMO_ADMIN_PASSWORD='choose-a-local-password' \
DEMO_USER_PASSWORD='choose-another-local-password' \
bin/rails db:seed
```

The production seed refuses to run unless `DEMO_RESET=1` is explicitly set and
both passwords are provided as environment variables. Never commit production
credentials.
