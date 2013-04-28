require 'erb'

module Cloud::Rendering  
  def render(file: nil, text: nil, context: nil)
    contents = case
      when file
        File.read(file)
      when text
        text
      end
    
    erb = ERB.new(contents)
    context ||= binding
    erb.result(context)
  end
end