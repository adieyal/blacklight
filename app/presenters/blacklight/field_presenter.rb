# frozen_string_literal: true

module Blacklight
  # Renders a field and handles link_to_facet or helper_method if supplied
  class FieldPresenter
    # @param controller [Object] the context in which to execute helper methods
    # @param document [SolrDocument] the document
    # @param field_config [Blacklight::Configuration::Field] the field's configuration
    # @param options [Hash]
    # @option options [Object] :values
    # @option options [Array] :except_operations
    # @option options [Object] :value
    # @option options [Array] :steps
    def initialize(controller, document, field_config, options = {})
      @controller = controller
      @document = document
      @field_config = field_config
      @options = options

      @values = if options.key?(:value)
                  Array.wrap(options[:value])
                else
                  options[:values]
                end

      @except_operations = options[:except_operations] || []
      # Implicitly prevent helper methods from drawing when drawing the label for the document
      @except_operations += [Rendering::HelperMethod] if options.key? :value
    end

    attr_reader :controller, :document, :field_config, :except_operations, :options

    def render
      Rendering::Pipeline.new(retrieve_values, field_config, document, controller, pipeline_steps, options).render
    end

    def label(context = 'index', **options)
      field_config.display_label(context, count: retrieve_values.count, **options)
    end

    private

    def pipeline_steps
      (options[:steps] || Rendering::Pipeline.operations) - except_operations
    end

    # rubocop:disable Naming/MemoizedInstanceVariableName
    def retrieve_values
      @values ||= FieldRetriever.new(document, field_config).fetch
    end
    # rubocop:enable Naming/MemoizedInstanceVariableName
  end
end
