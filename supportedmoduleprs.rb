#Get a list of supported modules
#You will need to gem install these dependencies
# gem install puppet_forge
# gem install HTTParty
# gem install json
require 'puppet_forge'
require 'HTTParty'
require 'json' # do not install > 2.0
require 'jira-ruby'

require_relative 'supportedmodulesjira'

def get_supported_modules_info()

    #open file for writing
    target = open("modules.csv", "w")
    target.truncate(0)
    target.puts("module,prs, ticket count, component count, supported, url")
    #get supported module list
    supported = PuppetForge::Module.where(owner: 'puppetlabs')
    supported.unpaginated.each do |mod|
        #p "Module #{mod.name} UserName  #{mod.owner.username}"
        #There are some modules that are in Puppetlabs namespace that are not maintained by us (Arista, Cumulus)
        if (mod.homepage_url.include? "puppetlabs")
            target.puts(get_module_info(mod))
        end
    end
    target.close
end


# The auth token in this URL is mine.  It is recommended that you use your own auth token.
# https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/
def get_module_info(mod)
    pull_url = "https://api.github.com/repos/puppetlabs/puppetlabs-#{mod.name}/issues?state=open&access_token=AUTHTOKEN"
    response = HTTParty.get pull_url#, :headers=>{"Authorization"=>"Token token=\"AUTHTOKEN\"", "User-Agent"=>"craig.gomes"}


    json = JSON.parse(response.body)
    ticket_count = get_ticket_count_for_module(mod.name)
    component_count = get_component_count_for_module(mod.name)
    p mod.name
    #p json
    return "#{mod.name}, #{json.length},#{ticket_count},#{component_count},#{mod.supported}, #{mod.homepage_url}"
    
end

#show_module_prs()
get_supported_modules_info()

#p get_ticket_count_for_module('puppetdb')
#p get_ticket_count_for_module('motd')