#
# Copyright 2016 GitLab Inc.
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

name 'mixlib-log'
# The version here should be in agreement with /Gemfile.lock so that our rspec
# testing stays consistent with the package contents.
default_version '3.0.1'

license 'Apache-2.0'
license_file 'LICENSE'
license_file 'NOTICE'

skip_transitive_dependency_licensing true

dependency 'ruby'
dependency 'rubygems'

build do
  patch source: "license/add-license-file.patch"
  patch source: "license/add-notice-file.patch"
  env = with_standard_compiler_flags(with_embedded_path)

  gem 'install mixlib-log' \
      " --version '#{version}'" \
      " --bindir '#{install_dir}/embedded/bin'" \
      ' --no-document', env: env
end
