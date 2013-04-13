include_recipe "cookbook-spark::default"

service "spark_master" do
  action :start
end
