include_recipe "cookbook-spark::default"

service "spark_worker" do
  action :start
end
