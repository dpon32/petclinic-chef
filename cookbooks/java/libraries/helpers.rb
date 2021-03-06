#
# Author:: Joshua Timberman <joshua@chef.io>
# Copyright:: Copyright (c) 2013-2015, Chef Software, Inc. <legal@chef.io>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/version_constraint'
require 'uri'
require 'pathname'

module ChefCookbook
  class OpenJDK
    attr_accessor :java_home, :jdk_version

    def initialize(node)
      @node = node.to_hash
      @java_home = @node['java']['java_home'] || '/usr/lib/jvm/default-java'
      @jdk_version = @node['java']['jdk_version'].to_s || '6'
    end

    def java_location
      File.join(java_home_parent(@java_home), openjdk_path, 'bin/java')
    end

    def alternatives_priority
      if @jdk_version == '6'
        # 'accepted' default for java 6
        1061
      elsif @jdk_version == '7'
        # i just made this number up
        1100
      elsif @jdk_version.to_i > 7
        # just a guard against the incoming java 8
        # so this cookbook will actually work for.. new versions of java
        1110
      else
        # it's not 6, it's not 7, it's not newer than
        # 7, but we probably want to install it, so
        # override 6's priority. arbitrary number.
        1062
      end
    end

    def java_home_parent(java_home)
      Pathname.new(java_home).parent.to_s
    end

    def openjdk_path
      case @node['platform_family']
      when 'debian'
        format('java-%s-openjdk%s/jre', @jdk_version, arch_dir)
      when 'rhel', 'fedora', 'amazon'
        path = @node['java']['jdk_version'].to_i < 11 ? 'jre-1.%s.0-openjdk%s' : 'java-%s'
        format(path, @jdk_version, arch_dir)
      else
        'jre'
      end
    end

    def arch_dir
      @node['kernel']['machine'] == 'x86_64' ? sixty_four : thirty_two
    end

    def sixty_four
      case @node['platform_family']
      when 'debian'
        '-amd64'
      when 'rhel', 'fedora', 'amazon'
        '.x86_64'
      else
        '-x86_64'
      end
    end

    def thirty_two
      case @node['platform_family']
      when 'debian'
        '-i386'
      else
        ''
      end
    end
  end
end

class Chef
  class Recipe
    def valid_ibm_jdk_uri?(url)
      url =~ ::URI::ABS_URI && %w(file http https).include?(::URI.parse(url).scheme)
    end

    def platform_requires_license_acceptance?
      %w(smartos).include?(node['platform'])
    end
  end
end
