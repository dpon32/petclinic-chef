#
# Cookbook:: petclinic
# Recipe:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.
tomcat_install "petclinicserver" do
  version '8.0.36'
end

tomcat_service "petclinicserver" do
  action [:enable, :start]
  env_vars [{'CATALINA_BASE' => '/opt/tomcat_petclinicserver_8_0_36/'},{'JAVA_OPTS' => '-Djava.net.preferIPv4Stack=true -Djava.net.preferIPv4Addresses=true'}]
end

remote_file '/opt/tomcat_petclinicserver_8_0_36/webapps/petclinic.war' do
  source 'http://localhost:8081/path/to/petclinic/pettclinic-1.0.0-SNAPSHOT.war'
  owner 'tomcat_petclinicserver'
  group 'tomcat_petclinicserver'
end

directory '/home/tomcat_petclinicserver' do
  owner 'tomcat_petclinicserver'
  group 'tomcat_petclinicserver'
  mode 0755
end
