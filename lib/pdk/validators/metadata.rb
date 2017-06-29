require 'pdk'
require 'pdk/cli/exec'
require 'pdk/validators/base_validator'
require 'pdk/util/bundler'

module PDK
  module Validate
    class Metadata < BaseValidator
      def self.name
        'metadata'
      end

      def self.cmd
        'metadata-json-lint'
      end

      def self.spinner_text
        _('Checking metadata.json')
      end

      def self.parse_targets(_options)
        [File.join(PDK::Util.module_root, 'metadata.json')]
      end

      def self.parse_options(_options, targets)
        cmd_options = ['--format', 'json']

        cmd_options.concat(targets)
      end

      def self.parse_output(report, result, _targets)
        begin
          json_data = JSON.parse(result[:stdout])
        rescue JSON::ParserError
          json_data = []
        end

        if json_data.empty?
          report.add_event(
            file:     'metadata.json',
            source:   cmd,
            state:    :passed,
            severity: :ok,
          )
        else
          json_data.delete('result')
          json_data.keys.each do |type|
            json_data[type].each do |offense|
              # metadata-json-lint groups the offenses by type, so the type ends
              # up being `warnings` or `errors`. We want to convert that to the
              # singular noun for the event.
              event_type = type[%r{\A(.+?)s?\Z}, 1]

              report.add_event(
                file:     'metadata.json',
                source:   cmd,
                message:  offense['msg'],
                test:     offense['check'],
                severity: event_type,
                state:    :failure,
              )
            end
          end
        end
      end
    end
  end
end
