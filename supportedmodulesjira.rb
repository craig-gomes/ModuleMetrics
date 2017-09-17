require 'jira-ruby'
require 'json'

$client =nil

#helpers
def get_client()

    unless $client
        print 'Enter JIRA username:'
        username = gets.chomp
    
        print 'Enter JIRA password:'
        system "stty -echo"
        password = gets.chomp
        system "stty echo"
        puts "\nRetrieving..."

        options = {
                    :username => username,
                    :password => password,
                    #:site     => 'http://127.0.0.1:2990', #local site
                    #TODO change this when ready for prime time
                    #:site   => "https://jira1-test.ops.puppetlabs.net", #This is the test site
                    :site => "https://tickets.puppetlabs.com/",
                    :context_path => '',
                    :auth_type => :basic,
                    :ssl_verify_mode =>OpenSSL::SSL::VERIFY_NONE ,
                    #:use_ssl => false, 
                    :read_timeout => 120
                }

        $client = JIRA::Client.new(options)
    end
    return $client  
end

def get_ticket_count_for_module(module_name)
    return query_count("summary~#{module_name} AND resolution = unresolved")
   
end

def get_component_count_for_module(module_name)
    return query_count("project = modules and component = #{module_name} and resolution = unresolved")
    
end

def query(jql)
    client = get_client()
    return client.Issue.jql(jql)
end 

def query_count(jql)
    count = 0
    begin
        client = get_client()
        count = client.Issue.jql(jql).count
    rescue => exception
        p "Exception caught in query #{jql}: " + exception.response.to_s
    end
    return count
end