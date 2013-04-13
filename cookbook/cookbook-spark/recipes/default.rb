#
# Cookbook Name:: cookbook-spark
# Recipe:: default
#
# Copyright 2013, Holden Karau
#
# BSD-3 Clause
#
node[:scala][:version] = 2.9.3
node[:scala][:url] = "http://www.scala-lang.org/downloads/distrib/files/scala-2.9.3.tgz"
node[:scala][:home] = node[:spark][:home]+"/scala"
include_recipe "scala::default"

git "{node[:spark][:home]}/spark/" do
  repository node[:spark][:git_repository]
  reference node[:spark][:git_revision]
  action :sync
  notifies :run, "bash[compile_app_name]"
end

bash "build_spark" do
  cwd "{node[:spark][:home]}"
  user node[:spark][:user]
  group node[:spark][:group]
  code <<-EOH
    ./sbt/sbt package
  EOH
end

template "{node[:spark][:home]}/spark/conf/spark-env.sh" do
  source "spark-env.sh.erb"
  owner node[:spark][:user]
  group node[:spark][:group]
  mode 00600
end

template "{node[:spark][:home]}/spark/conf/slaves" do
  source "slaves.erb"
  owner node[:spark][:user]
  group node[:spark][:group]
  mode 00600
end

service "spark_master" do
  start_command "{node[:spark][:home]/spark/bin/start-master.sh"
  stop_command "{node[:spark][:home]/spark/bin/stop-master.sh"
end
service "spark_worker" do
  start_command "{node[:spark][:home]/spark/bin/start-slave.sh spark://{node[:spark][:master]}:{node[:spark][:master_port]}"
  stop_command "{node[:spark][:home]/spark/bin/stop-slave.sh spark://{node[:spark][:master]}:{node[:spark][:master_port]}"
end
