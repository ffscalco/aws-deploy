module AwsDeploy
  class Instance
    
    def initialize(credentials)
      @credentials = credentials
      @ec2 = Aws::Ec2.new(@credentials.key, @credentials.token)
      @elb = Aws::Elb.new(@credentials.key, @credentials.token)
    end
    
    def find_all
      instances = @elb.describe_instance_health(AwsDeploy.configuration.load_balancer_name).map{|i| i[:instance_id]}
      return [] if instances.size == 0
      @ec2.describe_instances(instances)
    end
    
    def find_all_in_service
      instances = @elb.describe_instance_health(AwsDeploy.configuration.load_balancer_name).select{ |i| i[:state] == 'InService' }.map{|i| i[:instance_id]}
      return [] if instances.size == 0
      @ec2.describe_instances(instances)
    end
    
    def all_instances_registered?
      find_all == LoadBalance.new(@credentials).instances
    end
    
    def terminate_instances(number = 1)
      if find_all_in_service.size > 0 
        @ec2.terminate_instances(find_all_in_service.take(number).map{|i| i[:aws_instance_id]})
      end
    end
    
  end
end
