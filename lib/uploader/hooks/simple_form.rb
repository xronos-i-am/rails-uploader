require "simple_form"

class SimpleFormUploaderInput < SimpleForm::Inputs::Base
  def input
    @builder.uploader_field(attribute_name, input_html_options)
  end
end

::SimpleForm::FormBuilder.map_type :uploader, to: SimpleFormUploaderInput 