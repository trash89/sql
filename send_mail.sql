create or replace procedure send_mail (sender in varchar2,recipient in varchar2,message in varchar2) is
        mailhost varchar2(30) := 'mailhost.ilog.fr';
        mail_conn utl_smtp.connection;
begin
        mail_conn := utl_smtp.open_connection(mailhost, 25);
        utl_smtp.helo(mail_conn, mailhost);
        utl_smtp.mail(mail_conn, sender);
        utl_smtp.rcpt(mail_conn, recipient);
        utl_smtp.data(mail_conn, message);
        utl_smtp.quit(mail_conn);
exception
when others then
        null;
end;
/

