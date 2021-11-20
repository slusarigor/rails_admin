module RailsAdmin
  class ESModulePreprocessor
    def self.instance
      @instance ||= new
    end

    def self.call(input)
      instance.call(input)
    end

    def initialize; end

    def call(input)
      data = input[:data]

      # only process files under rails_admin/src
      if input[:filename].start_with? RailsAdmin::Engine.root.join('src').to_s
        data.gsub!(/^(import .+)$/) { "// #{Regexp.last_match(1)}" }
        data.gsub!(/^(export +default +{)$/) do
          case File.basename(input[:filename])
          when 'i18n.js'
            "/* #{Regexp.last_match(1)} */ window.I18n = {"
          else
            raise "Unable to preprocess file: #{input[:filename]}"
          end
        end
      end

      {data: data}
    end
  end
end
