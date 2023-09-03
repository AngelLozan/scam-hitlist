# Scam Reporting Full Stack Rails App

![Spam Banned Icon](https://github.com/AngelLozan/scam-hitlist/blob/main/app/assets/images/ban.png?raw=true)

An app to handle both database and user authentication for a scam reporting app.

Report IOCs and track their progress. Use a systematic approach to submitting and tracking IOCs with multiple API integrations.

Quicker and more efficient than using spreadsheets.

Allows for unauthorized users to submit IOCs. Allows for evidence attachment and tracking. Allows for multiple users to work on the same IOC.

## To import CSV data into Postgres. Need to set empty cells as null and placeholder timestamps for created and updated at if none. Order of columns must match order of columns in table.

run `heroku pg:psql -a scam-hitlist` to access postgres on heroku

```
\copy iocs(id,url,created_at,updated_at,removed_date,status,report_method_one,report_method_two,form,host,follow_up_date,follow_up_count,comments) FROM './lib/data.csv' WITH DELIMITER ',' NULL AS 'null' CSV HEADER;

```
Success message will be `copy 7000` or similar number.

## Setup
run `bundle install` to install dependencies
run `rails db:drop db:create db:migrate db:seed` to create database and seed with data

## To run
run `dev` to start server & run JS

If failing to see various features in front end, use `rails assets:precompile` to compile assets before running `dev`.


## Database setup
After seeding the database, you may need to manually find the next ID and set it in the rails console:

```
highest_id = Ioc.maximum(:id)

&&

next_available_id = highest_id + 1

ActiveRecord::Base.connection.execute("SELECT setval('iocs_id_seq', #{next_available_id}, false)")
```
In the case where you need to reset the sequence, you can run the following in the rails console (keep the `DATABASE` variable as is)):

```
heroku restart; heroku pg:reset DATABASE --confirm APP-NAME; heroku run rake db:migrate
```

## Deploying to Heroku:

In order to use `Grover` gem and `puppeteer` on Heroku, you need to add the following buildpacks:

Add Chrome buildpack:

```
heroku buildpacks:add heroku/google-chrome --index=1

```
Add Node/JS buildpack:

```
heroku buildpacks:add heroku/nodejs --index=2
```

Add Puppeteer buildpack (not sure if I still really need it or if Chrome build pack is enough will try at some point without it)

```
heroku buildpacks:add jontewks/puppeteer --index=3
```
Set the ENV variable to prevent downloading Chrominium:

```
heroku config:set PUPPETEER_SKIP_DOWNLOAD=true [--remote yourappname]

```
Configure the executable path in `config/initializers/grover.rb`:

```

Grover.configure do |config|
  config.options = {
    ...
    executable_path: "google-chrome"
  }
end
```

## Base Security Features

- Validates file size and limits to 5 mb and greater than 0
- Validates file type and only allows PDFs, .eml, jpeg, png, and txt
- Model Validations
- Uses built in methods to sanitize and remove xss attacks from form inputs (comments and url fields)
- Strong parameters
- CSRF meta tags used
- Strong Hash algorithm for cookies signatures (SHA-256)
- No open-uri use, no Marshal, no multiline, no use of html_safe, raw.
- Omniauth with limited users (2) and google enterprise account.
- Limiting routes
- Automated security check with bundler audit for dependencies, brakeman for code review and OSWAP dependency check. 

## Testing

- In controller rspec tests, create all model instances you would like to use. Then use `let` to create a variable that will be used in the tests.
  
## Docker
Don't forget to reset highest IOC as explained in `Database Setup`. Important if you've seeded the Database as planned here. 

View on localhost:3000 or 8080 depending on port chosen for captcha and oauth with docker compose. Separate from the build process below. 
`docker-compose build` & `docker-compose up`

Else, use this to build and push to docker hub and similar instructions on aws. 

- Build

`docker-compose build`

or

`docker build -t scottlozano/scam-hitlist:latest .`

- Test locally

`docker-compose up`

or

`docker run -p 3000:3000 scottlozano/scam-hitlist:latest`


- Push 

`docker push scottlozano/scam-hitlist:latest`

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

## AWS

- Deploy to cloud: [Amazon Elastic Container Registry](https://aws.amazon.com/ecr/)
  + Ensure Docker is running
  + After building with docker-compose. Tag container with desired name for docker hub and push to docker hub. (find app with `docker ps` then `docker tag <name> <dockerhub name>` & `docker push <dockerhub name>`)
  + Tag this image as your repository tag as specified after creating repo on AWS & push
- Create Kubernetes cluster: `eksctl create cluster --region eu-north-1 --name root --managed` (check region when logged into AWS to ensure the same as where repo and database are). This takes a few moments. 
- Create the RDS database. Use the free teir and the pre-configuration.
  + Port 5432
  + Add security groups used by the cluster to the database ensure that containers are not blocked from communicating with the RDS database. 
- Set DB credentials with k8s secret:
  + `echo -n "<username>" | base64` and `echo -n "<password>" | base64`
  + Store in yaml file.
  + Create secret on cluster: `kubectl create -f <secrets_filename>.yaml`
- Create k8s deployment
  + `kubectly apply -f k8s/db-secret.yaml`
  + `kubectly apply -f k8s/scam-hitlist-deployment.yaml`
  + `kubectly apply -f k8s/scam-hitlist-service.yaml`
- Verify with `kubectl get pods`

- restart terminal if unable to connect to pods
- Need to set dockerfile to run on linux `FROM --platform=linux/amd64 ruby:$RUBY_VERSION` in order to compile image built on mac M1
- Changing deployment number helps track deployments. 


Access Console:

`kubectl exec -it <pod ID> -- /bin/bash` or if on Alpine `kubectl exec -it <pod ID> -- /bin/sh`

 Migrate and seed:

 `bundle exec rake db:migrate`

 `bundle exec rake db:seed`

