#--
# Copyright 2013 Red Hat, Inc.
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
#++

module Vagrant
  module Openshift
    module Action
      class RunGeardTests
        include CommandHelper

        @@SSH_TIMEOUT = 4800

        def initialize(app, env, options)
          @app = app
          @env = env
          @options = options.clone
        end

        def call(env)
          @options.delete :help
          @options.delete :logs

          cmd_opts = ''
          if @options[:all]
            cmd_opts += "-a "
          end

          # TODO: remove the need for permissive mode once we get through SELinux issues with docker 1.0 and geard
          sudo(env[:machine], %{
            set -e
            if [[ $(cat /etc/sudoers | grep 'Defaults:root !requiretty') = "" ]]; then
              echo "Disabling requiretty for root user for contrib/test sudo support"
              echo -e '\\nDefaults:root !requiretty\\n' >> /etc/sudoers
            fi
            pushd #{Constants.build_dir}/geard
            setenforce 0
            contrib/test #{cmd_opts}
            popd
            }, {:timeout => 60*60})

          @app.call(env)
        end
      end
    end
  end
end