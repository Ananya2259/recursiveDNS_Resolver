def get_command_line_argument
  # ARGV is an array that Ruby defines for us,
  # which contains all the arguments we passed to it
  # when invoking the script from the command line.
  # https://docs.ruby-lang.org/en/2.4.0/ARGF.html
  if ARGV.empty?
    puts "Usage: ruby lookup.rb <domain>"
    exit
  end
  ARGV.first
end

# `domain` contains the domain name we have to look up.
domain = get_command_line_argument

# File.readlines reads a file and returns an
# array of string, where each element is a line
# https://www.rubydoc.info/stdlib/core/IO:readlines
dns_raw = File.readlines("zone")

def parse_dns(dns_raw)
  dns_raw = dns_raw.reject { |line| line[0] == "#" or line.empty? } #parses the zone file and deletes the empty lines and commented lines and stores it again in in the same variable.
  dns_records = {} #creates a hash
  dns_raw.each do |line| #loops through each line in file.
    arr = line.strip.split(", ") #splits the line into three array elements and stores it in array
    unless (dns_records.include? (arr[0])) #checks if the key already exists in the hash
      dns_records[arr[0]] = { arr[1] => arr[2] } #creates a key and stores the hash in that.
    else
      dns_records[arr[0]][arr[1]] = arr[2] #Appends a new hash as value to a already existing key.
    end
  end
  return dns_records
end

def resolve(dns_records, lookup_chain, domain)
  if dns_records["A"].include?(domain) #checks if the given domains ip address in A records.If yes it will return the ip address
    return lookup_chain.push(dns_records["A"][domain])
  elsif dns_records["CNAME"].include?(domain) #checks if the given domains is in CNAME record if yes it will recursively call the resolve function with the other domain name returned by the Cname record.
    lookup_chain.push(dns_records["CNAME"][domain])
    resolve(dns_records, lookup_chain, dns_records["CNAME"][domain])
  else
    lookup_chain.clear << ("Error: record not found for " + domain) #If the user has given a invalid request this will provide a appropriate message to the user.
  end
end

dns_records = parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)

puts lookup_chain.join(" => ")
