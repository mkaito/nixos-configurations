{
  # Add missing groups for service users. Workaround for NixOS 21.11
  users.users.dovecot2.group = "dovecot2";
  users.groups.dovecot2 = {};
  users.users.nginx.group = "nginx";
  users.groups.nginx = {};
  users.users.postfix.group = "postfix";
  users.groups.postfix = {};
}
