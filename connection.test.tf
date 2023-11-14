module "connection_string_simple" {
  source = "./connection"

  string = "http://host"
}

check "connection_string_simple" {
  assert {
    condition     = module.connection_string_simple.scheme == "http"
    error_message = "scheme is not http"
  }

  assert {
    condition     = module.connection_string_simple.host == "host"
    error_message = "Host is not host"
  }

  assert {
    condition     = module.connection_string_simple.port == null
    error_message = "Port is not null"
  }

  assert {
    condition     = module.connection_string_simple.user == null
    error_message = "User is not null"
  }

  assert {
    condition     = module.connection_string_simple.password == null
    error_message = "Password is not null"
  }

  assert {
    condition     = module.connection_string_simple.path == ""
    error_message = "Path is not an empty string"
  }
}

module "connection_string_full" {
  source = "./connection"

  string = "ssh://user:password@host:1234/some/file"
}

check "connection_string_full" {
  assert {
    condition     = module.connection_string_full.scheme == "ssh"
    error_message = "scheme is not ssh"
  }

  assert {
    condition     = module.connection_string_full.host == "host"
    error_message = "Host is not host"
  }

  assert {
    condition     = module.connection_string_full.port == 1234
    error_message = "Port is not 1234"
  }

  assert {
    condition     = module.connection_string_full.user == "user"
    error_message = "User is not user"
  }

  assert {
    condition     = module.connection_string_full.password == "password"
    error_message = "Password is not password"
  }

  assert {
    condition     = module.connection_string_full.path == "/some/file"
    error_message = "Path is not /some/file"
  }
}

module "connection_string_with_defaults" {
  source = "./connection"

  string = "ssh://host"

  default_port = "22"
  default_user = "default_user"
}

check "connection_string_with_defaults" {
  assert {
    condition     = module.connection_string_with_defaults.scheme == "ssh"
    error_message = "scheme is not ssh"
  }

  assert {
    condition     = module.connection_string_with_defaults.host == "host"
    error_message = "Host is not host"
  }

  assert {
    condition     = module.connection_string_with_defaults.port == 22
    error_message = "Port is not 22"
  }

  assert {
    condition     = module.connection_string_with_defaults.user == "default_user"
    error_message = "User is not user"
  }

  assert {
    condition     = module.connection_string_with_defaults.password == null
    error_message = "Password is not null"
  }

  assert {
    condition = module.connection_string_with_defaults.path == ""
    error_message = "Path is not an empty string"
  }
}

module "connection_string_https" {
  source = "./connection"

  string = "https://john.doe@www.example.com:123/forum/questions/?tag=networking&order=newest#top"
}

check "connection_string_https" {
  assert {
    condition     = module.connection_string_https.scheme == "https"
    error_message = "scheme is not https"
  }

  assert {
    condition     = module.connection_string_https.user == "john.doe"
    error_message = "user is not john.doe"
  }

  assert {
    condition     = module.connection_string_https.host == "www.example.com"
    error_message = "Host is not www.example.com"
  }

  assert {
    condition     = module.connection_string_https.port == 123
    error_message = "Port is not 123"
  }

  assert {
    condition     = module.connection_string_https.path == "/forum/questions/"
    error_message = "Path is not /forum/questions/"
  }

  assert {
    condition     = module.connection_string_https.query == "tag=networking&order=newest"
    error_message = "Query is not tag=networking&order=newest"
  }

  assert {
    condition     = module.connection_string_https.fragment == "top"
    error_message = "Fragment is not top"
  }
}

module "connection_string_ldap" {
  source = "./connection"

  string = "ldap://[2001:db8::7]/c=GB?objectClass?one"
}

check "connection_string_ldap" {
  assert {
    condition     = module.connection_string_ldap.scheme == "ldap"
    error_message = "scheme is not ldap"
  }

  assert {
    condition     = module.connection_string_ldap.authority == "[2001:db8::7]"
    error_message = "Authority is not [2001:db8::7]"
  }

  assert {
    condition     = module.connection_string_ldap.path == "/c=GB"
    error_message = "Path is not /c=GB"
  }

  assert {
    condition     = module.connection_string_ldap.query == "objectClass?one"
    error_message = "Query is not objectClass?one"
  }
}

module "connection_string_mailto" {
  source = "./connection"

  string = "mailto:John.Doe@example.com"
}

check "connection_string_mailto" {
  assert {
    condition     = module.connection_string_mailto.scheme == "mailto"
    error_message = "scheme is not mailto"
  }

  assert {
    condition     = module.connection_string_mailto.path == "John.Doe@example.com"
    error_message = "Path is not John.Doe@example.com"
  }
}

module "connection_string_news" {
  source = "./connection"

  string = "news:comp.infosystems.www.servers.unix"
}

check "connection_string_news" {
  assert {
    condition     = module.connection_string_news.scheme == "news"
    error_message = "scheme is not news"
  }

  assert {
    condition     = module.connection_string_news.path == "comp.infosystems.www.servers.unix"
    error_message = "Path is not comp.infosystems.www.servers.unix"
  }
}

module "connection_string_tel" {
  source = "./connection"

  string = "tel:+1-816-555-1212"
}

check "connection_string_tel" {
  assert {
    condition     = module.connection_string_tel.scheme == "tel"
    error_message = "scheme is not tel"
  }

  assert {
    condition     = module.connection_string_tel.path == "+1-816-555-1212"
    error_message = "Path is not +1-816-555-1212"
  }
}

module "connection_string_telnet" {
  source = "./connection"

  string = "telnet://192.0.2.16:80/"
}

check "connection_string_telnet" {
  assert {
    condition     = module.connection_string_telnet.scheme == "telnet"
    error_message = "scheme is not telnet"
  }

  assert {
    condition     = module.connection_string_telnet.authority == "192.0.2.16:80"
    error_message = "Authority is not 192.0.2.16:80"
  }

  assert {
    condition     = module.connection_string_telnet.path == "/"
    error_message = "Path is not /"
  }
}

module "connection_string_urn" {
  source = "./connection"

  string = "urn:oasis:names:specification:docbook:dtd:xml:4.1.2"
}

check "connection_string_urn" {
  assert {
    condition     = module.connection_string_urn.scheme == "urn"
    error_message = "scheme is not urn"
  }

  assert {
    condition     = module.connection_string_urn.path == "oasis:names:specification:docbook:dtd:xml:4.1.2"
    error_message = "Path is not oasis:names:specification:docbook:dtd:xml:4.1.2"
  }
}
