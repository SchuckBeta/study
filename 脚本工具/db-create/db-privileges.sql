use mysql;

select host, user from user;

create user crmj identified by '1qazse4';

grant all on os_creative.* to crmj@'%' identified by '1qazse4' with grant option;

flush privileges;

-- privileges.sql