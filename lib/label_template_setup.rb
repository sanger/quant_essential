# frozen_string_literal: true

#
# Class LabelTemplateSetup provides an easy way to register
# label templates in print my barcode, and to record the corresponding templates
# in the QuantEssential database
#
class LabelTemplateSetup
  class << self
    def label_types
      @label_types ||= PMB::LabelType.all
    end

    def label_templates
      @label_templates ||= PMB::LabelTemplate.all
    end

    def find_label_template_by_name(name)
      label_templates.detect { |t| t.name == name }
    end

    def label_type_id_for(type_name)
      label_types.detect { |lt| lt.name == type_name }.id
    end

    def templates
      @templates ||= []
    end

    def register_template(template_name, template_type)
      puts "Loading #{template_name}"
      type_id = label_type_id_for(template_type)
      templates << LabelTemplateSetup.new(template_name, yield(template_name, type_id))
    end

    def find_or_register_each_template!
      templates.each(&:find_or_register!)
    end
  end

  attr_reader :name, :hash

  def initialize(name, hash)
    @name = name
    @hash = hash
  end

  def find_or_register!
    puts "Processing #{name}..."
    existing = find_or_create_by_name!

    if local_template.external_id == existing.id
      puts 'No changes...'
      return true
    end
    local_template.external_id = existing.id
    local_template.new_record? ? 'Registering template' : 'Updating template'
    local_template.save!
  end

  def local_template
    return @local if @local
    @local = LabelTemplate.find_by(name: name) || LabelTemplate.new(name: name)
  end

  def find_or_create_by_name!
    existing = LabelTemplateSetup.find_label_template_by_name(name)

    if existing
      puts "Exisiting #{name} template found!"
      return existing
    else
      create_remote!
    end
  end

  def template
    @template ||= PMB::LabelTemplate.new(hash)
  end

  def create_remote!
    puts "Creating #{name} template"
    template.save
    template
  end
end
