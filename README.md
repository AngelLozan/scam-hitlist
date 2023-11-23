# Scam Hitlist v3

![Spam Banned Icon](https://github.com/AngelLozan/scam-hitlist/blob/main/app/assets/images/ban.png?raw=true)

An app to improve and streamline the brand protection program with both a database and user authentication.

Report IOCs and track their progress. Use a systematic approach to submitting and tracking IOCs with multiple API integrations.

Quicker and more efficient than using spreadsheets and allows for more efficient tooling.

Allows for unauthorized users to submit IOCs in a limited fashion, laying foundation for broader brand protection program across departments and ecosystem. Allows for evidence attachment and tracking. Allows for multiple users to work on the same IOC.

## Version History 🥲 => 😊

v3 here: https://scam-hitlist-d.ot.exodus.com/

See v2 here: https://docs.google.com/spreadsheets/d/1FyhDyRa8tjQvUSRn8BjviR0g9x7BU3nfmK73njYPyu4/edit?pli=1#gid=0

see v1 here: https://docs.google.com/spreadsheets/d/1Zd-47ml3BH3ma23JPC4SC-peafXgJSjXKpi8kHvNPzY/edit#gid=1387966833


## Setup

In the `Gemfile.lock`, make sure to add `x86_64-linux` to the `Platforms` section to run with GHA

run `bundle install` to install dependencies
run `rails db:drop db:create db:migrate db:seed` to create database and seed with data

Configure IAM keys for S3 bucket in `config/credentials.yml.enc` by using the terminal. If no editor is specified, use `EDITOR="nano" rails credentials:edit` to edit and encrypt keys. 


## To run in development

Change `config/database.yml` values in development to comment out the env-passed vars and uncomment database name `scam-hitlist-development`

Run `dev` to start server & run JS

If failing to see various features in front end, use `rails assets:precompile` to compile assets before running `dev`.


## Database setup

After seeding the database, you may need to manually find the next ID and set it in the rails console:

```
highest_id = Ioc.maximum(:id)

&&

next_available_id = highest_id + 1

ActiveRecord::Base.connection.execute("SELECT setval('iocs_id_seq', #{next_available_id}, false)")
```

## Base Security Features

- Utilizes presigned AWS S3 bucket upload and download urls for attaching evidence to records. No files touch server ✅
- Model Validations
- Uses built in methods to sanitize and remove xss attacks from form inputs (comments and url fields)
- Strong parameters
- CSRF meta tags used
- Strong Hash algorithm for cookies signatures (SHA-256)
- No open-uri use, no Marshal, no multiline, no use of html_safe, raw.
- Omniauth with limited users (2) and google enterprise account.
- Limiting routes
- Automated security check with bundler audit for dependencies, brakeman for code review and OSWAP dependency check. 

Alternatively run `dependency-check --out . --scan .` to run the dependency check and `bundle audit` for the gems. 

## Docker

Don't forget to reset highest IOC as explained in `Database Setup`. Important if you've seeded the Database as planned here. 

View on localhost:3000 or 8080 depending on port chosen for captcha and oauth with docker compose. Separate from the build process below. 

`docker-compose build` & `docker-compose up`

Else, use this to build and push to docker hub and similar instructions on aws. 

- Build

`docker-compose build`

(for production): `docker-compose build --build-arg RAILS_MASTER_KEY="$(cat config/master.key)"`


or

`docker build -t scottlozano/scam-hitlist:latest .`

- Test locally

`docker-compose up`

(Don't forget to change `config/database.yml` for development as explained above)

or

`docker run -p 3000:3000 scottlozano/scam-hitlist:latest`


- Push 

`docker push scottlozano/scam-hitlist:latest`

(First, you may need to tag the repo build with `docker-compose build` with `docker tag docker.io/<name> scottlozano/scam-hitlist:latest`)

- Access the console

`docker container ps ` -> Find container

`docker exec -it <container ID> bin/rails c ` or `docker exec -it <container ID> /bin/sh` for Alpine then `rails c` 

- You will need to run `rails db:migrate db:seed` & see Database setup step above. 

## Minikube (local kubernetes cluster)

Test with `minikube` and run a local cluster

- Build image and name it in the `k8s/scam-hitlist-deployment.yaml`
- Store secrets bas64 encoded in file `k8s/db-secret.yaml`
  + `bundle exec rake secret` (rails secret)
  + After above, run `echo -n "<secret here>" | base64`
- Start a postgres container, use a service like elephantsql (used here) or RDS on AWS as a database. Encode these secrets in the same yaml file and set them in the deployment.
- Ensure naming convention and secrets are referenced properly in the `config/database.yml`
- Start minikube with `minikube start`
- Run:
  + `kubectly apply -f k8s/db-secret.yaml`
  + `kubectly apply -f k8s/scam-hitlist-deployment.yaml`
  + `kubectly apply -f k8s/scam-hitlist-service.yaml`
- Commands to check on status of pods, deployments, services, secrets, jobs, ect.:
  + `kubectl get services,deployments,secrets,pods` (check status and get basic info)
  + `kubectl logs -f <pod>` (log continuously)
  + `kubectl delete <pods,secrets,deployments,services,jobs> <pod,secrets,deployment,service,job>` (delete)
  + `kubectl apply -f <file>` (update with changes to file)
  + `kubectl exec -it <pod> /bin/sh` (for alpine docker, access rails console)
- In the rails console, run migrations with `rails db:migrate`

Access Console:

`kubectl exec -it <pod ID> -- /bin/bash` or if on Alpine `kubectl exec -it <pod ID> -- /bin/sh`

 Migrate and seed:

 `bundle exec rake db:migrate`

 `bundle exec rake db:seed`

