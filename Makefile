DEVUPJSON = '.profile |= "uneet-dev" \
		  |.stages.production |= (.domain = "unit.dev.unee-t.com" | .zone = "dev.unee-t.com") \
		  | .actions[0].emails |= ["kai.hendry+unitdev@unee-t.com"] \
		  | .lambda.vpc.subnets |= [ "subnet-0e123bd457c082cff", "subnet-0ff046ccc4e3b6281", "subnet-0e123bd457c082cff" ] \
		  | .profile |= "uneet-dev" \
		  | .lambda.vpc.security_groups |= [ "sg-0b83472a34bc17400", "sg-0f4dadb564041855b" ]'

DEMOUPJSON = '.profile |= "uneet-demo" \
		  |.stages.production |= (.domain = "unit.demo.unee-t.com" | .zone = "demo.unee-t.com") \
		  | .actions[0].emails |= ["kai.hendry+unitdemo@unee-t.com"] \
		  | .lambda.vpc.subnets |= [ "subnet-0bdef9ce0d0e2f596", "subnet-091e5c7d98cd80c0d", "subnet-0fbf1eb8af1ca56e3" ] \
		  | .lambda.vpc.security_groups |= [ "sg-6f66d316" ]'

dev:
	@echo $$AWS_ACCESS_KEY_ID
	jq $(DEVUPJSON) up.json.in > up.json
	up deploy production

demo:
	@echo $$AWS_ACCESS_KEY_ID
	jq $(DEMOUPJSON) up.json.in > up.json
	up deploy production

prod:
	@echo $$AWS_ACCESS_KEY_ID
	jq '.profile |= "uneet-prod" |.stages.production |= (.domain = "unit.unee-t.com" | .zone = "unee-t.com")| .actions[0].emails |= ["kai.hendry+unitprod@unee-t.com"]' up.json.in > up.json
	up deploy production

testlocal:
	curl -i -H "Authorization: Bearer $(shell aws --profile uneet-dev ssm get-parameters --names API_ACCESS_TOKEN --with-decryption --query Parameters[0].Value --output text)" -X POST -d @tests/sample.json http://localhost:3000/create

testping:
	curl -i -H "Authorization: Bearer $(shell aws --profile uneet-demo ssm get-parameters --names API_ACCESS_TOKEN --with-decryption --query Parameters[0].Value --output text)" https://unit.demo.unee-t.com

.PHONY: dev demo prod
