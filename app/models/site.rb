class Site < ActiveRecord::Base
	validates_presence_of :host_name
	validates_uniqueness_of :host_name
	has_many :pages, :dependent => :destroy
	has_many :links, :through => :pages
end
