# We create a function to simplify getting variables for aws parameter store.
# The variable TRAVIS_AWS_PROFILE is set when .travis.yml runs

define ssm
$(shell aws --profile $(TRAVIS_AWS_PROFILE) ssm get-parameters --names $1 --with-decryption --query Parameters[0].Value --output text)
endef

# We prepare variables for up in UPJSON and PRODUPJSON.
# These variables are comming from AWS Parameter Store
# - STAGE
# - DOMAIN
# - EMAIL_FOR_NOTIFICATION_UNIT
# - PRIVATE_SUBNET_1
# - PRIVATE_SUBNET_2
# - PRIVATE_SUBNET_3
# - LAMBDA_TO_RDS_SECURITY_GROUP

UPJSON = '.profile |= "$(TRAVIS_AWS_PROFILE)" \
		  |.stages.production |= (.domain = "unit.$(call ssm,STAGE).$(call ssm,DOMAIN)" | .zone = "$(call ssm,STAGE).$(call ssm,DOMAIN)") \
		  | .actions[0].emails |= ["unit+$(call ssm,EMAIL_FOR_NOTIFICATION_UNIT)"] \
		  | .lambda.vpc.subnets |= [ "$(call ssm,PRIVATE_SUBNET_1)", "$(call ssm,PRIVATE_SUBNET_2)", "$(call ssm,PRIVATE_SUBNET_3)" ] \
		  | .lambda.vpc.security_groups |= [ "$(call ssm,LAMBDA_TO_RDS_SECURITY_GROUP)" ]'

PRODUPJSON = '.profile |= "$(TRAVIS_AWS_PROFILE)" \
		  |.stages.production |= (.domain = "unit.$(call ssm,DOMAIN)" | .zone = "$(call ssm,DOMAIN)") \
		  | .actions[0].emails |= ["unit+$(call ssm,EMAIL_FOR_NOTIFICATION_UNIT)"] \
		  | .lambda.vpc.subnets |= [ "$(call ssm,PRIVATE_SUBNET_1)", "$(call ssm,PRIVATE_SUBNET_2)", "$(call ssm,PRIVATE_SUBNET_3)" ] \
		  | .lambda.vpc.security_groups |= [ "$(call ssm,LAMBDA_TO_RDS_SECURITY_GROUP)" ]'
# We have everything, we can run up now.

dev:
	@echo $$AWS_ACCESS_KEY_ID
	jq $(UPJSON) up.json.in > up.json
	up deploy production

demo:
	@echo $$AWS_ACCESS_KEY_ID
	# We replace the relevant variable in the up.json file
	# We use the template defined in up.json.in for that
	jq $(UPJSON) up.json.in > up.json
	up deploy production

prod:
	@echo $$AWS_ACCESS_KEY_ID
	# We replace the relevant variable in the up.json file
	# We use the template defined in up.json.in for that
	jq $(PRODUPJSON) up.json.in > up.json
	up deploy production

test:
	curl -i -H "Authorization: Bearer $(call ssm,API_ACCESS_TOKEN)" https://unit.$(call ssm,STAGE).$(call ssm,DOMAIN)/metrics
