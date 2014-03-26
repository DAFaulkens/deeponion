class Link < ActiveRecord::Base
  validates_presence_of :href, :found_on, :full_path
  validates_uniqueness_of :full_path, :scope => :found_on
  belongs_to :page

  before_validation(:on => [:create, :update, :save]) do
    self.full_path = get_full_path
  end

    def found_on_uri
      @found_on_uri ||= URI.parse(found_on)
    end

    def uri
      @uri ||= URI.parse(full_path)
    end

    def local?
      found_on_uri.host == uri.host
    end

    def onion?
      full_path =~ /[[aA-zZ]|[0-9]]\.onion/
    end

    def full_path
      @full_path ||= get_full_path
    end



    def get_full_path
      parsed_href = URI.parse(href)
      if parsed_href.host
        return "#{parsed_href.scheme}://#{parsed_href.host}:#{parsed_href.port}#{parsed_href.path}?#{"?#{uri.query}" if uri.query}" 
      end
      Link.parse_abs_path(found_on_uri, href)
    end

    def self.parse_abs_path(parent_uri, path)
      (path[0] == "/") ? "#{parent_uri.scheme}://#{parent_uri.host}:#{parent_uri.port}#{path}" : parse_relative(parent_uri, path)
    end

    def self.parse_relative(parent_uri, path)
      if parent_uri.path =~ /\/$/
        "#{parent_uri.scheme}://#{parent_uri.host}:#{parent_uri.port}#{parent_uri.path}#{path}"
      else
        slice = (parent_uri.path =~ /\/\w+(\.\w+)?$/) ? parent_uri.path[0..(parent_uri.path =~ /\/\w+(\.\w+)?$/)] : "/"
        "#{parent_uri.scheme}://#{parent_uri.host}:#{parent_uri.port}#{slice}#{path}"
      end
    end

end
