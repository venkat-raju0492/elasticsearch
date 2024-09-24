region                            = "us-west-2"                                     ## AWS region to deploy service
project                           = "poc"                                           ## name of the project
env                               = "dev"                                           ## name of the environment
cost_category                     = "poc"                                           ## cost category tag


instance_count                    = 3                                               ## no. of data nodes
es_uname                          = "admin"                                         ## es username
instance_type                     = "r5.large.elasticsearch"                        ## data node instance type
ebs_options_volume_size           = 100                                             ## data node storage in Gib
dedicated_master_enabled          = true                                            ## enable master node
dedicated_master_type             = "c5.large.elasticsearch"                        ## master node instance type
dedicated_master_count            = 3                                               ## no. of master nodes
allow_security_group_ids          = ["sg-xxxxxx","sg-xxxxxxxxxxxxx"]                ## security groups to access es
retention_in_days                 = 30                                              ## cloud watch logs retention period
es_port                           = 443                                             ## es default port
tls_security_policy               = "Policy-Min-TLS-1-0-2019-07"                    ## es tls security policy
leader_cluster                    = true                                            ## leader cluster or follower cluster
allowed_cidrs                     = ["192.168.1.1./32", "172.16.254.1/32"]          ## network to access es
subnet_ids                        = ["subnet-xxxx", "subnet-xxxx", "subnet-xxxx"]   ## private subnet ids
vpc_id                            = "vpc-xxxxx"                                     ## vpc id




