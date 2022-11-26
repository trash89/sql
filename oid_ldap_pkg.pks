
set serveroutput on size unlimited
create or replace package oid_ldap_debug as
  active_trace boolean:=true;    --- by default, console trace using dbms_output.put_line
  trace_to_file boolean:=true;   --- file is /u01/app/oracle/admin/$DB_NAME/bdump/alert_$DB_NAME.log (the database alert.log)
end oid_ldap_debug;
/


-----   Requirements on IASDB databases running this package :
-----
-----   GRANT EXECUTE ON DBMS_SYSTEM TO ODS;
-----
-----   tipically ODS is the schema ODS on IASDB database
-----
-----

create or replace package oid_ldap_pkg as

  /*=================================================================================*
  *
  *   Package OID_LDAP_PKG   -  OID low level api
  *
  *   Author  : Marius RAICU (marius.raicu@sanofi-aventis.com)
  *
  *    (this package is developped and tested on OID 10g (10.2.1+) - installed 
  *      with OAS 10.2.1 (infrastructure install, including OID)
  *    This package should be installed under ODS database user, on IASDB database
  *      (the underlaying database for OAS 10.2.1 infrastructure.
  *
  *
  *==================================================================================*/



  /*===============================================================================================================
   *        Customize these variables on your environnment :
   *  
   *
   *         ldap_host     : the hostname where the OID server runs 
   *
   *         ldap_port     : non-ssl port for this OID server
   *
   *         ldap_port_ssl : ssl port for this OID server
   *
   *         ldap_user     : the username to connect; should be an privileged user, usually 'cn=orcladmin'
   *
   *         ldap_passwd   : the password for the administrative username
   *
   *         ldap_base     : is the root of your OID infrastructure under the cn=Groups is to be found.
   *                         This variable is used to calculate the cn=Groups position, in order to add groups.
   * 
   *         default_realm : is your OID default realm, where the users are to be created 
   *                         when the parameter p_users_realm is null for the create_user function.
   *
   * 
   *================================================================================================================*/ 
    
  ldap_host        VARCHAR2(256):='brscd1d2.d1.f1.enterprise';
  ldap_port        VARCHAR2(256):='13060';
  ldap_port_ssl    VARCHAR2(256):='13130';
  ldap_user        VARCHAR2(256):='cn=orcladmin';
  ldap_passwd      VARCHAR2(256):='infra10gr2';
  ldap_base        VARCHAR2(256):='dc=enterprise';
  default_realm    VARCHAR2(256):='dc=d1,dc=f1,dc=enterprise';

   
  --- the search filter used for groups selections (function find_group_and_get_dn, etc)
  v_group_search_filter varchar2(32000):='(objectclass=top)(objectclass=groupOfUniqueNames)(objectclass=orclGroup)';

  --- the search filter used for user selections  (function find_user_and_get_dn, etc)
  v_user_search_filter  varchar2(32000):='(objectclass=top)(objectclass=inetorgperson)(objectclass=organizationalPerson)(objectclass=person)'; 

  v_session DBMS_LDAP.session:=null;

  --- Returns a string of form "ldap_host:ldap_port" 
  function get_ldap return varchar2;

  --- open the connection to OId using the variables : ldap_host, ldap_port, ldap_user, ldap_passwd
  --- Returns dbms_ldap.sucess or -1 on failure.
  function init_oid(ssl boolean default false) return pls_integer;

  --- closes the OID connection and sets v_session to null
  --- Returns dbms_ldap.sucess or -1 on failure.
  function close_oid return pls_integer;


  ----- create a group with the following template : cn=p_group_name, cn=Groups, default_realm
  ----- if p_master_group_name is not null, then the template is : cn=p_group_name, cn=p_master_group_name,cn=Groups, default_realm
  ----- used to create groups and subgroups. Returns dbms_ldap.sucess or -1 on failure.
  function create_group(
            p_group_name          in varchar2, 
            p_description         in varchar2 default null,
            p_displayname         in varchar2 default null,
            p_master_group_name   in varchar2 default null
        ) return pls_integer;
  
  ---- Delete a group. The group must be emptied before deletion, i.e. no subgroups.
  function delete_group(
            p_group_name in varchar2
        ) return pls_integer;

  ---- add an user DN to group, under uniquemember attribute.
  function add_user_to_group(
            p_user_name  in varchar2,
            p_group_name in varchar2
        ) return pls_integer;

  ---- remove an user DN from uniquemember attribute of the group.
  function remove_user_from_group(
            p_user_name  in varchar2,
            p_group_name in varchar2
        ) return pls_integer;

  ---- print group details, the not null attributes. If no uniquemember is printed, the group has no users assigned.
  function print_group(
            p_group_name in varchar2
        ) return pls_integer;

  ---- list the groups defined on the OID.
  function list_groups return pls_integer;

  ---- Check whether the user belongs to a group, returns DBMS_LDAP_UTL.SUCCESS(0) if true, false (-3) otherwise
  function check_group_membership(
            p_user_name  in varchar2,
            p_group_name in varchar2
        ) return pls_integer;


  ---- The function get_group_membership() displays the list of groups to which the user is a member.
  function get_group_membership(
            p_user_name  in varchar2
        ) return pls_integer;


  ---- This function can create two types of users: pure OID-defined users, with OID password or Windows AD users, with delegated authentification.
  function create_user(
                        p_user_name              in varchar2,                ---- the uid attribute, used to search and identify an user 
                        p_user_type              in varchar2 default 'OID',  ---- OID/AD type for an user
                        p_users_realm            in varchar2 default null,   ---- the realm under the user is to be created. If null, then the function get_default_realm variable is used (if it returns null, then the global variable default_realm is returned)
                        p_cn                     in varchar2 default null,   ---- optionally, the cn attribute, if null the cn=p_user_name 
                        p_sn                     in varchar2 default null,   ---- the sn attribute, if null then p_user_name
                        p_givenname              in varchar2 default null,   ---- the givenname attribute, if null then p_user_name
                        p_krbprincipalname       in varchar2 default null,   ---- the krbprincipalname attribute, if null then p_user_name
                        p_displayname            in varchar2 default null,   ---- the displayname attribute, if null then p_user_name
                        p_mail                   in varchar2 default null,   ---- the mail attribute, if null then p_user_name
                        p_orclisenabled          in varchar2 default null,   ---- the orclisenabled attribute, if null then ENABLED
                        p_userpassword           in varchar2 default null,   ---- Starting from here, we distinguish an OID-defined user
                        p_orclsamaccountname     in varchar2 default null,   ---- This attribute is used for AD-defined users
                        p_orcluserprincipalname  in varchar2 default null,   ---- This attribute is used for AD-defined users
                        p_useraccountcontrol     in varchar2 default null    ---- the useraccountcontrol attribute, if null then 512 
        ) return pls_integer;

  ---- delete an user. The parameter p_user_name is the uid attribute. The user DN is retrieved using this attribute (uid=p_user_name) .
  function delete_user(
            p_user_name in varchar2
        ) return pls_integer;

  ---- for an OID-defined user, try to authentificate it using the given p_user_name/p_password.
  function authenticate_user(
            p_user_name in varchar2,
            p_password  in varchar2
        ) return pls_integer;

  ---- print the user details, the not null attributes.
  function print_user(
            p_user_name in varchar2
        ) return pls_integer;

  --- get an attribute value for an user. Returns null if the attribute is empty or does not exists.  
  function get_user_attr(
            p_user_name in varchar2,
            p_attr_name in varchar2
        ) return varchar2;

end oid_ldap_pkg;
/

show errors

