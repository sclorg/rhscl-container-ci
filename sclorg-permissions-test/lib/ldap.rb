require 'ldap'

HOST        = 'ldap.rdu.redhat.com'
BASE_DN     = 'ou=Users, dc=redhat, dc=com'
ATTRS = ['uid', 'mail', 'cn']


def ldap_user_by_uid(uid)
  user = nil
  ldap = ldap_connect
  ldap.bind do
    ldap.search(BASE_DN, LDAP::LDAP_SCOPE_SUBTREE, "(uid=#{uid})", ATTRS) do |entry|
      #email = entry.vals('mail')[0]
      user = entry
    end
  end
  user
end

def ldap_user_by_email(email)
  user = nil
  ldap = ldap_connect
  ldap.bind do
    ldap.search(BASE_DN, LDAP::LDAP_SCOPE_SUBTREE, "(mail=#{email})", ATTRS) do |entry|
      user = entry
    end
  end
  user
end

def ldap_users_by_name(givenName, sn, perfect_match=false)
  users = []
  ldap = ldap_connect
  ldap.bind do
    ldap.search(BASE_DN, LDAP::LDAP_SCOPE_SUBTREE, "(|(&(givenName=#{givenName}#{perfect_match ? '' : '*'})(sn=#{sn}))(cn=#{givenName}#{perfect_match ? ' ' : '*'}#{sn}))", ATTRS) do |entry|
      users << entry
    end
  end
  users
end

def ldap_users_by_last_name(sn)
  users = []
  ldap = ldap_connect
  ldap.bind do
    ldap.search(BASE_DN, LDAP::LDAP_SCOPE_SUBTREE, "(sn=#{sn})", ATTRS) do |entry|
      users << entry
    end
  end
  users
end

def valid_users(users)
  valid_users = {}
  users.each do |user|
    user = github_user(user)
    login = user['login']
    name = user['name']
    email = user['email']
    begin
      if email && email.end_with?('@redhat.com') && ldap_user_by_email(email)
        # Found email in ldap
        valid_users[login] = email
      else
        email = ldap_email(name, login)
        if email
          valid_users[login] = email
        end
      end
    rescue Exception => e
      puts "    #{login}: #{name} (Exception: #{e.message})"
    end
  end
  return valid_users
end

private

def ldap_email(name, login, verbose=true, allow_multiple=false)
  first_name, middle_name, last_name = split_names(name)
  users = nil
  if last_name
    users = ldap_users_by_name(first_name, last_name, true)
    if users.length != 1 && !(allow_multiple && users.length > 1)
      users = ldap_users_by_name(first_name, last_name)
      if (users.length != 1 && middle_name) && !(allow_multiple && users.length > 1)
        users = ldap_users_by_name(middle_name, last_name)
        if users.length != 1 && !(allow_multiple && users.length > 1)
          users = ldap_users_by_name(first_name, "#{middle_name} #{last_name}")
        end
      end
      if users.length != 1 && !(allow_multiple && users.length > 1)
        last_name_users = ldap_users_by_last_name(last_name)
        users = last_name_users if last_name_users.length == 1
      end
    end
  else
    puts "No last name: #{login}: #{name}" if verbose
  end
  email = nil
  if users
    if users.length == 1 || (allow_multiple && users.length > 1)
      email = users.first['mail'].first
    else
      puts "Not found or multiple matches: #{login}: #{name}" if verbose
    end
  end
  return email
end

def split_names(name)
  first_name = nil
  last_name = nil
  middle_name = nil
  if name
    ['(', '['].each do |c|
      if name.index(c)
        name = name[0..name.index(c) - 1]
      end
    end
    names = name.strip.split(' ')
    first_name = I18n.transliterate(names.first)
    if first_name.end_with? '.'
      first_name = first_name[0..-2]
    end
    if names.length > 1
      last_name = I18n.transliterate(names.last)
      if names.length > 2
        middle_name = I18n.transliterate(names[1])
      end
    end
  end
  return [first_name, middle_name, last_name]
end

def ldap_connect
  ldap = LDAP::Conn.new(HOST, LDAP::LDAP_PORT.to_i)
  ldap.set_option(LDAP::LDAP_OPT_PROTOCOL_VERSION, 3)
  ldap
end
