module Jekyll
  class CurrentUrl < Liquid::Tag

    def render(context)
    	page_url = context.environments.first["page"]["url"]
    end

  end
end

Liquid::Template.register_tag('current_url', Jekyll::CurrentUrl)