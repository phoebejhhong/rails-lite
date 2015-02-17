require 'active_support/inflector'

module  UrlHelper
  def link_to (body, url)
    "<a href='#{url}'>#{body}</a>"
  end

  def button_to (value, url, options = {})
    method = options[:method]|| "post"
    # only GET and POST would work...
    <<-BUTTON
    <form method="#{method}" action="#{url}">
      <input type="submit" value="#{value}" />
    </form>
    BUTTON
  end

  def parse_url(url, id = nil)
    # cats_url => /cats
    # cat_url(1) => /cats/1
    # new_cat_url => /cats/new
    # no support for nested routes! or singular resource!

    match_data = Regexp.new(/(?<body>.+)_url/).match(url)
    return url unless match_data

    body = match_data[:body].split("_")
    if id
      return "/#{body.first.pluralize}/#{id}"
    elsif body.size > 1
      return "/#{body.last.pluralize}/#{body.first}"
    else
      return "/#{body.first.pluralize}"
    end
  end

  def method_missing(meth, *args, &block)
    if meth.to_s =~ /.+_url/
      parse_url(meth.to_s, *args)
    else
      super
    end
  end
end
