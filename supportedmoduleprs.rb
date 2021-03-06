require 'bundler'

Bundler.require

require_relative 'supportedmodulesjira'

def get_supported_modules_info()

   p "Starting..."
    session = GoogleDrive::Session.from_service_account_key("PuppetModulePRs.json")

    spreadsheet = session.spreadsheet_by_title("Puppet Modules PRs")

    worksheet = spreadsheet.add_worksheet(DateTime.now.strftime("%Y/%m/%d %H:%M"), 200)

    #adding header row
    worksheet.insert_rows(1, [['module','prs', 'ticket count', 'component count', 'supported', 'url']])
    #get supported module list
    supported = PuppetForge::Module.where(owner: 'puppetlabs')
    supported.unpaginated.each do |mod|
        
        #There are some modules that are in Puppetlabs namespace that are not maintained by us (Arista, Cumulus)
        if (mod.homepage_url.include? "puppetlabs")
            worksheet.insert_rows(worksheet.num_rows + 1, [get_module_info(mod)])
            worksheet.save
        end
        
    end
    worksheet.save
    #target.close
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
    return ["#{mod.name}", "#{json.length}","#{ticket_count}","#{component_count}","#{mod.supported}", "#{mod.homepage_url}"]
    
end

get_supported_modules_info()

