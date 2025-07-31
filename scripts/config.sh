Host bastion
  HostName <Ip elastico do seu bastion>
  User ubuntu
  IdentityFile ~/.ssh/projeto.pem

Host webserver
  HostName <Ip privado do seu webserver>
  User ubuntu
  IdentityFile ~/.ssh/projeto.pem
  ProxyJump bastion
