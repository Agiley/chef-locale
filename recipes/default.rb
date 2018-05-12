#
# Cookbook Name:: locale
# Recipe:: default
#
# Copyright 2011, Heavy Water Software Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

if platform?("ubuntu", "debian")

  package "locales" do
    action :install
  end
  
  node[:locale][:language_packs].each do |language_pack|
    package "language-pack-#{language_pack}-base" do
      action :install
    end
  end if node[:locale][:language_packs].any?
  
  execute "Update locale" do
  	command_string = "update-locale"
    
    node[:locale][:vars].each do |var|
      unless node[:locale][var].to_s.empty?
        ENV[var.to_s.upcase] = node[:locale][var] # Set ENV so that subsequent processes will have the correct locales set
        command_string << " #{var.to_s.upcase}=#{node[:locale][var]}"
      end
    end

    Chef::Log.debug("locale command is #{command_string.inspect}")
    
    command command_string
  end
  
  execute "Source new locale config" do
    command ". #{node[:locale][:config_path]}"
  end

end

if platform?("redhat", "centos", "fedora")
  execute "Update locale" do
    command "locale -a | grep ^#{node[:locale][:lang]}$ && sed -i 's|LANG=.*|LANG=#{node[:locale][:lang]}|' /etc/sysconfig/i18n"
  end
end
