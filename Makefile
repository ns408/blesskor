include env.mk

cfn-create: _validate-stack-name _validate-profile
	$(call cfn,create-stack,$(capacity))

cfn-update: _validate-stack-name _validate-profile
	$(call cfn,update-stack,$(capacity))

cfn-pause: _validate-stack-name _validate-profile
	$(call cfn,update-stack,0)	

cfn-resume: _validate-stack-name _validate-profile
	$(call cfn,update-stack,1)
	
cfn-delete: _validate-stack-name _validate-profile
	aws cloudformation delete-stack --profile $(PROFILE) --region $(region) --stack-name $(STACK-NAME)

cfn-status: _validate-stack-name _validate-profile
	aws cloudformation describe-stacks --profile $(PROFILE) --region $(region) --stack-name $(STACK-NAME) --query 'Stacks[].StackStatus' --output text
	
define cfn
	aws cloudformation $1 --profile $(PROFILE) \
	      --capabilities CAPABILITY_NAMED_IAM \
        --region $(region)  \
        --stack-name $(STACK-NAME) \
        --template-body file://bless-cfn.yaml \
        --parameters \
           ParameterKey=ami,ParameterValue=$(ami) \
           ParameterKey=iamprofile,ParameterValue=$(iamprofile) \
           ParameterKey=key,ParameterValue=$(key) \
           ParameterKey=kmskey,ParameterValue=$(kmskey) \
           ParameterKey=password,ParameterValue=$(password) \
           ParameterKey=subnets,ParameterValue=\"$(subnets)\" \
           ParameterKey=user,ParameterValue=$(user) \
           ParameterKey=yourcidr,ParameterValue=$(yourcidr) \
           ParameterKey=vpc,ParameterValue=$(vpc)
endef

_validate-stack-name:
ifndef STACK-NAME
	$(error STACK-NAME is required)
endif

_validate-profile:
ifndef PROFILE
	$(error PROFILE is required)
endif
