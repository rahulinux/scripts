require 'QuickBaseClient'

qbc_username = ""
qbc_pass = ""
org_name = ""
my_application = ""
table_name = ""


## Connect to QuickBase
qbc = QuickBase::Client.init({ "username" => qbc_username, "password" => qbc_pass, "org" => org_name})

#qbc.printRequestsAndResponses = true
data = { 
           'instance_name' => 'Chef Master', 
           'public_ip' => [], 
           'private_ip' => [ "10.10.10.1" ], 
           'resource_uid' => '23ad977c-blablabla-bal232424', 
           'state' => 'inactive', 
           'created_on' => '2015/10/16 17:12:54 +0000', 
           'updated_on' => '2015/10/16 17:12:54 +0000'
        }

## Get dbid of my_application
qbc.grantedDBs{|db|

    if db.dbinfo.dbname.include?(my_application)
        $dbid = db.dbinfo.dbid
        break
    else
        puts "No application found"
    end 
}

data.each do |key,value|

   qbc.addRecord($dbid,{ key => value })
   puts qbc.lastError
   puts $dbid,{ key => value }

end

qbc.signOut
