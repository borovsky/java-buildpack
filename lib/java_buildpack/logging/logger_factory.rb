# Encoding: utf-8
# Cloud Foundry Java Buildpack
# Copyright (c) 2013 the original author or authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'java_buildpack/logging'
require 'java_buildpack/logging/delegating_logger'
require 'java_buildpack/util/configuration_utils'
require 'java_buildpack/util/constantize'
require 'logger'
require 'monitor'

module JavaBuildpack::Logging

  class LoggerFactory

    @@initialized = false

    @@monitor = Monitor.new

    def self.setup(application)
      @@monitor.synchronize do
        @@log_file    = application.root + '.java-buildpack.log'
        @@delegates   = [file_logger, console_logger]
        @@initialized = true
      end
    end

    def self.get_logger(klass)
      @@monitor.synchronize do
        raise "Attempted to get Logger for #{short_class(klass)} before initialization" unless @@initialized
        DelegatingLogger.new wrapped_short_class(klass), @@delegates
      end
    end

    def self.log_file
      @@monitor.synchronize do
        raise 'Attempted to get log file before initialization' unless @@initialized
        @@log_file
      end
    end

    def self.reset
      @@monitor.synchronize do
        @@initialized = false
      end
    end

    private_class_method :new

    private

    def self.console_logger
      logger           = Logger.new($stderr)
      logger.level     = severity
      logger.formatter = ->(severity, datetime, klass, message) do
        "#{klass.ljust(32)} #{severity.ljust(5)} #{message}\n"
      end

      logger
    end

    def self.file_logger
      logger           = Logger.new(@@log_file)
      logger.level     = ::Logger::DEBUG
      logger.formatter = ->(severity, datetime, klass, message) do
        "#{datetime.strftime('%FT%T.%2N%z')} #{klass.ljust(32)} #{severity.ljust(5)} #{message}\n"
      end

      logger
    end

    def self.ruby_mode
      $VERBOSE || $DEBUG ? 'DEBUG' : nil
    end

    def self.severity
      severity = ENV['JBP_LOG_LEVEL']
      severity = ruby_mode unless severity
      severity = JavaBuildpack::Util::ConfigurationUtils.load('logging', false)['default_log_level'] unless severity
      severity = 'INFO' unless severity

      "::Logger::Severity::#{severity.upcase}".constantize
    end

    def self.short_class(klass)
      klass.to_s.split('::').last
    end

    def self.wrapped_short_class(klass)
      "[#{short_class(klass)}]"
    end

  end

end
